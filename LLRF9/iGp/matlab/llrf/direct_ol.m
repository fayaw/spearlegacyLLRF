% direct_ol         - Calculate open-loop response through the cavity
%
% Includes cavity response plus DAC interpolator and direct loop
% rotator.
% 
% Copyright (c) 2016-2020 Dimtel, Inc., All Rights Reserved
%
% $Id: direct_ol.m,v 1.1 2021/11/05 07:56:39 dim Exp $

function H = direct_ol(x, data)

G     = x(1);
sigma = x(2);
wr    = x(3);
tau   = x(4);
phi0  = x(5);

w = data.w(data.u);

H = -i*sigma*G*w./(w.^2 - i*sigma*w - wr^2) .* exp(-i*((w-data.wrf)*tau - phi0));

if (0)
  H = H.*(dac_ol(data));
end

if isfield(data, 'H_inter')
  % Add interpolator filter response
  H = H.*data.H_inter(data.u);
end

if isfield(data, 'H_rot')
  % Add rotator filter response
  H = H.*abs(data.H_rot(data.u));
end
