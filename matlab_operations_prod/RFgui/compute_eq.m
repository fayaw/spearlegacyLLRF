% compute_eq       - This function computes the response of the comb equalizer
%
% function Heq = compute_eq(prm)
%

function Heq = compute_eq(prm);

wdig = (prm.w - prm.wrf)./prm.f_comb;

if (length(wdig)==1)
  Heq = freqz(prm.Beq, 1, [wdig wdig]);
  Heq = Heq(1);
else
  Heq = freqz(prm.Beq, 1, wdig);
end
