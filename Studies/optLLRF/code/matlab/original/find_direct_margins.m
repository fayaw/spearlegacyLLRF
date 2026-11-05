% This function computes phase margins of the direct loop model
% estimated by parameters in x. It uses compute_loop(x, prm) to
% compute open-loop transfer function. Returns baseband frequencies
% fm (kHz) and phases pm (deg).
%
% function [fm, pm] = find_direct_margins(x, prm);
%
function [fm, pm] = find_direct_margins(prm);

%fstr = inline('abs(dir_gn(x, prm)-1)', 'x', 'prm');

wm(1) = fminbnd(@abs_dir_gn, min(prm.w), prm.wrf, [], prm);
wm(2) = fminbnd(@abs_dir_gn, prm.wrf, max(prm.w), [], prm);

prm.w=wm;
pm = angle(compute_loop(prm.dirmodel, prm))*180/pi;
fm = (wm-prm.wrf)/2e3/pi;


return

function val = abs_dir_gn(x,prm)
  val = abs(dir_gn(x, prm)-1);
return
  
