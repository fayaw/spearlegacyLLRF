% dac_analyze       - Load a series of sweep.sh files and reconstruct long response
%
% [t, y, yy, idx] = dac_analyze(froot, range, rf_period);
%
% Arguments:
%  froot     - File name root
%  range     - Scan range in buckets
%  rf_period - RF period, defaults to 2000 ps
%
% Outputs:
%  t         - Time scale vector (ps)
%  y         - Response in dB
%  yy        - Reconstructed impulse response, alternating sign at minima
%  idx       - Bunch timing index

%
% Copyright (c) 2013 Dimtel, Inc., All Rights Reserved
%
% $Id: dac_analyze.m,v 1.2 2013/11/04 19:06:43 dim Exp $
% $Date: 2013/11/04 19:06:43 $
% $Author: dim $
% $Revision: 1.2 $
% $Log: dac_analyze.m,v $
% Revision 1.2  2013/11/04 19:06:43  dim
% Reversed time axis, added manual minima list
%
% Revision 1.1  2013/09/05 06:12:55  dim
% Tools for output response optimization with shaper
%

function [t, y, yy, idx] = dac_analyze(froot, range, rf_period, peaks)

% Default to 2000 ps
if (nargin < 3)
  rf_period = 2000;
end

m=1;
for k=range
  eval(sprintf('x=load(''%s%d.dat'');', froot, k));
  y(:,m) = x(:,2); m = m + 1;
  t = x(:,1);
end

Ts = t(2)-t(1);
Npb = round(rf_period/Ts);

y = y(:);
t = [0:length(y)-1]*Ts;

idx=1:Npb:length(t);

for k=0:(Npb-1)
  val = y(idx+k);
  val = -sort(-val);
  iso(k+1) = val(1)-val(2);
end

[foo, u] = max(iso);

idx = idx + u - 1;
timing_sweep_plot(t, y, idx);

% Convert the signal to linear scale, flip sign at minima
y = 10.^(y/20);
if (nargin < 4)
  peaks = peakfinder(-y);
end
mask = ones(size(y));
sign = -1;
for k=1:length(peaks)-1
  mask(peaks(k):peaks(k+1)-1) = mask(peaks(k):peaks(k+1)-1) * sign;
  sign = -sign;
end
mask(peaks(end):end) = mask(peaks(end):end) * sign;
yy = y .* mask;
