% dir_gn           - Returns direct loop gain at a given frequency
%
% function y = dir_gn(w, prm)
%

function y = dir_gn(w, prm)

prm.w = w;
y = abs(compute_loop(prm.dirmodel, prm));
