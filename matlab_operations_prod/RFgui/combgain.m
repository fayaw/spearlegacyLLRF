% combgain         - Compute the loop gain of the comb filter
%
% Function combgain computes the loop gain of the comb filter
% at a given frequency (scalar or vector). Direct loop and
% equalizer TFs are used to compute the basic loop function.
%
% function H = combgain(w, prm)
%

function H = combgain(w, prm);

% Comb loop response
Hcomb = freqresp(prm.num*prm.cmbmodel(1), prm.den, exp(i*w*prm.T0)).';

prm.w = w + prm.wrf;
Ldir = compute_loop(prm.dirmodel, prm);
Heq  = compute_eq(prm);

H1 = Heq.*Ldir./(1-Ldir);

H = abs(H1.*Hcomb);
