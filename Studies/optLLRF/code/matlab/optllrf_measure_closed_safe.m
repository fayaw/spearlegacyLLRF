function optllrf_measure_closed_safe(hObject, eventdata, handles)
%OPTLLRF_MEASURE_CLOSED_SAFE  RFgui "Measure Direct Closed" with the RFP state restored on every exit.
%   Same arguments as measure_direct_closed (the RFgui callback): call it from RFgui, or from the
%   command line with  h = guidata(<RFgui figure>); optllrf_measure_closed_safe([], [], h).
%
%   measure_direct_closed saves and restores the RFP multiplexers only on its normal path.  After
%   save_RFP_mux it can return early on about 25 error paths -- among them a file-transfer
%   time-out after DACS has been set to 1 -- which leaves the noise DACs enabled, the signal
%   multiplexer on TOTAL and the module in single-shot mode.  This wrapper reads the settings the
%   routine changes, runs it unchanged, and restores them through onCleanup on every exit,
%   including errors.  It writes only values that it read before the measurement; DACS is
%   switched off first.  Review with the RF group before first use (study plan, Section 10).
%
%   Settings watched: FBSIG, CAVSEL, DINJ, DACS, SSCONT, RUNMODE, MODU.RMSZ of <station>:STN:RFP.

rf = [handles.station ':STN:RFP'];
pvs = {[rf ':DACS']; [rf ':FBSIG']; [rf ':CAVSEL']; [rf ':DINJ']; [rf ':MODU.RMSZ']; [rf ':RUNMODE']; [rf ':SSCONT']};
before = lcaGet(pvs, 1, 'double');
fprintf('optllrf: RFP state before the measurement: %s\n', describe(pvs, before));
guard = onCleanup(@() restore(rf, pvs, before));
measure_direct_closed(hObject, eventdata, handles);
clear guard   % restores now, and reports
end

function restore(rf, pvs, before)
now_ = lcaGet(pvs, 1, 'double');
changed = find(now_(:) ~= before(:));
if isempty(changed)
    fprintf('optllrf: RFP state unchanged after the measurement\n');
    return
end
fprintf('optllrf: restoring %s\n', describe(pvs(changed), before(changed)));
for k = changed'                          % order of pvs: DACS first, SSCONT last
    lcaPut(pvs{k}, before(k));
end
for st = 0:2                              % reset, load, run -- as restore_RFP_mux does
    lcaPut([rf ':STATE'], st);
    pause(0.1);
end
after = lcaGet(pvs, 1, 'double');
bad = find(after(:) ~= before(:));
if isempty(bad)
    fprintf('optllrf: RFP state restored\n');
else
    warning('optllrf:restore', 'RFP state NOT restored for %s', describe(pvs(bad), after(bad)));
end
end

function s = describe(pvs, vals)
parts = cell(1, numel(pvs));
for k = 1:numel(pvs)
    parts{k} = sprintf('%s=%g', regexprep(pvs{k}, '^.*?:STN:RFP:', ''), vals(k));
end
s = strjoin(parts, ', ');
end
