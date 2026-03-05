% vector_sum_setup  - Set up vector sum and direct loop

function setup=vector_sum_setup(sys)

base=[sys, ':BRD1:'];

% Cavity vector combiner
setup.pvs.cavg{1} = [base, 'ROT:CAV1:GAIN'];
setup.pvs.cavp{1} = [base, 'ROT:CAV1:PHASE'];
setup.pvs.cavg{2} = [base, 'ROT:CAV2:GAIN'];
setup.pvs.cavp{2} = [base, 'ROT:CAV2:PHASE'];

% Direct loop gains and phases
setup.pvs.dirg{1} = [base, 'ROT:P_OL:GAIN'];
setup.pvs.dirp{1} = [base, 'ROT:P_OL:PHASE'];
setup.pvs.dirg{2} = [base, 'ROT:P_CL:GAIN'];
setup.pvs.dirp{2} = [base, 'ROT:P_CL:PHASE'];

% Diagnostic DDC channel
setup.pvs.diag{1} = [base, 'SCALAR:RAW:AMP4'];
setup.pvs.diag{2} = [base, 'SCALAR:RAW:PHASE4'];
setup.pvs.diagsel = [base, 'DIAGSEL'];

% Initial setup - get cavity 1 vector sum set at gain 1, phase 0
lcaPut({setup.pvs.cavg{1}; setup.pvs.cavp{1}}, [1; 0]);

% Step 1: configure rotated cavity signals to have the same ratio as scalar
% channels
setup.pvs.scalarV{1} = [base, 'CH0:AMP'];
setup.pvs.scalarP{1} = [base, 'CH0:PHASE'];
setup.pvs.scalarV{2} = [base, 'CH1:AMP'];
setup.pvs.scalarP{2} = [base, 'CH1:PHASE'];

setup.VcA = lcaGet(setup.pvs.scalarV(:));

lcaPut(setup.pvs.diagsel, 'Cavity 1 rotated');
pause(0.5);
setup.rot(:,1) = lcaGet(setup.pvs.diag(:));
lcaPut(setup.pvs.diagsel, 'Cavity 2 rotated');
pause(0.5);
setup.rot(:,2) = lcaGet(setup.pvs.diag(:));
lcaPut(setup.pvs.diagsel, 'Reference rotated');
pause(0.5);
setup.ref = lcaGet(setup.pvs.diag(:));

setup.cavg = lcaGet(setup.pvs.cavg(:));

% Now we need to adjust settings to have: Arot(1)/Arot(2) = VcA(1)/VcA(2)
% and (Arot(1)+Arot(2))/2 = Aref

% This is the scaling for cavg{2}
scale = setup.VcA(2)/setup.VcA(1)*setup.rot(1,1)/setup.rot(1,2);

if (scale*setup.cavg(2) > 1)
  % Scale down cavg(1);
  setup.cavg(1) = setup.cavg(1)/scale;
else
  setup.cavg(2) = setup.cavg(2)*scale;
end
lcaPut(setup.pvs.cavg(:), setup.cavg);

setup.scale = scale;

% Read rotated channels again
lcaPut(setup.pvs.diagsel, 'Cavity 1 rotated');
pause(0.5);
setup.rot(:,1) = lcaGet(setup.pvs.diag(:));
lcaPut(setup.pvs.diagsel, 'Cavity 2 rotated');
pause(0.5);
setup.rot(:,2) = lcaGet(setup.pvs.diag(:));

setup.dirg = lcaGet(setup.pvs.dirg(:));

% Next, trim the reference signal
scale = setup.ref(1)/mean(setup.rot(1,:));
g = scale*setup.dirg(1);
if (g > 1)
  error(sprintf('Required direct open-loop gain is %.2f > 1', g));
end
lcaPut(setup.pvs.dirg(1), g);
setup.scale(2) = scale;

% Match rotated phase of cavity 1 to reference phase
setup.dirp = value_adjust(setup.pvs.dirp{1}, setup.ref(2)-setup.rot(2,1));
lcaPut(setup.pvs.dirp{2}, setup.dirp);

% Match cavity 2 to cavity 1
value_adjust(setup.pvs.cavp{2}, setup.rot(2,1)-setup.rot(2,2));

pause(1);

% Now, match readout phases to the setpoint phase
setup.pvs.setpt  = [base, 'SETPT:PHASE'];
setup.pvs.off_cav1{1} = [base, 'CH0:PH_OFFSET']; % Probe
setup.pvs.off_cav1{2} = [base, 'CH2:PH_OFFSET']; % Forward
setup.pvs.off_cav2{1} = [base, 'CH1:PH_OFFSET']; % Probe
setup.pvs.off_cav2{2} = [sys, ':BRD2:CH0:PH_OFFSET']; % Forward

setup.p_set = lcaGet(setup.pvs.setpt);
setup.VcP = lcaGet(setup.pvs.scalarP(:));

setup.rdbk_adj = setup.p_set - setup.VcP;

% Cavity 1 adjustment
value_adjust(setup.pvs.off_cav1{1}, setup.rdbk_adj(1));
value_adjust(setup.pvs.off_cav1{2}, setup.rdbk_adj(1));

% Cavity 2 adjustment
value_adjust(setup.pvs.off_cav2{1}, setup.rdbk_adj(2));
value_adjust(setup.pvs.off_cav2{2}, setup.rdbk_adj(2));
