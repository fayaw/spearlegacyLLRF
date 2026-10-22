% This function computes closed-loop TF using direct loop and comb loop
% models. Error between analytical and measured functions is then computed
%
% x(1)	- wr (cavity resonant frequency, rad/s)
% x(2)  - Ql (cavity loaded Q) added 04/02/2007 and incremented all of the
%         indices below
% x(3)  - G (direct loop gain, v/v)
% x(4)  - Td (time delay, s)
% x(5)  - phase_offset (direct loop phase offset, rad)
% x(6)	- Gc (comb loop gain, v/v)
% x(7)  - Tc (comb loop delay)
% x(8)  - phase_offset (comb loop phase offset, rad)
%
% Parameter structure prm has members
%
% prm.w        - frequency vector, rad/s
% prm.H        - comb-loop transfer function measured to TOTAL
% prm.wrf      - RF frequency, rad/s
% prm.scale    - scaling for direct loop params
% prm.scale1   - scaling for comb loop params
% prm.num      - IIR numerator
% prm.den      - IIR denominator
% prm.T0       - revolution period
% prm.Beq      - Equalizer FIR coefficients
% prm.f_comb   - Comb loop sampling frequency

function er = fit_loop3(x, prm)

x(1)=(prm.wrf+2e3*pi*prm.detune)/prm.scale(1);
% modify code below to account for the inclustion of Ql in the initial prm
% structure
% xx = [x(1) prm.Ql x(2:4)];
% prm.scale=[prm.scale(1) 1 prm.scale(2:end)];
% Ldir = compute_loop(xx, prm);
% Lcmb = compute_comb(x(5:7), prm);
Ldir = compute_loop(x(1:5), prm);
if prm.combPresent,
    Lcmb = compute_comb(x(6:8), prm);
    L = Ldir./(1-(1+Lcmb).*Ldir);
else
    L = Ldir./(1-Ldir);
end % if prm.combPresent,
er = sum(prm.Weight.*abs(L-prm.H).^2);

return