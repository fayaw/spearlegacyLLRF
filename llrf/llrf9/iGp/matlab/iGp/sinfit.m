% sinfit            - Reliably fit a sine wave to the data
%
% Copyright (c) 2006 Dimtel, Inc., All Rights Reserved
%
% $Id: sinfit.m,v 1.2 2021/09/27 22:14:49 dim Exp $
% $Date: 2021/09/27 22:14:49 $
% $Author: dim $
% $Revision: 1.2 $
% $Log: sinfit.m,v $
% Revision 1.2  2021/09/27 22:14:49  dim
% Cleaned up fitting guess/scale to avoid divide by zero for zero mean signals
%
% Revision 1.1.1.1  2010/10/05 16:43:01  dim
% Initial import of iGp12
%
% Revision 1.3  2009/02/06 00:10:45  dim
% Sinewave fitting improvements, processing downsampling and beam current added
%
% Revision 1.2  2008/01/05 20:48:23  dim
% Bug fixes for better fitting
%
% Revision 1.1  2007/10/28 08:23:15  dim
% Tools to include in the distribution
%
% Revision 1.2  2007/08/09 17:23:11  dim
% Eliminated DC when searching for spectral peak
%
% Revision 1.1  2007/03/14 08:35:58  dim
% Matlab tools for data acquisition and testing with file-based data exchange
%
%

function [sol, x_fit, s] = sinfit(Ts, x, opts);

N = length(x);
s = fft(x)/N;
f = [0:N-1]/N/Ts; f = f(:);

[val, u] = max(abs(s(2:N/2)));
f0 = f(u+1);
a0 = (max(x)-min(x))/2;
m0 = mean(x);

% Phase search
p0 = [-pi -pi/2 0 pi/2];
for k=1:length(p0)
  guess = [a0 f0 p0(k) m0];
  vv(k) = sin_err(guess, Ts, x, [1 1 1 1]);
end
[foo, idx] = min(vv);

scale = [a0 f0/100000 1 m0+eps];
sol0 = [a0 f0 p0(idx) m0];
sol0 = sol0 ./ scale;
sol = fminunc('sin_err', sol0, opts, Ts, x, scale);
%sol = sol0;

sol = sol.*scale;
x_fit = sol(1)*sin(2*pi*sol(2)*[0:N-1]*Ts+sol(3)) + sol(4);
