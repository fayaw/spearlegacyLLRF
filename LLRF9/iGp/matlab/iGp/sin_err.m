% sin_err           - Error function for sin(a n) fitting
%
% Copyright (c) 2006 Dimtel, Inc., All Rights Reserved
%
% $Id: sin_err.m,v 1.1.1.1 2010/10/05 16:43:02 dim Exp $
% $Date: 2010/10/05 16:43:02 $
% $Author: dim $
% $Revision: 1.1.1.1 $
% $Log: sin_err.m,v $
% Revision 1.1.1.1  2010/10/05 16:43:02  dim
% Initial import of iGp12
%
% Revision 1.1  2007/10/28 08:23:15  dim
% Tools to include in the distribution
%
% Revision 1.1  2007/03/14 08:35:58  dim
% Matlab tools for data acquisition and testing with file-based data exchange
%
%

function [err, grad] = sin_err(x, Ts, y, scale);

x = x.*scale;
t = [0:length(y)-1]*Ts;

sv = sin(2*pi*x(2)*t+x(3));
del = x(1)*sv + x(4) - y;

err = sum(del.^2);


if (nargout == 2)
  grad(1) = 2*sum(del.*sv);
  grad(2) = 2*sum(del*x(1)*2*pi.*t.*cos(2*pi*x(2)*t + x(3)));
  grad(3) = 2*sum(del*x(1).*cos(2*pi*x(2)*t+x(3)));
  grad(4) = 2*sum(del);
%  grad = grad./scale;
  grad = grad(:);
end
