% This function accepts value and its standard deviation
% and formats those for presentation.
% Sigma is rounded to 1 significant digit. Value is rounded to
% the significant digit of the rounded sigma
% the case of sigma = 0 is addressed

function [v, s] = format_sigma(val, sig)

v = val;
s = sig;
ind = find(sig > 0);

pt = 10.^(floor(log10(sig(ind))));

v(ind) = round(val(ind)./pt).*pt;
s(ind) = round(sig(ind)./pt).*pt;

return
