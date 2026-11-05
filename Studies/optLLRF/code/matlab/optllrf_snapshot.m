function snap = optllrf_snapshot(outdir, station, note)
%OPTLLRF_SNAPSHOT  Read-only EPICS snapshot of the RF station for the optLLRF study.
%   SNAP = OPTLLRF_SNAPSHOT(OUTDIR, STATION, NOTE) reads every PV of the study list with labCA
%   (lcaGet only -- this function cannot write a PV), stores it as OUTDIR/<STATION>_<time>.json in
%   the format of spear3rf.live.Snapshot (fields time, station, values, pvs) and as a .mat file,
%   and returns the struct.  The PV list mirrors spear3rf/src/spear3rf/live.py so the Python
%   analysis (analyze_line.py, fit_sources.py) reads MATLAB snapshots directly.
%   Defaults: OUTDIR = pwd, STATION = 'SRF1', NOTE = ''.
%
%   Example (before and after every scan point, plan Section 9.3):
%       s = optllrf_snapshot('D:\optLLRF\data\snapshots', 'SRF1', 'I=200 mA, COUNTS.A=-0.2 dB');

if nargin < 1 || isempty(outdir), outdir = pwd; end
if nargin < 2 || isempty(station), station = 'SRF1'; end
if nargin < 3, note = ''; end

pv = pv_list(station);
keys = pv(:, 1);
names = pv(:, 2);
values = struct();
for k = 1:numel(keys)
    values.(keys{k}) = read_one(names{k});
end
values.note = note;                          % inside values: spear3rf.live.Snapshot takes no other top-level field
t = datetime('now');
snap.time = char(t, 'yyyy-MM-dd''T''HH:mm:ss');
snap.station = station;
snap.values = values;
snap.pvs = cell2struct(names, keys, 1);

if ~exist(outdir, 'dir'), mkdir(outdir); end
stem = fullfile(outdir, sprintf('%s_%s', station, char(t, 'yyyyMMdd''T''HHmmss')));
fid = fopen([stem '.json'], 'w');
fprintf(fid, '%s', jsonencode(snap));
fclose(fid);
save([stem '.mat'], 'snap');
missing = keys(cellfun(@(k) isempty(values.(k)) || (isnumeric(values.(k)) && any(isnan(values.(k)))), keys));
fprintf('snapshot %s.json: %d PVs, %d missing\n', stem, numel(keys), numel(missing));
if ~isempty(missing), fprintf('  missing: %s\n', strjoin(missing', ', ')); end
fprintf('  I %.1f mA, COUNTS.A %.2f dB, PHASE.C %.1f deg, PHASE.L %.1f deg, tracking %g\n', ...
    values.beam_current_mA, values.direct_counts_A, values.direct_phase_C, values.direct_phase_L, values.direct_track);
end

function v = read_one(name)
% Numeric read; a string record (the station state) falls back to char.  Unreachable -> NaN.
try
    v = lcaGet(name, 1, 'double');
catch
    try
        v = lcaGet(name, 0, 'char');
        if iscell(v), v = v{1}; end
    catch
        v = NaN;
    end
end
end

function pv = pv_list(s)
pv = {
    'f_rf_MHz',              'SPEAR:RFFreq'
    'state',                 [s ':STN:STATE:STRING']
    'beam_current_mA',       [s ':STN:BEAM:CURR']
    'stn_volt_kV',           [s ':STN:VOLT']
    'stn_volt_set_kV',       [s ':STN:VOLT:CTRL']
    'kly_fwd_kW',            [s ':KLYSOUTFRWD:POWER']
    'kly_fwd_max_kW',        [s ':KLYSOUTFRWD:POWER:MAX']
    'kly_refl_kW',           [s ':KLYSOUTREFL:POWER']
    'kly_drive_W',           [s ':KLYSDRIVFRWD:POWER']
    'kly_drive_set_W',       [s ':KLYSDRIVFRWD:POWER:ON']
    'kly_drive_sat_W',       [s ':KLYSDRIVFRWD:POWER:SAT']
    'kly_gain_dB',           [s ':KLYS:GAIN']
    'kly_eff_pct',           [s ':KLYS:EFFICIENCY']
    'hvps_kV',               [s ':HVPS:VOLT']
    'hvps_A',                [s ':HVPS:CURR']
    'circ_load_kW',          [s ':CIRCLDFRWD:POWER']
    'wg01_load_kW',          [s ':WG01LDFRWD:POWER']
    'wg02_load_kW',          [s ':WG02LDFRWD:POWER']
    'wg03_load_kW',          [s ':WG03LDFRWD:POWER']
    'direct_on',             [s ':STNDIRECT:LOOP:CTRL']
    'direct_track',          [s ':STNDIRECT:LOOP:TRACK']
    'intcomp',               [s ':STNDIRECT:INTCOMP:CTRL']
    'leadcomp',              [s ':STNDIRECT:LEADCOMP:CTRL']
    'intcomp_rfp',           [s ':STN:RFP:INTCOMP']
    'leadcomp_rfp',          [s ':STN:RFP:LEADCOMP']
    'comb_on',               [s ':STNCOMB:LOOP:CTRL']
    'rfp_ripple',            [s ':STN:RFP:RIPPLELOOP']
    'rfp_analog_ripple',     [s ':STN:RFP:ARIPPLELOOP']
    'rfp_fbsig',             [s ':STN:RFP:FBSIG']
    'ripple_dc_coef',        [s ':STNRIPPLE:LOOP:AMPL']
    'gff_on',                [s ':STN:GFF:CTRL']
    'lfb_on',                [s ':STN:LFB:CTRL']
    'ripple_track',          [s ':STNRIPPLE:LOOP:TRACK']
    'tuner_loop_on',         [s ':CAVTUNR:LOOP:CTRL']
    'load_angle_offset_on',  [s ':CAVLOAD:ANGLE:CTRL']
    'cav_freq_offs_avg_kHz', [s ':CAV:FREQ:OFFS']
    'direct_counts',         [s ':STNDIRECT:LOOP:COUNTS']
    'direct_phase_deg',      [s ':STNDIRECT:LOOP:PHASE']
    };
for f = 'ABCDEFGHIJKL'
    pv(end + 1, :) = {['direct_counts_' f], [s ':STNDIRECT:LOOP:COUNTS.' f]}; %#ok<AGROW>
    pv(end + 1, :) = {['direct_phase_' f], [s ':STNDIRECT:LOOP:PHASE.' f]}; %#ok<AGROW>
end
for n = 1:4
    c = sprintf('%s:CAV%d', s, n);
    p = sprintf('cav%d_', n);
    pv(end + 1:end + 11, :) = {
        [p 'volt_kV'],            [c 'PROBE:AMPL']
        [p 'probe_phase_deg'],    [c 'PROBE:PHASE']
        [p 'fwd_kW'],             [c 'FRWD:POWER']
        [p 'fwd_phase_deg'],      [c 'FRWD:PHASE']
        [p 'refl_kW'],            [c 'REFL:POWER']
        [p 'freq_offs_kHz'],      [c ':FREQ:OFFS']
        [p 'vswr'],               [c ':CPLG:FACTOR']
        [p 'beta_model'],         [c ':BETA:CTRL']
        [p 'q0_model'],           [c ':Q0:CTRL']
        [p 'load_angle_err_deg'], [c 'LOAD:ANGLE:ERR']
        [p 'tuner_mm'],           [c 'TUNR:STEP:MOTOR.RBV']
        };
end
end
