% dac_ol            - Calculate open-loop DAC response
%
% Assumes 120 nH and 47 pF lowpass with 50 ohm source and load
% 
% Copyright (c) 2016-2020 Dimtel, Inc., All Rights Reserved
%
% $Id$

function H = dac_ol(data)

w = data.w(data.u);
w_if=w-data.f_lo*2*pi; % At IF frequency
s = i*w_if;

% Zero order hold at 2*f_s
H_zoh = sinc(w_if/4/pi/data.f_s);

% DAC lowpass response
Rl=50; L=120e-9; C=47e-12;
H_lp = 2*Rl./(s.^2*L*C*Rl + (L+C*Rl^2)*s + 2*Rl);

H = H_zoh.*H_lp;
