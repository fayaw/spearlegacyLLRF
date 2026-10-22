% dir_ph           - Returns direct loop phase at a given frequency
%
% function y = dir_ph(w, prm)
%

function y = dir_ph(w, prm)

prm.w = w;
y = angle(compute_loop(prm.dirmodel, prm));
return
