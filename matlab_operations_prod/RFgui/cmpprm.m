% cmpprm           - Displays required adjustments from prm to prm1 argument
%
% function cmpprm(prm, prm1)
%
% If called with only one argument cmpprm() computes prm1 using optim_loop()
%

function cmpprm(prm, prm1)

if (nargin == 1)
  prm1 = optim_loop(prm);
end
fprintf('\n\n');
% Direct loop gain
disp(['Increase direct loop gain by ', ...
      num2str(20*log10(prm1.dirmodel(3)./prm.dirmodel(3))), ' dB']);
% Direct loop phase
delta = (prm.dirmodel(5)-prm1.dirmodel(5))/pi*180;
delta = mod(delta, 360);
if (delta > 180) delta = delta - 360; end
disp(['Increase direct loop phase by ', ...
      num2str(delta), ' degrees']);
if prm.combPresent,
    % Comb loop gain
    disp(['Increase comb loop gain by ', ...
        num2str(20*log10(prm1.cmbmodel(1)./prm.cmbmodel(1))), ' dB']);
    % Comb loop delay
    disp(['Increase comb loop delay by ', ...
        num2str((prm1.cmbmodel(2)-prm.cmbmodel(2))*1e9), ' ns']);
    % Comb loop phase
    delta = (prm.cmbmodel(3)-prm1.cmbmodel(3))/pi*180;
    delta = mod(delta, 360);
    if (delta > 180) delta = delta - 360; end
    disp(['Increase comb loop phase by ', ...
        num2str(delta), ' degrees']);
end % if prm.combPresent,
fprintf('\n');
