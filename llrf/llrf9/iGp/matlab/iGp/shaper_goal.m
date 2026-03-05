% shaper_goal       - Goal function for the deconvolution optimization
%
% drv = shaper(c, prm);
%
% Arguments:
%  x   - Shaper coefficients
%  prm - Impulse response, time scales
%  idx - Timing offset
%
% Outputs:
%  y   - Coupling ratio, linear scale

%
% Copyright (c) 2013 Dimtel, Inc., All Rights Reserved
%
% $Id: shaper_goal.m,v 1.2 2013/11/04 19:06:43 dim Exp $
% $Date: 2013/11/04 19:06:43 $
% $Author: dim $
% $Revision: 1.2 $
% $Log: shaper_goal.m,v $
% Revision 1.2  2013/11/04 19:06:43  dim
% Reversed time axis, added manual minima list
%

function y = shaper_goal(x, prm, idx);

% x(1) - Shaping coefficient C2
% x(2) - Shaping coefficient C0

c   = [x(1) 1 x(2)];

drv = shaper(c, prm);
idx1 = idx + [1:prm.Npb:(length(drv)-idx)];

kicks = -sort(-abs(drv(idx1)));
y = kicks(2)/kicks(1);
