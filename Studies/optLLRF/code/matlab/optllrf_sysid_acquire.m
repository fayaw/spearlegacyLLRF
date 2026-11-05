function shots = optllrf_sysid_acquire(designs, cavities, nshots, outdir, varargin)
%OPTLLRF_SYSID_ACQUIRE  Designed-excitation shots of the SRF1 direct loop for data-driven identification.
%   SHOTS = OPTLLRF_SYSID_ACQUIRE(DESIGNS, CAVITIES, NSHOTS, OUTDIR, 'rfData', RFDATA, ...) plays each
%   design's I and Q DAC files (written by sysid_multisine.py --write-dac: <name>_I, <name>_Q) into the
%   klystron drive and records, in the same triggered shot, the controller output (signal RAM, FBSIG 0 =
%   TOTAL) and one cavity probe (cavity RAM, CAVSEL), as RFgui Measure Direct Closed and
%   measure_beam_phase do.  For every design, cavity and shot the four RAM files are copied to OUTDIR as
%   <design>_c<cav>_s<shot>_{SIG,CAV}_{I,Q}; with 'drive', true one extra shot per design records the
%   drive (FBSIG 3), which gives the drive phase phi_u.  Snapshots (optllrf_snapshot) are taken before and
%   after.  The Python analysis is sysid_multisine.py --analyze OUTDIR.
%
%   Options:  'station' ('SRF1'), 'rfData' (required: the workstation path whose <station> subfolder the
%   IOC sees as /dat -- handles.rfData of RFgui), 'drive' (false), 'maxWait' (30 s per file transfer).
%
%   The DAC files must already be in <rfData>/<station>/ (copy them deliberately; this function does not).
%   The function writes only: MODU.RMSZ, RUNMODE, MODU.DIRF/DQRF (+ load), MODU.SIRF/SQRF/CIRF/CQRF,
%   SSCONT, DACS, FBSIG, CAVSEL and STATE, and restores every one of them except the file names through
%   onCleanup on every exit, DACS first, then reset/load/run (as restore_RFP_mux).  It refuses to run if
%   the RF or the direct loop is off.  UNTESTED on the machine: review with the RF group first.
%
%   Example (low current, both designs, all four cavities, three shots each):
%       s = optllrf_sysid_acquire({'SYSID_MS_A','SYSID_MS_B'}, 0:3, 3, 'D:\optLLRF\data\sysid\20261101', ...
%                                 'rfData', handles.rfData, 'drive', true);

p = inputParser;
addParameter(p, 'station', 'SRF1');
addParameter(p, 'rfData', '');
addParameter(p, 'drive', false);
addParameter(p, 'maxWait', 30);
parse(p, varargin{:});
o = p.Results;
if isempty(o.rfData), error('optllrf:sysid', 'give ''rfData'' (handles.rfData of RFgui)'); end
if ischar(designs), designs = {designs}; end
rf = [o.station ':STN:RFP'];
dat = fullfile(o.rfData, o.station);
if ~exist(outdir, 'dir'), mkdir(outdir); end

% preconditions (as measure_direct_closed)
if ~strcmpi(strtrim(char(lcaGet([rf ':RFENABLE']))), 'ON'), error('optllrf:sysid', 'RF must be on'); end
if ~strncmpi(strtrim(char(lcaGet([o.station ':STNDIRECT:LOOP:CTRL']))), 'ON', 2)
    error('optllrf:sysid', 'the direct loop must be closed');
end
for k = 1:numel(designs)
    for q = 'IQ'
        if ~exist(fullfile(dat, [designs{k} '_' q]), 'file')
            error('optllrf:sysid', 'DAC file %s not found in %s', [designs{k} '_' q], dat);
        end
    end
end

% state to restore (DACS first, SSCONT last)
pvs = {[rf ':DACS']; [rf ':FBSIG']; [rf ':CAVSEL']; [rf ':DINJ']; [rf ':MODU.RMSZ']; [rf ':RUNMODE']; [rf ':SSCONT']};
before = lcaGet(pvs, 1, 'double');
fprintf('optllrf_sysid: RFP state before: %s\n', describe(pvs, before));
guard = onCleanup(@() restore(rf, pvs, before));
optllrf_snapshot(outdir, o.station, 'sysid: before');

lcaPut([rf ':MODU.RMSZ'], 256);                % 2^18 samples per RAM record
lcaPut([rf ':RUNMODE'], 1);
loadrfstates(rf);
shots = struct('design', {}, 'cavity', {}, 'shot', {}, 'fbsig', {}, 'files', {}, 'time', {});
for k = 1:numel(designs)
    load_dac(rf, 'I', ['/dat/' designs{k} '_I'], o.maxWait);
    load_dac(rf, 'Q', ['/dat/' designs{k} '_Q'], o.maxWait);
    lcaPut([rf ':MODU.SIRF'], '/dat/OPTLLRF_SIG_I');
    lcaPut([rf ':MODU.SQRF'], '/dat/OPTLLRF_SIG_Q');
    lcaPut([rf ':MODU.CIRF'], '/dat/OPTLLRF_CAV_I');
    lcaPut([rf ':MODU.CQRF'], '/dat/OPTLLRF_CAV_Q');
    lcaPut([rf ':SSCONT'], 0);                 % single shot
    lcaPut([rf ':DACS'], 1);
    plan = [zeros(numel(cavities) * nshots, 1), kron(cavities(:), ones(nshots, 1)), ...
            repmat((1:nshots)', numel(cavities), 1)];
    if o.drive, plan(end + 1, :) = [3, cavities(1), 1]; end %#ok<AGROW>
    for r = 1:size(plan, 1)
        lcaPut([rf ':FBSIG'], plan(r, 1));
        lcaPut([rf ':CAVSEL'], plan(r, 2));
        cyclerfstates(rf);                     % reset, load, run (single shot), load
        pause(1);
        stem = sprintf('%s_c%d_s%d', designs{k}, plan(r, 2), plan(r, 3));
        if plan(r, 1) == 3, stem = [designs{k} '_drive']; end
        files = {};
        for x = {'GSIR', 'SIST', 'OPTLLRF_SIG_I', 'SIG_I'; 'GSQR', 'SQST', 'OPTLLRF_SIG_Q', 'SIG_Q'; ...
                 'GCIR', 'CIST', 'OPTLLRF_CAV_I', 'CAV_I'; 'GCQR', 'CQST', 'OPTLLRF_CAV_Q', 'CAV_Q'}'
            lcaPut([rf ':MODU.' x{1}], 1);
            wait_ok([rf ':MODU.' x{2}], o.maxWait);
            dst = fullfile(outdir, [stem '_' x{4}]);
            copyfile(fullfile(dat, x{3}), dst, 'f');
            files{end + 1} = dst; %#ok<AGROW>
        end
        shots(end + 1) = struct('design', designs{k}, 'cavity', plan(r, 2), 'shot', plan(r, 3), ...
                                'fbsig', plan(r, 1), 'files', {files}, 'time', char(datetime('now'))); %#ok<AGROW>
        fprintf('optllrf_sysid: %s (FBSIG %d, CAVSEL %d) recorded\n', stem, plan(r, 1), plan(r, 2));
    end
    lcaPut([rf ':DACS'], 0);
end
optllrf_snapshot(outdir, o.station, 'sysid: after');
save(fullfile(outdir, 'optllrf_sysid_shots.mat'), 'shots', 'designs', 'cavities', 'nshots');
clear guard
end

function load_dac(rf, q, name, maxWait)
fld = 'DIRF'; ld = 'LDIR'; st = 'DIST';
if q == 'Q', fld = 'DQRF'; ld = 'LDQR'; st = 'DQST'; end
if ~strcmp(strtrim(char(lcaGet([rf ':MODU.' fld]))), name)
    lcaPut([rf ':MODU.' fld], name);
    lcaPut([rf ':MODU.' ld], 1);
    wait_ok([rf ':MODU.' st], maxWait);
end
end

function wait_ok(pv, maxWait)
pause(2);
t0 = tic;
while ~strncmpi(strtrim(char(lcaGet(pv))), 'N', 1)    % 'NO_ALARM' when the transfer is done
    if toc(t0) > maxWait, error('optllrf:sysid', 'time-out waiting for %s', pv); end
    pause(1);
end
end

function restore(rf, pvs, before)
now_ = lcaGet(pvs, 1, 'double');
changed = find(now_(:) ~= before(:));
for k = changed'
    lcaPut(pvs{k}, before(k));
end
for st = 0:2
    lcaPut([rf ':STATE'], st);
    pause(0.1);
end
after = lcaGet(pvs, 1, 'double');
bad = find(after(:) ~= before(:));
if isempty(bad)
    fprintf('optllrf_sysid: RFP state restored\n');
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
