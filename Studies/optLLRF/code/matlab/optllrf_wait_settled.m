function [ok, log] = optllrf_wait_settled(station, timeout_s, period_s, n_stable)
%OPTLLRF_WAIT_SETTLED  Read-only check that the station has settled after a setting change.
%   [OK, LOG] = OPTLLRF_WAIT_SETTLED(STATION, TIMEOUT_S, PERIOD_S, N_STABLE) polls, every
%   PERIOD_S seconds, the load-angle errors of the four cavities, the station voltage, the
%   klystron drive power, the HVPS voltage and the applied loop phase PHASE.L, and returns
%   OK = true as soon as the last N_STABLE polls all satisfy (plan Section 9.2, step 2):
%       |load-angle error| < 1 deg in every cavity
%       station voltage within +/-0.2 %, drive power within +/-2 %, HVPS within +/-0.2 %
%       PHASE.L within +/-0.3 deg
%   or OK = false after TIMEOUT_S.  LOG holds every poll.  lcaGet only: it writes no PV.
%   Defaults: 'SRF1', 180 s, 1 s, 10 polls.

if nargin < 1 || isempty(station), station = 'SRF1'; end
if nargin < 2 || isempty(timeout_s), timeout_s = 180; end
if nargin < 3 || isempty(period_s), period_s = 1; end
if nargin < 4 || isempty(n_stable), n_stable = 10; end

s = station;
pvs = {[s ':CAV1LOAD:ANGLE:ERR']; [s ':CAV2LOAD:ANGLE:ERR']; [s ':CAV3LOAD:ANGLE:ERR']; [s ':CAV4LOAD:ANGLE:ERR'];
       [s ':STN:VOLT']; [s ':KLYSDRIVFRWD:POWER']; [s ':HVPS:VOLT']; [s ':STNDIRECT:LOOP:PHASE.L']};
log = zeros(0, numel(pvs) + 1);
t0 = tic;
ok = false;
while toc(t0) < timeout_s
    v = lcaGet(pvs, 1, 'double');
    log(end + 1, :) = [toc(t0), v(:)']; %#ok<AGROW>
    if size(log, 1) >= n_stable
        w = log(end - n_stable + 1:end, 2:end);
        angles_ok = all(all(abs(w(:, 1:4)) < 1.0));
        rel = @(x) (max(x) - min(x)) / max(abs(mean(x)), eps) / 2;
        volt_ok = rel(w(:, 5)) < 0.002;
        drive_ok = rel(w(:, 6)) < 0.02;
        hvps_ok = rel(w(:, 7)) < 0.002;
        phase_ok = (max(w(:, 8)) - min(w(:, 8))) / 2 < 0.3;
        if angles_ok && volt_ok && drive_ok && hvps_ok && phase_ok
            ok = true;
            fprintf('settled after %.0f s: load angles %s deg, V %.0f kV, drive %.1f W, HVPS %.2f kV, PHASE.L %.2f deg\n', ...
                toc(t0), mat2str(round(v(1:4)', 2)), v(5), v(6), v(7), v(8));
            return
        end
    end
    pause(period_s);
end
fprintf('NOT settled after %.0f s (last: load angles %s deg, PHASE.L %.2f deg)\n', ...
    timeout_s, mat2str(round(log(end, 2:5), 2)), log(end, 9));
end
