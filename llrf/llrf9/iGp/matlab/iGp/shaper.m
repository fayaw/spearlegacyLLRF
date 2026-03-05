% shaper            - Shaper convolution calculator
%
% drv = shaper(c, prm);
%
% Arguments:
%  c    - FIR coefficients, 3 long
%  prm  - Impulse response, time scales
%
% Outputs:
%  drv  - Overall response (linear scale)

%
% Copyright (c) 2013 Dimtel, Inc., All Rights Reserved
%
% $Id: shaper.m,v 1.2 2013/11/04 19:06:43 dim Exp $
% $Date: 2013/11/04 19:06:43 $
% $Author: dim $
% $Revision: 1.2 $
% $Log: shaper.m,v $
% Revision 1.2  2013/11/04 19:06:43  dim
% Reversed time axis, added manual minima list
%

function drv = shaper(c, prm);

N = length(prm.impresp);
drv = zeros(N+2*prm.Npb, 1);
drv(1:N) = c(1)*prm.impresp;
drv(prm.Npb+(1:N)) = drv(prm.Npb+(1:N)) + c(2)*prm.impresp;
drv(2*prm.Npb+1:end) = drv(2*prm.Npb+1:end) + c(3)*prm.impresp;
