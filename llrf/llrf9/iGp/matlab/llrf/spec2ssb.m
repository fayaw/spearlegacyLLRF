% spec2ssb          - Extract SSB spectrum by averaging upper and lower SB

function [df S1 L1 idx bin] = spec2ssb(fr, Sx, ssb_span);

bin = mean(diff(fr))*1e6; % In Hz
[foo, idx] = max(abs(Sx));
npts = round(ssb_span/bin);

df = (fr(idx+[1:npts])-fr(idx))*1e6;
S1 = 10*log10(real(Sx(idx-[1:npts])+Sx(idx+[1:npts]))/2)-10*log10(max(real(Sx)));
L1 = S1 - 10*log10(bin);
