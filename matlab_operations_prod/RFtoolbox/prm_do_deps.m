% prm_do_deps       - Recomputes the dependent variables
%
% function prm = prm_do_deps(prm)
%

function prm = prm_do_deps(prm)

% Loaded cavity Q
prm.rf.Ql    = prm.rf.Q/(1+prm.rf.Beta);
% Loaded cavity shunt impedance
prm.rf.Rl    = prm.rf.Rs/(1+prm.rf.Beta);
prm.accel.n  = -prm.accel.h/2:(prm.accel.h/2-1); % Vector of rev harmonics
prm.accel.w0 = prm.accel.wrf/prm.accel.h;        % Revolution frequency
% Comb filter sampling frequency
prm.rf.fs    = prm.accel.w0*prm.rf.hcomb/2/pi;
