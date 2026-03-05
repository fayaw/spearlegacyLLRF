% shaper_optimize   - Optimizes shaping coefficients and timing
%
% [C0, C2, T, t, drv, idxb] = shaper_optimize(froot, range, rf_period);
%
% Arguments:
%  froot     - File name root
%  range     - Scan range in buckets
%  rf_period - RF period, defaults to 2000 ps
%
% Outputs:
%  C0        - Shaper coefficient, -2^17 to 2^17 range
%  C2        - Shaper coefficient, -2^17 to 2^17 range
%  T         - Optimal timing (ps)
%  t         - Time scale (ps)
%  drv       - Overall response (linear scale)
%  idxb      - Bunch timing index points

%
% Copyright (c) 2013 Dimtel, Inc., All Rights Reserved
%
% $Id: shaper_optimize.m,v 1.2 2013/11/04 19:06:43 dim Exp $
% $Date: 2013/11/04 19:06:43 $
% $Author: dim $
% $Revision: 1.2 $
% $Log: shaper_optimize.m,v $
% Revision 1.2  2013/11/04 19:06:43  dim
% Reversed time axis, added manual minima list
%
% Revision 1.1  2013/09/05 06:12:55  dim
% Tools for output response optimization with shaper
%

function [C0 C2 T t drv idxb] = shaper_optimize(froot, range, rf_period, peaks);

if (nargin < 3)
  rf_period = 2000;
end

figure(1); clf;
if (nargin < 4)
  [t, y, impresp] = dac_analyze(froot, range, rf_period);
else
  [t, y, impresp] = dac_analyze(froot, range, rf_period, peaks);
end

prm.impresp   = impresp;
prm.t         = t;
prm.rf_period = rf_period;
prm.Ts        = (t(2)-t(1));
prm.Npb       = round(rf_period/prm.Ts);

x0 = [20e3 -40e3]/2^17;
opts = optimset('Display', 'none');
idx=0:(prm.Npb-1);
for k=1:length(idx)
  [x, fv(k)] = fmincon('shaper_goal', x0, [],[],[],[], [-1 -1], ...
            [1 1], [], opts, prm, idx(k));
%  x = x0; fv(k) = -k;
  C2(k) = x(1)*2^17;
  C0(k) = x(2)*2^17;
  T(k)  = round(idx(k))*prm.Ts;
end

% Select the best isolation
[iso u] = min(fv);

drv = shaper([C2(u)/2^17 1 C0(u)/2^17], prm);
idxb = idx(u) + 1:prm.Npb:length(drv);
%drv = shaper([.15 1 -.3], prm); 
%idxb = 19+1:prm.Npb:length(drv);

figure(2);
t = [0:length(drv)-1]*prm.Ts;
timing_sweep_plot(t, 20*log10(abs(drv)), idxb);

C0 = C0(u);
C2 = C2(u);
T  = T(u);
