% direct_fit        - Fit measured open-loop response

% function data = direct_fit(data, span, flag)
%
% data - RTNA data structure
% span - fitting range, min to max, kHz
% flag - Disable LLRF systematics (Interpolator and vector rotation)
%
% Copyright (c) 2016-2020 Dimtel, Inc., All Rights Reserved
%
% $Id: direct_fit.m,v 1.2 2021/11/05 07:57:22 dim Exp $

function data = direct_fit(data, span, flag);

data.w = 2*pi*data.freq;
frf = data.wrf/2/pi;

f = data.freq -frf;

if (nargin == 1 | isempty(span))
  data.u = 1:length(f);
else
  data.u = find(f>=min(span) & f<=max(span));
end

if (nargin < 3)
  % Compute interpolator response
  theta = 2*pi*data.f_if/data.f_s;
  C = 1/2/cos(theta/2); % Interpolator coefficient
  w0 = (data.freq - data.f_lo)/data.f_s * pi;
  data.H_inter = freqz([C 1 C], [0 2], w0);

  % Compute rotator response
  if isfield(data, 'rot')
    data.vec = rot(data.rot.gn, data.rot.ph, theta);
    data.H_rot = freqz(data.vec, 1, w0);
    % Normalize out the gain at RF
    g0 = freqz(data.vec, 1, [1 1]*pi*data.f_if/data.f_s);
    g0 = abs(g0(1));
    data.H_rot = data.H_rot / g0;
  end
end

% First, fit the magnitude, extracting G, sigma, wr
[G0, idx] = max(abs(data.H(data.u)));
wr0       = data.w(data.u(idx(1)));
ph0       = data.phase(data.u(idx(1)));
u         = find(max(data.mag(data.u))-data.mag(data.u)<3);
sigma0    = (data.w(data.u(max(u)))-data.w(data.u(min(u))));

x0 = [G0 sigma0 wr0];

opts = optimset('TolX', 1e-9, 'TolFun', 1e-9, 'Disp', 'none');
x = fminsearch('direct_fit_mag', x0, opts, data);

data.fit.G     = x(1);
data.fit.sigma = x(2);
data.fit.wr    = x(3);
data.fit.x     = x;

x0 = [400e-9 ph0];

x = fminsearch('direct_fit_ph', x0, opts, data);

data.fit.tau   = x(1);
data.fit.phi   = mod(x(2), 2*pi)/pi*180;
data.fit.x     = [data.fit.x x];

% Finally, run joint optimization
x0 = data.fit.x;
x  = fminsearch('direct_fit_all', x0, opts, data);

data.fit.G     = x(1);
data.fit.sigma = x(2);
data.fit.wr    = x(3);
data.fit.tau   = x(4);
data.fit.phi   = mod(x(5), 2*pi)/pi*180;
data.fit.Q     = x(3)/x(2);
data.fit.x     = x;


data1   = data;
data1.w = linspace(min(data.w), max(data.w), 1024);
data1.u = 1:length(data1.w);
H = direct_ol(x, data1);

% Determine NaN insertion point
[foo, N] = max(diff(data.freq)); N = N + 1;
f1 = (data.freq(1:N-1)-frf)/1e3; f1 = f1(:);
f2 = (data.freq(N:end)-frf)/1e3; f2 = f2(:);
f3 = (data1.w-data1.wrf)/2e3/pi; f3 = f3(:);

clf;
mag=data.mag(:);
subplot(211); set(gca, 'fontsize', 12);
h = plot([f1; 0; f2], [mag(1:N-1); NaN; mag(N:end)], ...
         f3, 20*log10(abs(H(:))), 'r');
set(h, 'linewidth', 2);
xlabel('Frequency offset (kHz)');
ylabel('Gain (dB)');
legend('Data', 'Fit', 'Location', 'Best');
title(sprintf('Gain = %.3f, Q = %g, (w_r - w_{rf}) = %.2f kHz', ...
      data.fit.G, data.fit.Q, (data.fit.wr - data.wrf)/2e3/pi));
grid;

HH = data.H(:);
subplot(212); set(gca, 'fontsize', 12);
h = plot([f1; 0; f2], [angle(HH(1:N-1)); NaN; angle(HH(N:end))]/pi*180, ...
         f3, angle(H)/pi*180, 'r');
set(h, 'linewidth', 2);
xlabel('Frequency offset (kHz)');
ylabel('Phase (degrees)');
legend('Data', 'Fit', 'Location', 'Best');
title(sprintf('\\tau = %g ns, \\phi = %.1f deg', data.fit.tau*1e9, data.fit.phi));
grid;

data.fit.H = H;
data.fit.f = f3;
