% optim_loop       - Computes optimal values for direct and comb loops
%
% This function computes the optimal values for the direct loop gain and
% phase, comb loop gain, phase and one-turn delay based on the measured
% models
%
% function new = optim_loop(prm, dpm, cpm)
%
% prm - current (non-optimal) model
% dpm - desired direct loop phase margin (optional, default = 66 degrees)
% cgn - desired comb loop gain (optional, default = 17 dB)

function new = optim_loop(prm, dpm, cgn)

if (nargin < 3)
  cgn = 17;
end
if (nargin < 2)
  dpm = pi*66/180;
end
  
new = prm;
dir = prm.dirmodel;
cmb = prm.cmbmodel;

% First figure out correct direct loop phase
dir(5)=pi;
prm.w = dir(1);
L = compute_loop(dir, prm);
% What the angle should be
new.dirmodel(5) = -angle(L);

% Now find direct loop gain for 66 degrees phase margin

% Start from finding current unity gain points
[fm, pm] = find_direct_margins(new);
%funstr = inline('abs(dir_ph(x, prm))', 'x', 'prm');
%funstr replace with abs_dir_ph()

% Margins around the center frequency
fm = fm + (new.wrf - new.dirmodel(1))/2e3/pi;
prm.dirmodel = new.dirmodel;

% Shift the phase by dpm and find phase zero crossing near -fm
prm.dirmodel(5) = new.dirmodel(5) + dpm;
low = min(fm)*2e3*pi; wm(1) = low;
while (wm(1)==low)
  low = 2*low;
  wm(1) = fminbnd(@abs_dir_ph, low+new.dirmodel(1), new.dirmodel(1), [], prm);
end

% Shift the phase by -dpm and find phase zero crossing near fm
prm.dirmodel(5) = new.dirmodel(5) - dpm;
high = max(fm)*2e3*pi; wm(2) = high;
while (wm(2)==high)
  high = 2*high;
  wm(2) = fminbnd(@abs_dir_ph, new.dirmodel(1), high+new.dirmodel(1), [], prm);
end

% Find the largest gain
G = max(dir_gn(wm, new));

% Set loop gain so that G=1
new.dirmodel(3) = new.dirmodel(3)/G;

if prm.combPresent,
    % Figure out correct comb loop phase
    dir = new.dirmodel;
    prm.w = prm.wrf;
    Ldir = compute_loop(dir, prm);
    Hcl = Ldir./(1-Ldir);
    new.cmbmodel(3) = pi - angle(Hcl);

    % Now find what comb delay should be
    prm = new;
    prm.w = prm.wrf + 2*pi*linspace(-1e6, 1e6, 1024);
    Ldir = compute_loop(prm.dirmodel, prm);
    Heq = compute_eq(prm);

    H1 = Heq.*Ldir./(1-Ldir);

    ph = unwrap(angle(H1));
    p = polyfit(prm.w-prm.wrf, ph, 1);
    % Closed direct loop + equalizer delay
    Td = -p(1);
    % Set comb delay to complete 1 turn
    new.cmbmodel(2) = new.T0 - Td;

    % Compute optimal comb loop
    % Convert from dB
    gn = 10^(cgn/20);

    % Select 100 points from 0 to Frev/2
    w1 = 2*pi*linspace(0, 1/new.T0/2, 100);
    G1 = combgain(w1, new);

    % Use the peak as a guess
    [foo, idx] = max(G1);
    w0 = w1(idx);

    % Optimization function

    %funstr = inline('-combgain(x, prm)', 'x', 'prm');
    %funstr replaced with neg_combgain()
    wmax = fminsearch(@neg_combgain, w0, [], new);

    G1 = combgain(wmax, new);

    % Adjust comb gain so that G1=gn
    new.cmbmodel(1) = new.cmbmodel(1)*gn/G1;
end % if prm.combPresent,

return

function val = abs_dir_ph(x,prm)
  val = abs(dir_ph(x, prm));
return
  
function val = neg_combgain(x,prm)
  val  = -combgain(x, prm);
return
  
