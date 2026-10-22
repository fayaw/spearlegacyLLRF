% sys_prm           - Ring/RF/LFB parameter generator
%
% prm = sys_prm(machine)
%
% Currently supported values for machine:
%
% als
% dafne+
% dafne-
% dafne1+
% dafne1-
% dafne_strong
% bessy
% pepii-HER
% pepii-HER-afs
% pepii-LER
% pepii-LER-afs
% pepii-LAB
function prm = sys_prm(machine)

% initialize labca timeout parameters
lcaSetTimeout(0.05);
lcaSetRetryCount(200);
% bypass the invalid severity check
lcaSetSeverityWarnLevel(14); 

prm.files = file_prm(machine);
if (isfield(prm.files, 'error'))
  prm.error = prm.files.error;
  return;
end
prm.accel = accel_prm(machine);
if (isfield(prm.accel, 'error'))
  prm.error = prm.accel.error;
  return;
end
prm.lfb   = lfb_prm(machine, prm.accel);
if (isfield(prm.lfb, 'error'))
  prm.error = prm.lfb.error;
  return;
end
prm.rf    = rf_prm(machine);
if (isfield(prm.rf, 'error'))
  prm.error = prm.rf.error;
  return;
end

% Recompute dependent variables
prm = prm_do_deps(prm);
