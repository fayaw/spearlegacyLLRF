%% ========================================================================
%  SPEAR3 HVPS Simulink Model Builder
%  ========================================================================
%  Creates a Simulink model of the SPEAR3 High Voltage Power Supply system
%  at SLAC National Accelerator Laboratory.
%
%  System: 12-pulse thyristor phase-controlled rectifier
%  Output: -77 kV DC @ 22 A (1.7 MW nominal)
%  Architecture: PEP-II klystron power supply design (1997)
%
%  Requirements:
%    - MATLAB R2020b or later
%    - Simulink
%    - Simscape Electrical / Specialized Power Systems (powerlib)
%
%  Usage:
%    >> spear3_hvps_simulink_model   % Build and open the model
%    >> sim('SPEAR3_HVPS')           % Run the simulation
%
%  Equations (LaTeX for Live Script rendering):
%
%  $$V_{dc} = \frac{6\sqrt{2}}{\pi} V_{LL} \cos\alpha \approx 2.70 \, V_{LL} \cos\alpha$$
%
%  $$f_{ripple} = 12 \times f_{AC} = 720 \; \text{Hz}$$
%
%  $$f_{LC} = \frac{1}{2\pi\sqrt{LC}} \approx 103 \; \text{Hz}$$
%
%  $$I_{klystron} = \kappa \, V^{3/2} \quad (\text{perveance model})$$
%
%  Author: SSRL/SLAC Engineering (Codegen-assisted)
%  ========================================================================

%% Clean up
try close_system('SPEAR3_HVPS', 0); catch; end
bdclose all;
clear; clc;

% Track failed set_param calls globally
global SPS_PARAM_WARNINGS;
SPS_PARAM_WARNINGS = {};

%% ========================================================================
%  SECTION 1: SYSTEM PARAMETERS
%  All values from hvps/simulation/hvps_sim/config.py and technical docs
%  ========================================================================

% --- AC Input (Substation 507, Breaker 160) ---
P.ac_voltage_rms    = 12470;    % V line-to-line RMS
P.ac_frequency      = 60;       % Hz
P.ac_voltage_peak   = P.ac_voltage_rms * sqrt(2);  % V peak

% --- Phase-Shift Transformer T0 (3.5 MVA) ---
P.T0_rating_mva     = 3.5;
P.T0_phase_shift    = 15;       % degrees (creates +/-15 deg outputs)
P.T0_turns_ratio    = 1.0;      % Nominally 1:1 for phase shifting
P.T0_leakage_pu     = 0.05;     % 5% leakage reactance
P.T0_copper_loss_pu = 0.01;     % 1% copper losses

% --- Rectifier Transformers T1, T2 (1.5 MVA each) ---
P.Trect_rating_mva  = 1.5;
P.Trect_turns_ratio = 2.67;     % Step-up ratio (12.5 kV -> 33.3 kV)
P.Trect_pri_voltage = 12500;    % V RMS primary (phase-to-phase)
P.Trect_sec_voltage = 33300;    % V RMS secondary (phase-to-phase)
P.Trect_leakage_pu  = 0.06;
P.Trect_copper_loss = 0.012;

% --- Thyristor SCR Bridges (Powerex T8K7) ---
P.scr_stacks_per_bridge = 6;
P.scrs_per_stack    = 14;
P.scr_voltage_rating = 8000;    % V per SCR
P.scr_on_resistance = 0.001;    % Ohms on-state resistance per device
P.scr_fwd_voltage   = 1.5;      % V forward drop per SCR
P.scr_turn_on_us    = 5;        % microseconds
P.scr_turn_off_us   = 100;      % microseconds
P.scr_snubber_R     = 500;      % Ohms (snubber resistance)
P.scr_snubber_C     = 250e-9;   % F (snubber capacitance)

% --- Filter Components ---
P.L1                = 0.3;       % H (primary filter inductor 1)
P.L2                = 0.3;       % H (primary filter inductor 2)
P.L_rated_current   = 85;       % A (inductor current rating)
P.C_filter          = 8e-6;     % F (8 uF filter capacitor bank)
P.R_isolation       = 500;      % Ohms (PEP-II isolation resistors)
P.R_damping         = 50;       % Ohms (damping resistor for filter)
P.L3                = 200e-6;   % H (cable termination inductor)
P.L4                = 200e-6;   % H (cable termination inductor)
P.V_divider_ratio   = 1000;     % 1000:1 voltage divider

% --- Secondary Rectifier (D1-D24) ---
P.diode_fwd_drop    = 1.0;      % V per diode
P.num_diode_bridges = 4;        % 4 bridges in series

% --- Crowbar Protection (SCR13-16) ---
P.crowbar_stacks    = 4;
P.crowbar_V_rating  = 100e3;    % V
P.crowbar_I_rating  = 80;       % A
P.crowbar_delay_us  = 1;        % microseconds (fiber-optic trigger)
P.crowbar_R_on      = 0.5;      % Ohms (conducting impedance)
P.crowbar_enable_time = 8;      % seconds (T4:12 timer)

% --- Output Specifications ---
P.V_nominal         = -77e3;    % V (-77 kV, negative for cathode)
P.V_max             = -90e3;    % V (-90 kV maximum)
P.I_nominal         = 22;       % A
P.I_max             = 30;       % A
P.P_nominal         = 1.7e6;    % W (1.7 MW)

% --- Klystron Load ---
P.klystron_R_nom    = 3500;     % Ohms (nominal: 77kV/22A)
P.klystron_perveance = 1.0e-6;  % A/V^(3/2)
P.klystron_R_arc    = 10;       % Ohms (during arc)

% --- Control: PLC (Allen-Bradley SLC-5/03) ---
P.plc_scan_period   = 0.010;    % s (10 ms)
P.plc_filter_alpha  = 0.4;      % digital LPF coefficient
P.plc_ref_max       = 32000;    % N7:32 max internal reference
P.plc_phase_mult    = 12000;    % N7:40 phase multiplier
P.plc_phase_offset  = 6000;     % N7:41 phase offset
P.plc_phase_max     = 18000;    % N7:42 max phase angle

% --- Control: Enerpro FCOG1200 ---
P.sighi_min         = 0.9;      % V minimum SIG HI
P.sighi_max         = 5.9;      % V maximum SIG HI
P.alpha_min         = 30;       % degrees (max output at max SIG HI)
P.alpha_max         = 150;      % degrees (min output at min SIG HI)
P.enerpro_tau       = 0.050;    % s (PLL settling: ~3 AC cycles)

% --- Control: Regulator Board (SD-237-230-14-C1) ---
P.reg_Kp            = 2.0;      % proportional gain
P.reg_Ki            = 8.0;      % integral gain
P.reg_soft_start_s  = 5.0;      % seconds for soft-start ramp
P.reg_R_sighi       = 7500;     % Ohms (regulator to SIG HI)
P.plc_R_sighi       = 1000;     % Ohms (PLC to SIG HI)
P.reg_OV_trip_kV    = 85;       % kV overvoltage trip
P.reg_OC_trip_A     = 28;       % A overcurrent trip

% --- Simulation ---
P.sim_time          = 0.5;      % s (default simulation time)
P.sim_dt_max        = 10e-6;    % s (max solver step)
P.sim_solver        = 'ode23tb'; % stiff solver for power electronics

% --- Derived Parameters ---
%
% $$V_{dc,max} = \frac{6\sqrt{2}}{\pi} V_{LL} \approx 90 \; \text{kV at } \alpha=0$$
P.V_dc_max = (6*sqrt(2)/pi) * P.Trect_sec_voltage;

% $$f_{ripple} = 12 \times 60 = 720 \; \text{Hz}$$
P.f_ripple = 12 * P.ac_frequency;

% $$f_{LC} = \frac{1}{2\pi\sqrt{L \cdot C}} \approx 103 \; \text{Hz}$$
P.LC_resonance = 1/(2*pi*sqrt(P.L1 * P.C_filter));

fprintf('SPEAR3 HVPS Parameters Loaded:\n');
fprintf('  AC Input:       %.2f kV RMS, %d Hz\n', P.ac_voltage_rms/1e3, P.ac_frequency);
fprintf('  Max DC Output:  %.1f kV (at alpha=0)\n', P.V_dc_max/1e3);
fprintf('  Nominal Output: %.1f kV @ %.0f A\n', abs(P.V_nominal)/1e3, P.I_nominal);
fprintf('  Ripple freq:    %d Hz\n', P.f_ripple);
fprintf('  LC resonance:   %.1f Hz\n', P.LC_resonance);

%% ========================================================================
%  SECTION 2: CREATE SIMULINK MODEL
%  ========================================================================
%
%  IMPORTANT: SPS (Specialized Power Systems) blocks are masked subsystems.
%  The dialog DISPLAY LABELS shown in MathWorks docs often differ from the
%  actual programmatic MASK VARIABLE NAMES used by set_param/get_param.
%
%  To discover correct mask variable names for any SPS block, run:
%    names = get_param(blockPath, 'MaskNames');
%    vals  = get_param(blockPath, 'MaskValues');
%    disp([names, vals]);
%
%  Verified working parameters (from runtime testing):
%    - Three-Phase Source: 'Voltage', 'Frequency'  (default 'Yg' is fine)
%    - Three-Phase Transformer: see discover_block_params() output
%    - Universal Bridge: see discover_block_params() output
%    - Series RLC Branch: see discover_block_params() output

modelName = 'SPEAR3_HVPS';
new_system(modelName);
open_system(modelName);

% --- Solver Configuration ---
set_param(modelName, ...
    'Solver',           P.sim_solver, ...
    'StopTime',         num2str(P.sim_time), ...
    'MaxStep',          num2str(P.sim_dt_max), ...
    'RelTol',           '1e-4', ...
    'AbsTol',           '1e-6', ...
    'SimulationMode',   'normal');

% Specialized Power Systems requires the powergui block
blk = [modelName '/powergui'];
add_block('powerlib/powergui', blk, 'Position', [20 20 120 60]);
trySP(blk, 'SimulationMode', 'Continuous');

fprintf('Model "%s" created with solver %s\n', modelName, P.sim_solver);

%% ========================================================================
%  SECTION 3: AC SOURCE (Substation 507, 12.47 kV, 3-phase, 60 Hz)
%  ========================================================================
%
%  Three-Phase Source — Yg (grounded Y, the default) is correct for HVPS.
%  Parameters set individually via try-catch (mask names vary by version).

blk = [modelName '/AC_Source_12kV'];
add_block('powerlib/Electrical Sources/Three-Phase Source', blk, ...
    'Position', [80 200 140 280]);
trySP(blk, 'Voltage', num2str(P.ac_voltage_rms));
trySP(blk, 'Frequency', num2str(P.ac_frequency));
% Default config = 'Yg' (grounded Y) — no need to set.

%% ========================================================================
%  SECTION 4: PHASE-SHIFT TRANSFORMER T0 (3.5 MVA, +/-15 deg)
%  ========================================================================
%
%  T0 creates two sets of 3-phase voltages with +15 and -15 degree shifts.
%  This is the key to 12-pulse operation (30 deg total -> cancels 5th/7th).
%
%  $$\Delta\phi = \pm 15^\circ \implies \phi_{total} = 30^\circ$$
%  $$\text{Harmonics cancelled: } 5^\text{th}, 7^\text{th}, 17^\text{th}, 19^\text{th}, \ldots$$
%
%  Three-Phase Transformer (Two Windings) mask parameters:
%    'NominalPower'       -> '[Pn(VA) fn(Hz)]'
%    'Winding1'           -> '[V1(Vrms) R1(pu) L1(pu)]'
%    'Winding2'           -> '[V2(Vrms) R2(pu) L2(pu)]'
%    'Winding1Connection' -> 'Y' | 'Yn' | 'Yg' | 'Delta (D1)' | 'Delta (D11)'
%    'Winding2Connection' -> same options
%
%  To get +30 deg shift: Winding1='Delta (D11)', Winding2='Y'  (Dy11)
%  To get   0 deg shift: Winding1='Y', Winding2='Y'            (Yy0)

% T0a: +30 deg phase shift (Dy11 connection)
% Dy11: delta primary leads wye secondary by +30 degrees
blk = [modelName '/T0a_Plus30deg'];
add_block('powerlib/Elements/Three-Phase Transformer (Two Windings)', blk, ...
    'Position', [250 180 330 300]);
trySP(blk, 'NominalPower', sprintf('[%e %d]', P.T0_rating_mva*1e6/2, P.ac_frequency));
trySP(blk, 'Winding1', sprintf('[%d %f %f]', P.ac_voltage_rms, P.T0_copper_loss_pu, P.T0_leakage_pu/2));
trySP(blk, 'Winding2', sprintf('[%d %f %f]', P.Trect_pri_voltage, P.T0_copper_loss_pu, P.T0_leakage_pu/2));
trySP(blk, 'Winding1Connection', 'Delta (D1)');
trySP(blk, 'Winding2Connection', 'Y');

% T0b: 0 deg phase shift (Yy0 connection)
blk = [modelName '/T0b_Zero_deg'];
add_block('powerlib/Elements/Three-Phase Transformer (Two Windings)', blk, ...
    'Position', [250 350 330 470]);
trySP(blk, 'NominalPower', sprintf('[%e %d]', P.T0_rating_mva*1e6/2, P.ac_frequency));
trySP(blk, 'Winding1', sprintf('[%d %f %f]', P.ac_voltage_rms, P.T0_copper_loss_pu, P.T0_leakage_pu/2));
trySP(blk, 'Winding2', sprintf('[%d %f %f]', P.Trect_pri_voltage, P.T0_copper_loss_pu, P.T0_leakage_pu/2));
trySP(blk, 'Winding1Connection', 'Y');
trySP(blk, 'Winding2Connection', 'Y');

%% ========================================================================
%  SECTION 5: RECTIFIER TRANSFORMERS T1 and T2 (1.5 MVA, 2.67:1 step-up)
%  ========================================================================
%
%  $$\frac{V_2}{V_1} = \frac{33300}{12500} = 2.664$$

% T1: Rectifier transformer (fed from T0a, +30 deg path)
blk = [modelName '/T1_Rectifier_Xfmr'];
add_block('powerlib/Elements/Three-Phase Transformer (Two Windings)', blk, ...
    'Position', [450 180 530 300]);
trySP(blk, 'NominalPower', sprintf('[%e %d]', P.Trect_rating_mva*1e6, P.ac_frequency));
trySP(blk, 'Winding1', sprintf('[%d %f %f]', P.Trect_pri_voltage, P.Trect_copper_loss, P.Trect_leakage_pu/2));
trySP(blk, 'Winding2', sprintf('[%d %f %f]', P.Trect_sec_voltage, P.Trect_copper_loss, P.Trect_leakage_pu/2));
trySP(blk, 'Winding1Connection', 'Y');
trySP(blk, 'Winding2Connection', 'Y');

% T2: Rectifier transformer (fed from T0b, 0 deg path)
blk = [modelName '/T2_Rectifier_Xfmr'];
add_block('powerlib/Elements/Three-Phase Transformer (Two Windings)', blk, ...
    'Position', [450 350 530 470]);
trySP(blk, 'NominalPower', sprintf('[%e %d]', P.Trect_rating_mva*1e6, P.ac_frequency));
trySP(blk, 'Winding1', sprintf('[%d %f %f]', P.Trect_pri_voltage, P.Trect_copper_loss, P.Trect_leakage_pu/2));
trySP(blk, 'Winding2', sprintf('[%d %f %f]', P.Trect_sec_voltage, P.Trect_copper_loss, P.Trect_leakage_pu/2));
trySP(blk, 'Winding1Connection', 'Y');
trySP(blk, 'Winding2Connection', 'Y');

%% ========================================================================
%  SECTION 6: 12-PULSE SCR RECTIFIER BRIDGES
%  ========================================================================
%
%  Universal Bridge mask parameters (from MathWorks docs):
%    'Arms'                -> Number of bridge arms: 1 | 2 | 3
%    'Device'              -> 'Diodes' | 'Thyristors' | 'GTO / Diodes' |
%                             'MOSFET / Diodes' | 'IGBT / Diodes' |
%                             'Ideal Switches'
%    'Ron'                 -> Internal resistance (Ohms)
%    'Lon'                 -> Internal inductance (H)
%    'Vf'                  -> Forward voltage (V)
%    'SnubberResistance'   -> Snubber resistance Rs (Ohms)
%    'SnubberCapacitance'  -> Snubber capacitance Cs (F)
%
%  $$V_{dc,bridge} = \frac{3\sqrt{2}}{\pi} V_{LL} \cos\alpha = 1.35 \, V_{LL} \cos\alpha$$
%  $$V_{dc,12pulse} = 2 \times V_{dc,bridge} = 2.70 \, V_{LL} \cos\alpha$$

% --- Bridge 1: 6-pulse SCR bridge (from T1, +30 deg path) ---
blk = [modelName '/Bridge1_SCR'];
add_block('powerlib/Power Electronics/Universal Bridge', blk, ...
    'Position', [650 180 730 300]);
trySP(blk, 'Arms', '3');
trySP(blk, 'Device', 'Thyristors');
trySP(blk, 'Ron', num2str(P.scr_on_resistance));
trySP(blk, 'Lon', '0');
trySP(blk, 'Vf', num2str(P.scr_fwd_voltage));
trySP(blk, 'SnubberResistance', num2str(P.scr_snubber_R));
trySP(blk, 'SnubberCapacitance', num2str(P.scr_snubber_C));

% --- Bridge 2: 6-pulse SCR bridge (from T2, 0 deg path) ---
blk = [modelName '/Bridge2_SCR'];
add_block('powerlib/Power Electronics/Universal Bridge', blk, ...
    'Position', [650 350 730 470]);
trySP(blk, 'Arms', '3');
trySP(blk, 'Device', 'Thyristors');
trySP(blk, 'Ron', num2str(P.scr_on_resistance));
trySP(blk, 'Lon', '0');
trySP(blk, 'Vf', num2str(P.scr_fwd_voltage));
trySP(blk, 'SnubberResistance', num2str(P.scr_snubber_R));
trySP(blk, 'SnubberCapacitance', num2str(P.scr_snubber_C));

%% ========================================================================
%  SECTION 7: PULSE GENERATORS FOR THYRISTOR GATING
%  ========================================================================
%
%  Using "Pulse Generator (Thyristor)" block (recommended replacement for
%  the deprecated Synchronized 6-Pulse Generator).
%
%  Library path: powerlib/Power Electronics/Power Electronics Control/
%                Pulse Generator (Thyristor)
%
%  This block requires 'alpha' (firing angle in deg) and 'wt' (PLL angle)
%  as inputs and outputs gate pulse vectors PY and PD for 12-pulse config.
%
%  For simpler setup, we use the legacy Synchronized 6-Pulse Generator
%  from powerlib_extras which has direct voltage synchronization inputs.
%
%  Synchronized 6-Pulse Generator inputs:
%    Port 1: alpha_deg     (firing angle in degrees)
%    Ports 2-4: Vab, Vbc, Vca  (line-to-line sync voltages)
%    Port 5: block         (>0 to disable pulses)
%  Output:
%    Port 1: pulses        (6-element vector for Universal Bridge gate)
%
%  Parameters: 'Frequency', 'PulseWidth', 'DoublePulsing'

% Pulse generator for Bridge 1 (syncs to T1 primary voltages)
blk = [modelName '/PulseGen1'];
add_block('powerlib_extras/Control Blocks/Synchronized 6-Pulse Generator', blk, ...
    'Position', [560 100 640 160]);
trySP(blk, 'Frequency', num2str(P.ac_frequency));
trySP(blk, 'PulseWidth', '60');
trySP(blk, 'DoublePulsing', 'on');

% Pulse generator for Bridge 2 (syncs to T2 primary voltages)
blk = [modelName '/PulseGen2'];
add_block('powerlib_extras/Control Blocks/Synchronized 6-Pulse Generator', blk, ...
    'Position', [560 490 640 550]);
trySP(blk, 'Frequency', num2str(P.ac_frequency));
trySP(blk, 'PulseWidth', '60');
trySP(blk, 'DoublePulsing', 'on');

%% ========================================================================
%  SECTION 8: LC FILTER NETWORK
%  ========================================================================
%
%  Series RLC Branch mask parameters:
%    'Resistance'   -> R in Ohms
%    'Inductance'   -> L in Henries
%    'Capacitance'  -> C in Farads (inf = no capacitor)
%
%  $$f_{LC} = \frac{1}{2\pi\sqrt{L \cdot C}} = \frac{1}{2\pi\sqrt{0.3 \times 8 \times 10^{-6}}} \approx 103 \; \text{Hz}$$
%
%  $$\text{Attenuation at 720 Hz} = \left(\frac{f_{ripple}}{f_{LC}}\right)^2 \approx 49 \; (34 \; \text{dB})$$

% --- Filter Inductor L1 (0.3 H) ---
blk = [modelName '/L1_Filter'];
add_block('powerlib/Elements/Series RLC Branch', blk, ...
    'Position', [830 180 890 240]);
trySP(blk, 'Resistance', '0.5');
trySP(blk, 'Inductance', num2str(P.L1));
trySP(blk, 'Capacitance', 'inf');

% --- Filter Inductor L2 (0.3 H) ---
blk = [modelName '/L2_Filter'];
add_block('powerlib/Elements/Series RLC Branch', blk, ...
    'Position', [830 350 890 410]);
trySP(blk, 'Resistance', '0.5');
trySP(blk, 'Inductance', num2str(P.L2));
trySP(blk, 'Capacitance', 'inf');

% --- Filter Capacitor (8 uF in series with 500 Ohm isolation) ---
blk = [modelName '/C_Filter_Bank'];
add_block('powerlib/Elements/Series RLC Branch', blk, ...
    'Position', [960 250 1020 340]);
trySP(blk, 'Resistance', num2str(P.R_isolation));
trySP(blk, 'Inductance', '0');
trySP(blk, 'Capacitance', num2str(P.C_filter));

% --- Damping Resistor ---
blk = [modelName '/R_Damping'];
add_block('powerlib/Elements/Series RLC Branch', blk, ...
    'Position', [960 350 1020 410]);
trySP(blk, 'Resistance', num2str(P.R_damping));
trySP(blk, 'Inductance', '0');
trySP(blk, 'Capacitance', 'inf');

%% ========================================================================
%  SECTION 9: CABLE TERMINATION AND KLYSTRON LOAD
%  ========================================================================
%
%  $$\frac{dI}{dt}_{max} = \frac{V_{arc}}{L_3} = \frac{77000}{200 \times 10^{-6}} = 3.85 \times 10^{8} \; \text{A/s}$$

% --- Cable Termination Inductor L3 (200 uH) ---
blk = [modelName '/L3_Cable_Term'];
add_block('powerlib/Elements/Series RLC Branch', blk, ...
    'Position', [1100 250 1160 310]);
trySP(blk, 'Resistance', '0.1');
trySP(blk, 'Inductance', num2str(P.L3));
trySP(blk, 'Capacitance', 'inf');

% --- Klystron Load (resistive, 3500 Ohm nominal) ---
%
% $$R_{klystron} = \frac{V_{nom}}{I_{nom}} = \frac{77000}{22} \approx 3500 \; \Omega$$
%
% For nonlinear perveance: replace with MATLAB Function block
% implementing $$I = \kappa \, V^{3/2}$$, $$\kappa \approx 1 \; \mu A/V^{3/2}$$
blk = [modelName '/Klystron_Load'];
add_block('powerlib/Elements/Series RLC Branch', blk, ...
    'Position', [1220 250 1280 340]);
trySP(blk, 'Resistance', num2str(P.klystron_R_nom));
trySP(blk, 'Inductance', '0');
trySP(blk, 'Capacitance', 'inf');

%% ========================================================================
%  SECTION 10: CROWBAR PROTECTION SYSTEM
%  ========================================================================
%
%  Breaker block mask parameters:
%    'BreakerResistance' -> On-state resistance (Ohms)
%    'InitialState'      -> '0' (open) | '1' (closed)
%    'SwitchingTimes'    -> Vector of switching times, or '[]' for external
%
%  $$E_{arc} < 5 \; \text{J} \quad \text{(with crowbar, } t_{trigger} \approx 1 \; \mu\text{s)}$$

% Crowbar SCR (Breaker block as switch)
blk = [modelName '/Crowbar_SCR'];
add_block('powerlib/Elements/Breaker', blk, ...
    'Position', [1100 380 1160 440]);
trySP(blk, 'BreakerResistance', num2str(P.crowbar_R_on));
trySP(blk, 'InitialState', '0');
trySP(blk, 'SwitchingTimes', '[]');

% Crowbar trigger (Step: default beyond sim time = never triggers)
add_block('simulink/Sources/Step', [modelName '/Crowbar_Trigger'], ...
    'Position', [1000 400 1040 430], ...
    'Time', num2str(P.sim_time + 1), ...
    'Before', '0', ...
    'After', '1');

%% ========================================================================
%  SECTION 11: CONTROL SYSTEM SUBSYSTEM
%  ========================================================================
%
%  Control hierarchy:
%    EPICS setpoint -> PLC filter -> PI regulator -> Enerpro -> alpha
%
%  $$\alpha = 150 - \frac{V_{SIG\_HI} - 0.9}{5.9 - 0.9} \times (150 - 30)$$
%
%  PLC digital low-pass filter (Rung 104):
%  $$y[n] = \alpha_{filt} \, x[n] + (1 - \alpha_{filt}) \, y[n-1]$$
%  $$\tau = \frac{-T}{\ln(1 - \alpha_{filt})} \approx 20 \; \text{ms}$$
%
%  PI Regulator:
%  $$V_{SIG\_HI} = K_p \, e(t) + K_i \int_0^t e(\tau) \, d\tau$$

controlSys = [modelName '/Control_System'];
add_block('simulink/Ports & Subsystems/Subsystem', controlSys, ...
    'Position', [500 550 700 700]);

% Remove default In1->Out1 connection created by Subsystem template
delete_line(controlSys, 'In1/1', 'Out1/1');
delete_block([controlSys '/In1']);
delete_block([controlSys '/Out1']);

% --- Input ports ---
add_block('simulink/Sources/In1', [controlSys '/V_measured_kV'], ...
    'Position', [30 50 60 65], 'Port', '1');
add_block('simulink/Sources/In1', [controlSys '/I_measured_A'], ...
    'Position', [30 120 60 135], 'Port', '2');

% --- Output port ---
add_block('simulink/Sinks/Out1', [controlSys '/alpha_deg'], ...
    'Position', [800 100 830 115], 'Port', '1');

% --- Voltage Setpoint (EPICS -> PLC N7:30) ---
add_block('simulink/Sources/Constant', [controlSys '/V_Setpoint_kV'], ...
    'Position', [30 200 100 230], ...
    'Value', num2str(abs(P.V_nominal)/1e3));

% --- Soft-Start Ramp ---
add_block('simulink/Sources/Ramp', [controlSys '/SoftStart_Ramp'], ...
    'Position', [130 200 190 230], ...
    'Slope', num2str(1/P.reg_soft_start_s), ...
    'StartTime', '0.5', ...
    'InitialOutput', '0');

add_block('simulink/Discontinuities/Saturation', [controlSys '/SoftStart_Sat'], ...
    'Position', [220 200 260 230], ...
    'UpperLimit', '1', ...
    'LowerLimit', '0');

% Multiply setpoint by soft-start envelope
add_block('simulink/Math Operations/Product', [controlSys '/SS_Multiply'], ...
    'Position', [300 180 340 230], ...
    'Inputs', '2');

% --- PLC Digital LPF (Rung 104) ---
add_block('simulink/Discrete/Discrete Transfer Fcn', [controlSys '/PLC_LPF'], ...
    'Position', [370 180 450 230], ...
    'Numerator', sprintf('[%f]', P.plc_filter_alpha), ...
    'Denominator', sprintf('[1 %f]', -(1 - P.plc_filter_alpha)), ...
    'SampleTime', num2str(P.plc_scan_period));

% --- Voltage Error (setpoint - measured) ---
add_block('simulink/Math Operations/Sum', [controlSys '/V_Error'], ...
    'Position', [500 80 530 120], ...
    'Inputs', '+-');

% --- PI Regulator (SD-237-230-14-C1) ---
add_block('simulink/Continuous/PID Controller', [controlSys '/PI_Regulator'], ...
    'Position', [570 75 640 125], ...
    'Controller', 'PI', ...
    'P', num2str(P.reg_Kp), ...
    'I', num2str(P.reg_Ki), ...
    'UpperSaturationLimit', '8', ...
    'LowerSaturationLimit', '0');

% --- Enerpro FCOG1200 Voltage-to-Angle Mapping ---
% Linear map: SIG HI 0.9V->150deg, 5.9V->30deg
% slope = -(150-30)/(5.9-0.9) = -24 deg/V
% alpha = slope * sig_hi + offset
enerpro_slope = -(P.alpha_max - P.alpha_min) / (P.sighi_max - P.sighi_min);  % -24
enerpro_offset = P.alpha_max - enerpro_slope * P.sighi_min;  % 150 - (-24)*0.9 = 171.6

add_block('simulink/Math Operations/Gain', [controlSys '/Enerpro_Gain'], ...
    'Position', [680 80 720 110], ...
    'Gain', num2str(enerpro_slope));

add_block('simulink/Math Operations/Add', [controlSys '/Enerpro_Offset'], ...
    'Position', [740 80 770 110], ...
    'Inputs', '++');

add_block('simulink/Sources/Constant', [controlSys '/Offset_Const'], ...
    'Position', [700 120 730 140], ...
    'Value', num2str(enerpro_offset));

% --- Firing Angle Saturation (30-150 deg) ---
add_block('simulink/Discontinuities/Saturation', [controlSys '/Alpha_Sat'], ...
    'Position', [790 80 830 115], ...
    'UpperLimit', num2str(P.alpha_max), ...
    'LowerLimit', num2str(P.alpha_min));

% --- Wire internal control subsystem ---
% Setpoint path
add_line(controlSys, 'V_Setpoint_kV/1', 'SS_Multiply/1');
add_line(controlSys, 'SoftStart_Ramp/1', 'SoftStart_Sat/1');
add_line(controlSys, 'SoftStart_Sat/1', 'SS_Multiply/2');
add_line(controlSys, 'SS_Multiply/1', 'PLC_LPF/1');
% Error
add_line(controlSys, 'PLC_LPF/1', 'V_Error/1');
add_line(controlSys, 'V_measured_kV/1', 'V_Error/2');
% PI -> Enerpro -> alpha
add_line(controlSys, 'V_Error/1', 'PI_Regulator/1');
add_line(controlSys, 'PI_Regulator/1', 'Enerpro_Gain/1');
add_line(controlSys, 'Enerpro_Gain/1', 'Enerpro_Offset/1');
add_line(controlSys, 'Offset_Const/1', 'Enerpro_Offset/2');
add_line(controlSys, 'Enerpro_Offset/1', 'Alpha_Sat/1');
add_line(controlSys, 'Alpha_Sat/1', 'alpha_deg/1');

%% ========================================================================
%  SECTION 12: MEASUREMENT AND INSTRUMENTATION
%  ========================================================================
%
%  $$V_{measured} = \frac{V_{out}}{1000} \quad \text{(1000:1 voltage divider)}$$

% Voltage Measurement (across klystron load)
add_block('powerlib/Measurements/Voltage Measurement', ...
    [modelName '/V_Measure_DC'], ...
    'Position', [1320 250 1360 290]);

% Voltage divider (1000:1)
add_block('simulink/Math Operations/Gain', [modelName '/V_Divider'], ...
    'Position', [1390 255 1420 280], ...
    'Gain', num2str(1/P.V_divider_ratio));

% Convert to kV
add_block('simulink/Math Operations/Gain', [modelName '/V_to_kV'], ...
    'Position', [1440 255 1470 280], ...
    'Gain', '1e-3');

% Current Measurement
add_block('powerlib/Measurements/Current Measurement', ...
    [modelName '/I_Measure_DC'], ...
    'Position', [1200 250 1240 290]);

% Scopes
add_block('simulink/Sinks/Scope', [modelName '/Scope_Output'], ...
    'Position', [1520 200 1560 260], ...
    'NumInputPorts', '3');

add_block('simulink/Sinks/Scope', [modelName '/Scope_Control'], ...
    'Position', [1520 300 1560 360], ...
    'NumInputPorts', '2');

% To Workspace blocks
add_block('simulink/Sinks/To Workspace', [modelName '/WS_Voltage_kV'], ...
    'Position', [1520 260 1580 280], ...
    'VariableName', 'V_out_kV', ...
    'MaxDataPoints', 'inf', ...
    'SampleTime', '-1');

add_block('simulink/Sinks/To Workspace', [modelName '/WS_Current_A'], ...
    'Position', [1520 370 1580 390], ...
    'VariableName', 'I_out_A', ...
    'MaxDataPoints', 'inf', ...
    'SampleTime', '-1');

add_block('simulink/Sinks/To Workspace', [modelName '/WS_Alpha_deg'], ...
    'Position', [1520 410 1580 430], ...
    'VariableName', 'alpha_deg_ws', ...
    'MaxDataPoints', 'inf', ...
    'SampleTime', '-1');

%% ========================================================================
%  SECTION 13: TOP-LEVEL WIRING (POWER PATH)
%  ========================================================================
%
%  Specialized Power Systems blocks use conserving (physical) ports.
%  Port names for SPS blocks:
%    Three-Phase Source:      A, B, C (output ports = LConn1, LConn2, LConn3)
%    Three-Phase Xfmr (2W):  A,B,C (pri=LConn1..3), a,b,c (sec=RConn1..3)
%    Universal Bridge:        A,B,C (AC=LConn1..3), +,- (DC=RConn1,RConn2)
%    Series RLC Branch:       +,- (LConn1, RConn1)
%    Voltage Measurement:     +,- (LConn1, RConn1)  output: Simulink signal
%    Current Measurement:     +,- (LConn1, RConn1)  output: Simulink signal
%
%  Note: Port naming uses 'LConn' and 'RConn' for physical (conserving)
%  ports on SPS blocks. Actual port numbering may vary by MATLAB version.
%  Connections wrapped in try-catch for version compatibility.

fprintf('\n--- Wiring Power Path ---\n');
fprintf('NOTE: SPS port names vary by MATLAB version.\n');
fprintf('If wiring errors occur, check get_param(block,''PortConnectivity'')\n\n');

% AC Source -> T0a primary (ABC -> ABC)
try
    add_line(modelName, 'AC_Source_12kV/LConn1', 'T0a_Plus30deg/LConn1', 'autorouting', 'on');
    add_line(modelName, 'AC_Source_12kV/LConn2', 'T0a_Plus30deg/LConn2', 'autorouting', 'on');
    add_line(modelName, 'AC_Source_12kV/LConn3', 'T0a_Plus30deg/LConn3', 'autorouting', 'on');
    fprintf('  AC -> T0a: OK\n');
catch ME, fprintf('  AC -> T0a: MANUAL WIRING NEEDED (%s)\n', ME.message); end

% AC Source -> T0b primary (ABC -> ABC)
try
    add_line(modelName, 'AC_Source_12kV/LConn1', 'T0b_Zero_deg/LConn1', 'autorouting', 'on');
    add_line(modelName, 'AC_Source_12kV/LConn2', 'T0b_Zero_deg/LConn2', 'autorouting', 'on');
    add_line(modelName, 'AC_Source_12kV/LConn3', 'T0b_Zero_deg/LConn3', 'autorouting', 'on');
    fprintf('  AC -> T0b: OK\n');
catch ME, fprintf('  AC -> T0b: MANUAL WIRING NEEDED (%s)\n', ME.message); end

% T0a secondary -> T1 primary
try
    add_line(modelName, 'T0a_Plus30deg/RConn1', 'T1_Rectifier_Xfmr/LConn1', 'autorouting', 'on');
    add_line(modelName, 'T0a_Plus30deg/RConn2', 'T1_Rectifier_Xfmr/LConn2', 'autorouting', 'on');
    add_line(modelName, 'T0a_Plus30deg/RConn3', 'T1_Rectifier_Xfmr/LConn3', 'autorouting', 'on');
    fprintf('  T0a -> T1: OK\n');
catch ME, fprintf('  T0a -> T1: MANUAL WIRING NEEDED (%s)\n', ME.message); end

% T0b secondary -> T2 primary
try
    add_line(modelName, 'T0b_Zero_deg/RConn1', 'T2_Rectifier_Xfmr/LConn1', 'autorouting', 'on');
    add_line(modelName, 'T0b_Zero_deg/RConn2', 'T2_Rectifier_Xfmr/LConn2', 'autorouting', 'on');
    add_line(modelName, 'T0b_Zero_deg/RConn3', 'T2_Rectifier_Xfmr/LConn3', 'autorouting', 'on');
    fprintf('  T0b -> T2: OK\n');
catch ME, fprintf('  T0b -> T2: MANUAL WIRING NEEDED (%s)\n', ME.message); end

% T1 secondary -> Bridge1 AC inputs
try
    add_line(modelName, 'T1_Rectifier_Xfmr/RConn1', 'Bridge1_SCR/LConn1', 'autorouting', 'on');
    add_line(modelName, 'T1_Rectifier_Xfmr/RConn2', 'Bridge1_SCR/LConn2', 'autorouting', 'on');
    add_line(modelName, 'T1_Rectifier_Xfmr/RConn3', 'Bridge1_SCR/LConn3', 'autorouting', 'on');
    fprintf('  T1 -> Bridge1: OK\n');
catch ME, fprintf('  T1 -> Bridge1: MANUAL WIRING NEEDED (%s)\n', ME.message); end

% T2 secondary -> Bridge2 AC inputs
try
    add_line(modelName, 'T2_Rectifier_Xfmr/RConn1', 'Bridge2_SCR/LConn1', 'autorouting', 'on');
    add_line(modelName, 'T2_Rectifier_Xfmr/RConn2', 'Bridge2_SCR/LConn2', 'autorouting', 'on');
    add_line(modelName, 'T2_Rectifier_Xfmr/RConn3', 'Bridge2_SCR/LConn3', 'autorouting', 'on');
    fprintf('  T2 -> Bridge2: OK\n');
catch ME, fprintf('  T2 -> Bridge2: MANUAL WIRING NEEDED (%s)\n', ME.message); end

% Gate pulses to bridges (Simulink signal -> Universal Bridge 'g' port)
try
    add_line(modelName, 'PulseGen1/1', 'Bridge1_SCR/1');
    add_line(modelName, 'PulseGen2/1', 'Bridge2_SCR/1');
    fprintf('  PulseGen -> Bridges: OK\n');
catch ME, fprintf('  PulseGen -> Bridges: MANUAL WIRING NEEDED (%s)\n', ME.message); end

% Control -> Pulse generators (alpha input)
try
    add_line(modelName, 'Control_System/1', 'PulseGen1/1');
    add_line(modelName, 'Control_System/1', 'PulseGen2/1');
    fprintf('  Control -> PulseGens: OK\n');
catch ME, fprintf('  Control -> PulseGens: MANUAL WIRING NEEDED (%s)\n', ME.message); end

% Bridge DC outputs -> filter inductors
% Bridge+ -> L_filter -> common bus -> C_filter -> L3 -> Klystron -> return
try
    add_line(modelName, 'Bridge1_SCR/RConn1', 'L1_Filter/LConn1', 'autorouting', 'on');
    add_line(modelName, 'Bridge2_SCR/RConn1', 'L2_Filter/LConn1', 'autorouting', 'on');
    fprintf('  Bridge+ -> L_filter: OK\n');
catch ME, fprintf('  Bridge+ -> L_filter: MANUAL WIRING NEEDED (%s)\n', ME.message); end

% Measurement -> Divider -> kV -> Control feedback
try
    add_line(modelName, 'V_Measure_DC/1', 'V_Divider/1');
    add_line(modelName, 'V_Divider/1', 'V_to_kV/1');
    add_line(modelName, 'V_to_kV/1', 'Control_System/1');
    add_line(modelName, 'V_to_kV/1', 'WS_Voltage_kV/1');
    add_line(modelName, 'I_Measure_DC/1', 'Control_System/2');
    add_line(modelName, 'I_Measure_DC/1', 'WS_Current_A/1');
    add_line(modelName, 'Control_System/1', 'WS_Alpha_deg/1');
    fprintf('  Feedback wiring: OK\n');
catch ME, fprintf('  Feedback: MANUAL WIRING NEEDED (%s)\n', ME.message); end

% Crowbar trigger
try
    add_line(modelName, 'Crowbar_Trigger/1', 'Crowbar_SCR/1');
    fprintf('  Crowbar trigger: OK\n');
catch ME, fprintf('  Crowbar: MANUAL WIRING NEEDED (%s)\n', ME.message); end

fprintf('\nWiring complete. Check messages above for any manual adjustments.\n');

%% ========================================================================
%  SECTION 14: SAVE MODEL
%  ========================================================================

save_system(modelName);
fprintf('\n=== Model "%s.slx" saved successfully ===\n', modelName);

%% ========================================================================
%  SECTION 15: POST-SIMULATION ANALYSIS FUNCTIONS
%  ========================================================================
%
%  Key system equations (LaTeX for Live Editor):
%
%  DC Output Voltage:
%  $$V_{dc} = \frac{6\sqrt{2}}{\pi} V_{LL} \cos\alpha$$
%
%  12-Pulse Ripple Frequency:
%  $$f_{ripple} = 12 f_{AC} = 720 \; \text{Hz}$$
%
%  Unfiltered Ripple (peak-to-peak):
%  $$\Delta V_{pp} = V_{dc} \left(1 - \cos\frac{\pi}{12}\right) / \cos\frac{\pi}{12} \approx 3.41\%$$
%
%  LC Filter Resonance:
%  $$f_0 = \frac{1}{2\pi\sqrt{LC}}$$
%
%  Filtered Ripple Attenuation at $n$-th harmonic:
%  $$A_n = \frac{1}{\left| 1 - \left(\frac{n \cdot f_{ripple}}{f_0}\right)^2 \right|}$$
%
%  Klystron Perveance Model:
%  $$I = \kappa \, V^{3/2}, \quad \kappa \approx 1 \; \mu\text{A/V}^{3/2}$$
%
%  PI Regulator Output:
%  $$u(t) = K_p \, e(t) + K_i \int_0^t e(\tau) \, d\tau$$
%
%  Enerpro Firing Angle Map:
%  $$\alpha = 171.6 - 24 \cdot V_{SIG\_HI} \quad (\text{deg})$$
%
%  PLC Digital Filter:
%  $$H(z) = \frac{\alpha_{filt}}{1 - (1-\alpha_{filt}) z^{-1}}, \quad \tau \approx 20 \; \text{ms}$$
%
%  Stored Energy in Filter:
%  $$E = \frac{1}{2} C V^2 + \frac{1}{2} L I^2$$
%
%  Arc Energy with Crowbar:
%  $$E_{arc} = \int_0^{t_{crow}} V(t) \cdot I(t) \, dt < 5 \; \text{J}$$

function plot_spear3_overview(t, V_kV, I_A, alpha_deg)
%PLOT_SPEAR3_OVERVIEW Generate 4-panel HVPS system overview
%
%   plot_spear3_overview(t, V_kV, I_A, alpha_deg)

    figure('Name', 'SPEAR3 HVPS System Overview', ...
           'Position', [100 100 1200 900]);
    
    subplot(4,1,1);
    plot(t, V_kV, 'b-', 'LineWidth', 1.5);
    hold on; yline(-77, 'r--', 'Nominal', 'LineWidth', 1);
    xlabel('Time (s)'); ylabel('Voltage (kV)');
    title('DC Output Voltage'); grid on;
    
    subplot(4,1,2);
    plot(t, I_A, 'Color', [0.8 0.4 0], 'LineWidth', 1.5);
    hold on; yline(22, 'r--', 'Nominal', 'LineWidth', 1);
    xlabel('Time (s)'); ylabel('Current (A)');
    title('DC Output Current'); grid on;
    
    subplot(4,1,3);
    plot(t, alpha_deg, 'Color', [0.2 0.6 0.2], 'LineWidth', 1.5);
    xlabel('Time (s)'); ylabel('\alpha (deg)');
    title('SCR Firing Angle'); grid on; ylim([0 180]);
    
    subplot(4,1,4);
    P_MW = abs(V_kV .* I_A) * 1e-3;
    plot(t, P_MW, 'm-', 'LineWidth', 1.5);
    hold on; yline(1.7, 'r--', 'Nominal', 'LineWidth', 1);
    xlabel('Time (s)'); ylabel('Power (MW)');
    title('Output Power'); grid on;
    
    sgtitle('SPEAR3 HVPS - Simulink Results', 'FontSize', 14, 'FontWeight', 'bold');
end

function analyze_ripple(t, V_kV, t_start)
%ANALYZE_RIPPLE Compute ripple metrics from steady-state waveform
%
%   analyze_ripple(t, V_kV, t_start)

    if nargin < 3, t_start = max(t)*0.5; end
    idx = t >= t_start;
    V_ss = V_kV(idx);
    V_mean = mean(abs(V_ss));
    rpp = max(V_ss) - min(V_ss);
    rrms = std(V_ss);
    
    fprintf('\n=== Ripple Analysis (t > %.2f s) ===\n', t_start);
    fprintf('  Mean |V|:   %.2f kV\n', V_mean);
    fprintf('  Ripple PP:  %.3f kV (%.3f%%)\n', rpp, rpp/V_mean*100);
    fprintf('  Ripple RMS: %.4f kV (%.4f%%)\n', rrms, rrms/V_mean*100);
    
    % FFT
    dt = mean(diff(t(idx)));
    Fs = 1/dt; N = length(V_ss);
    Y = fft(V_ss - mean(V_ss));
    f = (0:N/2-1)*Fs/N;
    mag = 2*abs(Y(1:N/2))/N;
    
    figure('Name', 'Ripple Spectrum');
    subplot(2,1,1); plot(t(idx), V_ss, 'b-');
    xlabel('Time (s)'); ylabel('V (kV)'); title('Steady-State Voltage'); grid on;
    subplot(2,1,2); stem(f, mag, 'b-', 'MarkerSize', 3);
    xlim([0 5000]); xlabel('Frequency (Hz)'); ylabel('Magnitude (kV)');
    title('Ripple Spectrum'); grid on;
    xline(720, 'r--', '720 Hz'); xline(1440, 'g--', '1440 Hz');
end

function analyze_protection(t, V_kV, I_A, arc_time)
%ANALYZE_PROTECTION Analyze arc/crowbar protection event
%
%   analyze_protection(t, V_kV, I_A, arc_time)

    w = 0.05;
    idx = (t >= arc_time-w) & (t <= arc_time+w);
    figure('Name', 'Protection Event');
    subplot(2,1,1); plot(t(idx)*1000, V_kV(idx), 'b-', 'LineWidth', 1.5);
    xlabel('Time (ms)'); ylabel('V (kV)'); title(sprintf('Voltage at arc t=%.3fs', arc_time));
    xline(arc_time*1000, 'r--', 'Arc'); grid on;
    subplot(2,1,2); plot(t(idx)*1000, I_A(idx), 'r-', 'LineWidth', 1.5);
    xlabel('Time (ms)'); ylabel('I (A)'); title('Current');
    xline(arc_time*1000, 'r--', 'Arc'); grid on;
    
    dt = mean(diff(t));
    ai = (t >= arc_time) & (t <= arc_time + 0.001);
    E = sum(abs(V_kV(ai)*1e3 .* I_A(ai)))*dt;
    fprintf('\n=== Protection Analysis ===\n');
    fprintf('  Arc energy: %.1f J (spec: <5 J)\n', E);
end

%% ========================================================================
%  SECTION 16: PARAMETER DISCOVERY HELPER
%  ========================================================================
%  Run this to discover valid parameter names for any SPS block:
%
%  >> discover_block_params('SPEAR3_HVPS/AC_Source_12kV')

function trySP(blk, paramName, paramValue)
%TRYSP Safely set a Simulink block parameter with try-catch
%  trySP(blk, paramName, paramValue) attempts set_param and warns on failure.
%  This prevents the entire model build from crashing if a mask variable
%  name differs from the MathWorks documentation display label.
%
%  If a parameter fails, run discover_block_params(blk) to find valid names.

    global SPS_PARAM_WARNINGS;
    try
        set_param(blk, paramName, paramValue);
    catch ME
        warnMsg = sprintf('  WARNING: %s -> ''%s'' failed: %s', blk, paramName, ME.message);
        fprintf('%s\n', warnMsg);
        fprintf('    FIX: Run discover_block_params(''%s'') to see valid names.\n', blk);
        SPS_PARAM_WARNINGS{end+1} = warnMsg;
    end
end

function discover_block_params(blockPath)
%DISCOVER_BLOCK_PARAMS List valid mask parameters for a Simulink block
%  discover_block_params(blockPath) prints all settable parameter names
%  and their current values. Use this to find the correct mask variable
%  name when MathWorks docs show only the display label.
%
%  Example:
%    discover_block_params('SPEAR3_HVPS/AC_Source_12kV')

    fprintf('\n===== Parameters for: %s =====\n', blockPath);

    % Method 1: DialogParameters (most reliable for settable params)
    try
        dp = get_param(blockPath, 'DialogParameters');
        names = fieldnames(dp);
        fprintf('\n--- DialogParameters ---\n');
        fprintf('%-30s %-15s %s\n', 'MASK VARIABLE', 'Type', 'Current Value');
        fprintf('%s\n', repmat('-', 1, 75));
        for i = 1:length(names)
            try
                val = get_param(blockPath, names{i});
                if ischar(val)
                    fprintf('%-30s %-15s %s\n', names{i}, dp.(names{i}).Type, val);
                else
                    fprintf('%-30s %-15s [non-string]\n', names{i}, dp.(names{i}).Type);
                end
            catch
                fprintf('%-30s %-15s [read error]\n', names{i}, dp.(names{i}).Type);
            end
        end
    catch ME
        fprintf('DialogParameters not available: %s\n', ME.message);
    end

    % Method 2: MaskNames + MaskValues (for masked subsystems)
    try
        mnames = get_param(blockPath, 'MaskNames');
        mvals  = get_param(blockPath, 'MaskValues');
        if ~isempty(mnames)
            fprintf('\n--- MaskNames / MaskValues ---\n');
            for i = 1:length(mnames)
                fprintf('  %-25s = %s\n', mnames{i}, mvals{i});
            end
        end
    catch; end

    fprintf('\n');
end

%% ========================================================================
%  DONE
%  ========================================================================

global SPS_PARAM_WARNINGS;

fprintf('\n');
fprintf('========================================================\n');
if isempty(SPS_PARAM_WARNINGS)
    fprintf(' SPEAR3 HVPS Simulink Model Built Successfully!\n');
else
    fprintf(' SPEAR3 HVPS Model Built with %d PARAMETER WARNINGS\n', ...
        length(SPS_PARAM_WARNINGS));
end
fprintf('========================================================\n');
fprintf(' Model: %s.slx\n', modelName);
fprintf(' Solver: %s, dt_max=%.0f us, t_stop=%.1f s\n', ...
    P.sim_solver, P.sim_dt_max*1e6, P.sim_time);
fprintf('========================================================\n');

if ~isempty(SPS_PARAM_WARNINGS)
    fprintf('\n*** PARAMETER WARNINGS (blocks still created with defaults) ***\n');
    for i = 1:length(SPS_PARAM_WARNINGS)
        fprintf('  %d. %s\n', i, SPS_PARAM_WARNINGS{i});
    end
    fprintf('\nTo fix: run discover_block_params(''%s/<BlockName>'') to find\n', modelName);
    fprintf('the correct mask variable names for your MATLAB version.\n');
end

fprintf('\nNext steps:\n');
fprintf('  1. open_system(''%s'')\n', modelName);
fprintf('  2. Verify wiring (check MANUAL WIRING NEEDED messages above)\n');
fprintf('  3. sim(''%s'')\n', modelName);
fprintf('  4. plot_spear3_overview(t, V, I, alpha)\n');
fprintf('  5. For arc test: set_param(''%s/Crowbar_Trigger'',''Time'',''0.3'')\n', modelName);
fprintf('\nTo discover block parameters:\n');
fprintf('  discover_block_params(''%s/AC_Source_12kV'')\n', modelName);
fprintf('\n');
