% timing_sweep_plot - Plot a timing sweep, optimal timing, sensitivity
%
% timing_sweep_plot(t, y, idx);
%
% Arguments:
%  t   - Time scale (ps)
%  y   - Response (dB)
%  idx - Optimal timing index

%
% Copyright (c) 2013 Dimtel, Inc., All Rights Reserved
%
% $Id: timing_sweep_plot.m,v 1.2 2013/11/04 19:06:43 dim Exp $
% $Date: 2013/11/04 19:06:43 $
% $Author: dim $
% $Revision: 1.2 $
% $Log: timing_sweep_plot.m,v $
% Revision 1.2  2013/11/04 19:06:43  dim
% Reversed time axis, added manual minima list
%
% Revision 1.1  2013/09/05 10:10:37  dim
% Initial import - tools for shaper optimization
%

function timing_sweep_plot(t, y, idx)

% Flip the time axis for the plots
t_plt = max(t)-t;

% Determine the isolation
yy = sort(y(idx));
iso = yy(end)-yy(end-1);

clf; subplot(211); set(gca, 'fontsize', 12);
plot(t_plt/1e3, y, t_plt(idx)/1e3, y(idx), 'or', 'markersize', 7, 'linewidth', 2);
xlabel('Time (ns)');
ylabel('Magnitude (dB)');
title(sprintf('Optimal timing %d ps with isolation of %.1f dB', ...
      t(idx(1)), iso));
grid;

% Plot timing sensitivity analysis
subplot(212); set(gca, 'fontsize', 12);
h = plot(t_plt/1e3, y); hold on;
markers = 'o+*xsdph^';
leg{1} = 'Response';
Ts = abs(t(2)-t(1));
delta = round(200/Ts); % +/-200 ps
Trange=-delta:delta;
m = 1;
for k=Trange;
  idx1 = idx + k;
  if (min(idx1) < 1) idx1 = idx1(2:end); end
  if (max(idx1) > length(y)) idx1 = idx1(1:end-1); end
  yy = sort(y(idx1));
  iso(m) = yy(end) - yy(end-1);
  h(m+1) = plot(t_plt(idx1)/1e3, y(idx1), markers(m));
  m = m + 1;
  leg{m} = sprintf('%d ps offset', k*Ts);
end
hold off;
set(h, 'markersize', 7, 'linewidth', 2);
set(h(2:end), 'color', 'r');
xlabel('Time (ns)');
ylabel('Magnitude (dB)');
[foo, u] = min(iso);
title(sprintf('Timing shift sensitivity: isolation %.1f dB at %d ps offset', ...
      iso(u), Trange(u)*Ts));
legend(leg, 3);
grid;
