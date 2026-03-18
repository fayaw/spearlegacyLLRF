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
%  Reference Documents:
%    - 00-spear3-hvps-legacy-system-design.md
%    - 01-pepii-power-supply-architecture.md
%    - 04-regulator-board-design.md
%    - Enerpro FCOG1200 technical notes
%    - PLC SLC-5/03 technical notes
%
%  Author: SSRL/SLAC Engineering (Codegen-assisted)
%  ========================================================================

%% Clean up
close_system('SPEAR3_HVPS', 0);  % Close if already open (suppress error)
bdclose all;
clear; clc;

%% ========================================================================
%  SECTION 1: SYSTEM PARAMETERS
%  All values from hvps/simulation/hvps_sim/config.py and technical docs
%  ========================================================================

% --- AC Input (Substation 507, Breaker 160) ---
P.ac_voltage_rms   = 12470;    % V line-to-line RMS
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
P.Trect_pri_voltage = 12500;    % V RMS primary
P.Trect_sec_voltage = 33300;    % V RMS secondary (line-to-line)
P.Trect_leakage_pu  = 0.06;
P.Trect_copper_loss = 0.012;

% --- Thyristor SCR Bridges (Powerex T8K7) ---
P.scr_stacks_per_bridge = 6;
P.scrs_per_stack    = 14;
P.scr_voltage_rating = 8000;    % V per SCR
P.scr_on_drop       = 1.5;      % V forward drop per SCR
P.scr_turn_on_us    = 5;        % microseconds
P.scr_turn_off_us   = 100;      % microseconds
P.scr_snubber_R     = 100;      % Ohms
P.scr_snubber_C     = 0.1e-6;   % F (0.1 uF)

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
P.P_nominal         = 1.7e6;   % W (1.7 MW)

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
P.alpha_min         = 30;       % degrees (max output)
P.alpha_max         = 150;      % degrees (min output)
P.enerpro_tau       = 0.050;    % s (PLL settling: ~3 AC cycles)

% --- Control: Regulator Board (SD-237-230-14-C1) ---
P.reg_Kp            = 2.0;      % proportional gain
P.reg_Ki            = 8.0;      % integral gain
P.reg_soft_start_s  = 5.0;      % seconds for soft-start ramp
P.reg_R_sighi       = 7500;     % Ohms (regulator to SIG HI)
P.plc_R_sighi       = 1000;     % Ohms (PLC to SIG HI)
P.reg_OV_trip_kV    = 85;       % kV overvoltage trip
P.reg_OC_trip_A     = 28;       % A overcurrent trip

% --- Protection Thresholds ---
P.arc_dVdt_thresh   = 1e9;      % V/s (arc detection)
P.arc_Vdrop_pct     = 20;       % % sudden drop
P.arc_Ispike_factor = 2.0;      % current doubling
P.temp_phase_max    = 80;       % deg C
P.temp_crowbar_max  = 60;       % deg C

% --- Simulation ---
P.sim_time          = 0.5;      % s (default simulation time)
P.sim_dt_max        = 10e-6;    % s (max solver step)
P.sim_solver        = 'ode23tb'; % stiff solver for power electronics

% --- Derived Parameters ---
P.V_dc_max = (6*sqrt(2)/pi) * P.Trect_sec_voltage;  % ~90 kV at alpha=0
P.f_ripple = 12 * P.ac_frequency;  % 720 Hz
P.LC_resonance = 1/(2*pi*sqrt(P.L1 * P.C_filter));  % ~103 Hz

fprintf('SPEAR3 HVPS Parameters Loaded:\n');
fprintf('  AC Input:       %.2f kV RMS, %d Hz\n', P.ac_voltage_rms/1e3, P.ac_frequency);
fprintf('  Max DC Output:  %.1f kV (at alpha=0)\n', P.V_dc_max/1e3);
fprintf('  Nominal Output: %.1f kV @ %.0f A\n', abs(P.V_nominal)/1e3, P.I_nominal);
fprintf('  Ripple freq:    %d Hz\n', P.f_ripple);
fprintf('  LC resonance:   %.1f Hz\n', P.LC_resonance);

%% ========================================================================
%  SECTION 2: CREATE SIMULINK MODEL
%  ========================================================================

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
add_block('powerlib/powergui', [modelName '/powergui'], ...
    'Position', [20 20 120 60], ...
    'SimulationMode', 'Continuous');

fprintf('Model "%s" created with solver %s\n', modelName, P.sim_solver);

%% ========================================================================
%  SECTION 3: AC SOURCE (Substation 507, 12.47 kV, 3-phase, 60 Hz)
%  ========================================================================

% Three-Phase Programmable Voltage Source
add_block('powerlib/Electrical Sources/Three-Phase Source', ...
    [modelName '/AC_Source_12kV'], ...
    'Position', [80 200 140 280], ...
    'PhaseVoltage', num2str(P.ac_voltage_rms / sqrt(3)), ...  % Phase voltage
    'Frequency', num2str(P.ac_frequency), ...
    'InternalConnection', 'Yg', ...  % Grounded Wye
    'SourceImpedance', '[0.01 0.05]');  % [R(pu) L(pu)]

% --- Annotation ---
add_block('built-in/Note', [modelName '/Note_AC'], ...
    'Position', [60 150 220 190], ...
    'Text', sprintf('Substation 507, Breaker 160\n12.47 kV RMS, 60 Hz, 3-phase'));

%% ========================================================================
%  SECTION 4: PHASE-SHIFT TRANSFORMER T0 (3.5 MVA, +/-15 deg)
%  ========================================================================
%  T0 creates two sets of 3-phase voltages with +15 and -15 degree shifts.
%  This is the key to 12-pulse operation (30 deg total -> cancels 5th/7th).
%
%  Implementation: Two Three-Phase Transformers
%    T0a: Delta-Wye with +15 deg phase shift (feeds T1)
%    T0b: Delta-Wye with -15 deg phase shift (feeds T2)

% T0a: Phase-shift transformer, Set 1 (+15 degrees)
add_block('powerlib/Elements/Three-Phase Transformer (Two Windings)', ...
    [modelName '/T0a_PhaseShift_Plus15'], ...
    'Position', [250 180 330 300], ...
    'NominalPower', sprintf('[%e %d]', P.T0_rating_mva*1e6/2, P.ac_frequency), ...
    'Winding1', sprintf('[%d 0.002 %f]', P.ac_voltage_rms, P.T0_leakage_pu/2), ...
    'Winding2', sprintf('[%d 0.002 %f]', P.Trect_pri_voltage, P.T0_leakage_pu/2), ...
    'Winding1Connection', 'D11', ...   % Delta primary
    'Winding2Connection', 'Yg');       % Grounded Wye secondary (+30 deg inherent)

% T0b: Phase-shift transformer, Set 2 (-15 degrees)
add_block('powerlib/Elements/Three-Phase Transformer (Two Windings)', ...
    [modelName '/T0b_PhaseShift_Minus15'], ...
    'Position', [250 350 330 470], ...
    'NominalPower', sprintf('[%e %d]', P.T0_rating_mva*1e6/2, P.ac_frequency), ...
    'Winding1', sprintf('[%d 0.002 %f]', P.ac_voltage_rms, P.T0_leakage_pu/2), ...
    'Winding2', sprintf('[%d 0.002 %f]', P.Trect_pri_voltage, P.T0_leakage_pu/2), ...
    'Winding1Connection', 'Y', ...     % Wye primary
    'Winding2Connection', 'Yg');       % Grounded Wye secondary (0 deg)

add_block('built-in/Note', [modelName '/Note_T0'], ...
    'Position', [230 140 380 170], ...
    'Text', sprintf('T0: Phase-Shift Transformer (3.5 MVA)\n+/-15 deg for 12-pulse operation'));

%% ========================================================================
%  SECTION 5: RECTIFIER TRANSFORMERS T1 and T2 (1.5 MVA, 2.67:1 step-up)
%  ========================================================================
%  T1 receives the +15 deg shifted voltage, T2 receives -15 deg shifted.
%  Both step up from ~12.5 kV to ~33.3 kV for high-voltage rectification.

% T1: Rectifier transformer (fed from T0a, +15 deg path)
add_block('powerlib/Elements/Three-Phase Transformer (Two Windings)', ...
    [modelName '/T1_Rectifier_Xfmr'], ...
    'Position', [450 180 530 300], ...
    'NominalPower', sprintf('[%e %d]', P.Trect_rating_mva*1e6, P.ac_frequency), ...
    'Winding1', sprintf('[%d 0.003 %f]', P.Trect_pri_voltage, P.Trect_leakage_pu/2), ...
    'Winding2', sprintf('[%d 0.003 %f]', P.Trect_sec_voltage, P.Trect_leakage_pu/2), ...
    'Winding1Connection', 'Y', ...     % Open Wye (floating neutral for star-point)
    'Winding2Connection', 'Y');        % Wye secondary

% T2: Rectifier transformer (fed from T0b, -15 deg path)
add_block('powerlib/Elements/Three-Phase Transformer (Two Windings)', ...
    [modelName '/T2_Rectifier_Xfmr'], ...
    'Position', [450 350 530 470], ...
    'NominalPower', sprintf('[%e %d]', P.Trect_rating_mva*1e6, P.ac_frequency), ...
    'Winding1', sprintf('[%d 0.003 %f]', P.Trect_pri_voltage, P.Trect_leakage_pu/2), ...
    'Winding2', sprintf('[%d 0.003 %f]', P.Trect_sec_voltage, P.Trect_leakage_pu/2), ...
    'Winding1Connection', 'Y', ...
    'Winding2Connection', 'Y');

add_block('built-in/Note', [modelName '/Note_T1T2'], ...
    'Position', [430 140 580 170], ...
    'Text', sprintf('T1/T2: Rectifier Transformers (1.5 MVA each)\nStep-up 2.67:1 to ~33.3 kV'));

%% ========================================================================
%  SECTION 6: 12-PULSE SCR RECTIFIER BRIDGES
%  ========================================================================
%  Two 6-pulse Universal Bridge blocks configured as thyristor bridges.
%  Bridge 1 and Bridge 2 are 30 degrees apart -> 12-pulse operation.
%  Each uses Synchronized 6-Pulse Generator for gate control.

% --- Bridge 1: 6-pulse SCR bridge (from T1, +15 deg path) ---
add_block('powerlib/Power Electronics/Universal Bridge', ...
    [modelName '/Bridge1_SCR'], ...
    'Position', [650 180 730 300], ...
    'Arms', '3', ...
    'Device', 'Thyristors', ...
    'Ron', num2str(P.scr_on_drop * 2), ...  % Two SCRs in series conducting
    'Lon', '0', ...
    'Vf', num2str(P.scr_on_drop * P.scrs_per_stack * 2), ...
    'Rs', num2str(P.scr_snubber_R), ...
    'Cs', num2str(P.scr_snubber_C));

% --- Bridge 2: 6-pulse SCR bridge (from T2, -15 deg path) ---
add_block('powerlib/Power Electronics/Universal Bridge', ...
    [modelName '/Bridge2_SCR'], ...
    'Position', [650 350 730 470], ...
    'Arms', '3', ...
    'Device', 'Thyristors', ...
    'Ron', num2str(P.scr_on_drop * 2), ...
    'Lon', '0', ...
    'Vf', num2str(P.scr_on_drop * P.scrs_per_stack * 2), ...
    'Rs', num2str(P.scr_snubber_R), ...
    'Cs', num2str(P.scr_snubber_C));

% --- Pulse Generators for SCR gate control ---
% Synchronized 6-Pulse Generator for Bridge 1
add_block('powerlib/Extra Sources/Synchronized 6-Pulse Generator', ...
    [modelName '/PulseGen1'], ...
    'Position', [560 100 640 160], ...
    'Frequency', num2str(P.ac_frequency), ...
    'PulseWidth', '60');

% Synchronized 6-Pulse Generator for Bridge 2
add_block('powerlib/Extra Sources/Synchronized 6-Pulse Generator', ...
    [modelName '/PulseGen2'], ...
    'Position', [560 490 640 550], ...
    'Frequency', num2str(P.ac_frequency), ...
    'PulseWidth', '60');

add_block('built-in/Note', [modelName '/Note_Bridges'], ...
    'Position', [620 140 780 170], ...
    'Text', sprintf('12 SCR Stacks (Powerex T8K7)\n2 x 6-pulse bridges -> 12-pulse'));

%% ========================================================================
%  SECTION 7: LC FILTER NETWORK
%  ========================================================================
%  Primary filter inductors (L1, L2), secondary filter capacitors (C),
%  isolation resistors (500 Ohm, PEP-II design), damping network.
%
%  The two bridge DC outputs are connected in series (voltage stacking),
%  then filtered through the LC network.

% Series connection block (sums Bridge 1 + Bridge 2 outputs)
add_block('built-in/Note', [modelName '/Note_Series'], ...
    'Position', [800 260 920 290], ...
    'Text', 'DC Series Connection: V_out = V_B1 + V_B2');

% --- Filter Inductor L1 (0.3 H, 85 A rated, Bridge 1 path) ---
add_block('powerlib/Elements/Series RLC Branch', ...
    [modelName '/L1_Filter_Inductor'], ...
    'Position', [830 180 890 240], ...
    'Resistance', '0.5', ...      % Small winding resistance
    'Inductance', num2str(P.L1), ...
    'Capacitance', 'inf');

% --- Filter Inductor L2 (0.3 H, 85 A rated, Bridge 2 path) ---
add_block('powerlib/Elements/Series RLC Branch', ...
    [modelName '/L2_Filter_Inductor'], ...
    'Position', [830 350 890 410], ...
    'Resistance', '0.5', ...
    'Inductance', num2str(P.L2), ...
    'Capacitance', 'inf');

% --- Filter Capacitor Bank (8 uF with 500 Ohm isolation) ---
% Modeled as parallel RC (capacitor in series with isolation resistor)
add_block('powerlib/Elements/Series RLC Branch', ...
    [modelName '/C_Filter_Bank'], ...
    'Position', [960 250 1020 340], ...
    'Resistance', num2str(P.R_isolation), ...
    'Inductance', '0', ...
    'Capacitance', num2str(P.C_filter));

% --- Damping Resistor ---
add_block('powerlib/Elements/Series RLC Branch', ...
    [modelName '/R_Damping'], ...
    'Position', [960 350 1020 410], ...
    'Resistance', num2str(P.R_damping), ...
    'Inductance', '0', ...
    'Capacitance', 'inf');

add_block('built-in/Note', [modelName '/Note_Filter'], ...
    'Position', [820 140 980 170], ...
    'Text', sprintf('LC Filter: L1=L2=0.3H, C=8uF\nR_iso=500 Ohm (PEP-II), fc~%.0f Hz', P.LC_resonance));

%% ========================================================================
%  SECTION 8: CABLE TERMINATION AND KLYSTRON LOAD
%  ========================================================================

% --- Cable Termination Inductors L3, L4 (200 uH each) ---
add_block('powerlib/Elements/Series RLC Branch', ...
    [modelName '/L3_Cable_Term'], ...
    'Position', [1100 250 1160 310], ...
    'Resistance', '0.1', ...
    'Inductance', num2str(P.L3), ...
    'Capacitance', 'inf');

% --- Klystron Load (resistive model, nominal 3500 Ohm) ---
% Uses constant resistance for basic model.
% For perveance model, replace with MATLAB Function block.
add_block('powerlib/Elements/Series RLC Branch', ...
    [modelName '/Klystron_Load'], ...
    'Position', [1220 250 1280 340], ...
    'Resistance', num2str(P.klystron_R_nom), ...
    'Inductance', '0', ...
    'Capacitance', 'inf');

add_block('built-in/Note', [modelName '/Note_Load'], ...
    'Position', [1100 200 1300 240], ...
    'Text', sprintf('Klystron Load\nR_nom = %d Ohm (-77kV/22A)\nL_cable = 200uH', P.klystron_R_nom));

%% ========================================================================
%  SECTION 9: CROWBAR PROTECTION SYSTEM
%  ========================================================================
%  4 series SCR stacks with fiber-optic trigger (~1 us delay).
%  When triggered, shorts the DC output to dump stored energy.
%  Modeled as a switched resistor across the output.

% --- Crowbar SCR (ideal switch + small resistor) ---
add_block('powerlib/Elements/Breaker', ...
    [modelName '/Crowbar_SCR'], ...
    'Position', [1100 380 1160 440], ...
    'BreakerResistance', num2str(P.crowbar_R_on), ...
    'InitialState', '0', ...       % Initially open (not triggered)
    'SwitchingTimes', '[]');       % Controlled externally

% --- Crowbar Trigger Logic ---
% Step block to simulate crowbar trigger at a specified time
add_block('built-in/Step', [modelName '/Crowbar_Trigger'], ...
    'Position', [1000 400 1040 430], ...
    'Time', num2str(P.sim_time + 1), ... % Default: never trigger (beyond sim time)
    'Before', '0', ...
    'After', '1');

add_block('built-in/Note', [modelName '/Note_Crowbar'], ...
    'Position', [1080 350 1200 370], ...
    'Text', sprintf('Crowbar: 4 SCR stacks\n100kV, 80A, ~1us trigger'));

%% ========================================================================
%  SECTION 10: CONTROL SYSTEM SUBSYSTEM
%  ========================================================================
%  Models the complete control hierarchy:
%    EPICS -> VXI -> PLC (SLC-5/03) -> Regulator Board -> Enerpro -> alpha
%
%  Implemented as a Simulink subsystem with:
%    Input: V_measured (voltage feedback from divider)
%    Input: I_measured (current feedback from Danfysik DC-CT)
%    Output: alpha_deg (firing angle to pulse generators)

% Create Control System subsystem
controlSys = [modelName '/Control_System'];
add_block('built-in/SubSystem', controlSys, ...
    'Position', [500 550 700 700]);

% --- Inside Control Subsystem ---

% Input ports
add_block('built-in/Inport', [controlSys '/V_measured_kV'], ...
    'Position', [30 50 60 65], 'Port', '1');
add_block('built-in/Inport', [controlSys '/I_measured_A'], ...
    'Position', [30 120 60 135], 'Port', '2');

% Output port
add_block('built-in/Outport', [controlSys '/alpha_deg'], ...
    'Position', [800 100 830 115], 'Port', '1');

% --- Voltage Setpoint (EPICS via VXI to PLC N7:30) ---
add_block('built-in/Constant', [controlSys '/V_Setpoint_kV'], ...
    'Position', [30 200 100 230], ...
    'Value', num2str(abs(P.V_nominal)/1e3));  % 77 kV

% --- Soft-Start Ramp ---
% Ramp from 0 to 1 over soft_start_s seconds
add_block('built-in/Ramp', [controlSys '/SoftStart_Ramp'], ...
    'Position', [130 200 190 230], ...
    'Slope', num2str(1/P.reg_soft_start_s), ...
    'StartTime', '0.5', ...           % Start after 0.5s delay
    'InitialOutput', '0');

add_block('built-in/Saturation', [controlSys '/SoftStart_Sat'], ...
    'Position', [220 200 260 230], ...
    'UpperLimit', '1', ...
    'LowerLimit', '0');

% Multiply setpoint by soft-start envelope
add_block('built-in/Product', [controlSys '/SS_Multiply'], ...
    'Position', [300 180 340 230], ...
    'Inputs', '2');

% --- PLC Digital Low-Pass Filter (Rung 104) ---
% tau = -T/ln(1-alpha) ~ 0.020 s
% Implemented as discrete transfer function: H(z) = alpha / (1 - (1-alpha)*z^-1)
add_block('built-in/DiscreteTransferFcn', [controlSys '/PLC_LPF'], ...
    'Position', [370 180 450 230], ...
    'Numerator', num2str(P.plc_filter_alpha), ...
    'Denominator', sprintf('[1 %f]', -(1 - P.plc_filter_alpha)), ...
    'SampleTime', num2str(P.plc_scan_period));

% --- Voltage Error (setpoint - measured) ---
add_block('built-in/Sum', [controlSys '/V_Error'], ...
    'Position', [500 80 530 120], ...
    'Inputs', '+-');

% --- PI Regulator (SD-237-230-14-C1) ---
add_block('simulink/Continuous/PID Controller', [controlSys '/PI_Regulator'], ...
    'Position', [570 75 640 125], ...
    'Controller', 'PI', ...
    'P', num2str(P.reg_Kp), ...
    'I', num2str(P.reg_Ki), ...
    'UpperSaturationLimit', '8', ...   % Max SIG HI contribution
    'LowerSaturationLimit', '0');

% --- Enerpro Voltage-to-Angle Mapping ---
% SIG HI (0.9V to 5.9V) -> alpha (150 deg to 30 deg)
% alpha = 150 - (sig_hi - 0.9) / (5.9 - 0.9) * (150 - 30)
% alpha = 150 - (sig_hi - 0.9) * 24 = 171.6 - 24 * sig_hi
add_block('built-in/Gain', [controlSys '/Enerpro_Gain'], ...
    'Position', [680 80 720 110], ...
    'Gain', num2str(-(P.alpha_max - P.alpha_min) / (P.sighi_max - P.sighi_min)));

add_block('built-in/Bias', [controlSys '/Enerpro_Offset'], ...
    'Position', [740 80 780 110], ...
    'Bias', num2str(P.alpha_max + P.alpha_min * (P.alpha_max - P.alpha_min) / (P.sighi_max - P.sighi_min)));

% --- Enerpro PLL Dynamics (first-order lag) ---
add_block('simulink/Continuous/Transfer Fcn', [controlSys '/Enerpro_PLL'], ...
    'Position', [660 150 740 180], ...
    'Numerator', '1', ...
    'Denominator', sprintf('[%f 1]', P.enerpro_tau));

% --- Firing Angle Saturation ---
add_block('built-in/Saturation', [controlSys '/Alpha_Sat'], ...
    'Position', [760 80 800 115], ...
    'UpperLimit', num2str(P.alpha_max), ...
    'LowerLimit', num2str(P.alpha_min));

% --- Wire up internal connections ---
% Setpoint path: Constant -> Ramp -> Sat -> Multiply -> PLC_LPF
add_line(controlSys, 'V_Setpoint_kV/1', 'SS_Multiply/1');
add_line(controlSys, 'SoftStart_Ramp/1', 'SoftStart_Sat/1');
add_line(controlSys, 'SoftStart_Sat/1', 'SS_Multiply/2');
add_line(controlSys, 'SS_Multiply/1', 'PLC_LPF/1');
% Error: filtered_setpoint - V_measured
add_line(controlSys, 'PLC_LPF/1', 'V_Error/1');
add_line(controlSys, 'V_measured_kV/1', 'V_Error/2');
% PI regulator -> Enerpro mapping -> alpha output
add_line(controlSys, 'V_Error/1', 'PI_Regulator/1');
add_line(controlSys, 'PI_Regulator/1', 'Enerpro_Gain/1');
add_line(controlSys, 'Enerpro_Gain/1', 'Alpha_Sat/1');
add_line(controlSys, 'Alpha_Sat/1', 'alpha_deg/1');

add_block('built-in/Note', [modelName '/Note_Control'], ...
    'Position', [500 520 700 545], ...
    'Text', sprintf('Control: EPICS->PLC->Regulator->Enerpro\nPI: Kp=%.1f, Ki=%.1f, Soft-start=%.0fs', ...
    P.reg_Kp, P.reg_Ki, P.reg_soft_start_s));

%% ========================================================================
%  SECTION 11: MEASUREMENT AND INSTRUMENTATION
%  ========================================================================
%  Models the B118 monitoring channels and EPICS PVs.
%  4 monitoring channels matching the real Waveform Buffer System:
%    Ch1: HVPS DC Voltage (0 to -90 kV)
%    Ch2: HVPS DC Current (0 to 30 A)
%    Ch3: Inductor 2 sawtooth (T2 firing diagnosis)
%    Ch4: Transformer 1 AC current (T1 health)

% --- Voltage Measurement (1000:1 divider) ---
add_block('powerlib/Measurements/Voltage Measurement', ...
    [modelName '/V_Measure_DC'], ...
    'Position', [1320 250 1360 290]);

add_block('built-in/Gain', [modelName '/V_Divider_1000'], ...
    'Position', [1390 255 1420 280], ...
    'Gain', num2str(1/P.V_divider_ratio));

% Convert to kV for display
add_block('built-in/Gain', [modelName '/V_to_kV'], ...
    'Position', [1440 255 1470 280], ...
    'Gain', '1e-3');

% --- Current Measurement (Danfysik DC-CT) ---
add_block('powerlib/Measurements/Current Measurement', ...
    [modelName '/I_Measure_DC'], ...
    'Position', [1200 250 1240 290]);

% --- AC Voltage Measurement (for PLL sync) ---
add_block('powerlib/Measurements/Three-Phase V-I Measurement', ...
    [modelName '/AC_VI_Measure'], ...
    'Position', [170 200 210 280], ...
    'VoltageMeasurement', 'phase-to-ground', ...
    'CurrentMeasurement', 'yes');

% --- Scopes ---
% Output Voltage and Current scope
add_block('built-in/Scope', [modelName '/Scope_Output'], ...
    'Position', [1520 200 1560 260], ...
    'NumInputPorts', '3');

% Control signals scope
add_block('built-in/Scope', [modelName '/Scope_Control'], ...
    'Position', [1520 300 1560 360], ...
    'NumInputPorts', '2');

% --- To Workspace blocks for post-processing ---
add_block('built-in/ToWorkspace', [modelName '/WS_Voltage_kV'], ...
    'Position', [1520 260 1580 280], ...
    'VariableName', 'V_out_kV', ...
    'MaxDataPoints', 'inf', ...
    'SampleTime', '-1');

add_block('built-in/ToWorkspace', [modelName '/WS_Current_A'], ...
    'Position', [1520 370 1580 390], ...
    'VariableName', 'I_out_A', ...
    'MaxDataPoints', 'inf', ...
    'SampleTime', '-1');

add_block('built-in/ToWorkspace', [modelName '/WS_Alpha_deg'], ...
    'Position', [1520 410 1580 430], ...
    'VariableName', 'alpha_deg', ...
    'MaxDataPoints', 'inf', ...
    'SampleTime', '-1');

add_block('built-in/ToWorkspace', [modelName '/WS_Power_MW'], ...
    'Position', [1520 450 1580 470], ...
    'VariableName', 'P_out_MW', ...
    'MaxDataPoints', 'inf', ...
    'SampleTime', '-1');

% --- Power Calculation ---
add_block('built-in/Product', [modelName '/Power_Calc'], ...
    'Position', [1460 320 1500 370], ...
    'Inputs', '2');
add_block('built-in/Gain', [modelName '/Power_to_MW'], ...
    'Position', [1510 330 1540 360], ...
    'Gain', '1e-6');

add_block('built-in/Note', [modelName '/Note_Meas'], ...
    'Position', [1300 200 1500 225], ...
    'Text', sprintf('B118 Monitoring Channels\n1000:1 Voltage Divider, Danfysik DC-CT'));

%% ========================================================================
%  SECTION 12: TOP-LEVEL WIRING (POWER PATH)
%  ========================================================================
%  Connect all blocks in the main power conversion chain:
%  AC Source -> T0a/T0b -> T1/T2 -> Bridge1/Bridge2 -> L1/L2 -> 
%  C_Filter -> L3 -> Klystron_Load

% NOTE: The exact add_line() calls depend on the port naming convention
% of the Specialized Power Systems blocks, which varies by MATLAB version.
% The connections below use the standard port naming.
% If running in a different version, port names may need adjustment.

fprintf('\n--- Wiring Power Path ---\n');

% AC Source -> T0a (primary)
try
    add_line(modelName, 'AC_Source_12kV/1', 'T0a_PhaseShift_Plus15/1');
    add_line(modelName, 'AC_Source_12kV/2', 'T0a_PhaseShift_Plus15/2');
    add_line(modelName, 'AC_Source_12kV/3', 'T0a_PhaseShift_Plus15/3');
catch ME
    fprintf('  Note: AC->T0a wiring may need manual adjustment: %s\n', ME.message);
end

% AC Source -> T0b (primary)
try
    add_line(modelName, 'AC_Source_12kV/1', 'T0b_PhaseShift_Minus15/1');
    add_line(modelName, 'AC_Source_12kV/2', 'T0b_PhaseShift_Minus15/2');
    add_line(modelName, 'AC_Source_12kV/3', 'T0b_PhaseShift_Minus15/3');
catch ME
    fprintf('  Note: AC->T0b wiring may need manual adjustment: %s\n', ME.message);
end

% T0a secondary -> T1 primary
try
    add_line(modelName, 'T0a_PhaseShift_Plus15/4', 'T1_Rectifier_Xfmr/1');
    add_line(modelName, 'T0a_PhaseShift_Plus15/5', 'T1_Rectifier_Xfmr/2');
    add_line(modelName, 'T0a_PhaseShift_Plus15/6', 'T1_Rectifier_Xfmr/3');
catch ME
    fprintf('  Note: T0a->T1 wiring may need manual adjustment: %s\n', ME.message);
end

% T0b secondary -> T2 primary
try
    add_line(modelName, 'T0b_PhaseShift_Minus15/4', 'T2_Rectifier_Xfmr/1');
    add_line(modelName, 'T0b_PhaseShift_Minus15/5', 'T2_Rectifier_Xfmr/2');
    add_line(modelName, 'T0b_PhaseShift_Minus15/6', 'T2_Rectifier_Xfmr/3');
catch ME
    fprintf('  Note: T0b->T2 wiring may need manual adjustment: %s\n', ME.message);
end

% T1 secondary -> Bridge1 (AC inputs)
try
    add_line(modelName, 'T1_Rectifier_Xfmr/4', 'Bridge1_SCR/1');
    add_line(modelName, 'T1_Rectifier_Xfmr/5', 'Bridge1_SCR/2');
    add_line(modelName, 'T1_Rectifier_Xfmr/6', 'Bridge1_SCR/3');
catch ME
    fprintf('  Note: T1->Bridge1 wiring may need manual adjustment: %s\n', ME.message);
end

% T2 secondary -> Bridge2 (AC inputs)
try
    add_line(modelName, 'T2_Rectifier_Xfmr/4', 'Bridge2_SCR/1');
    add_line(modelName, 'T2_Rectifier_Xfmr/5', 'Bridge2_SCR/2');
    add_line(modelName, 'T2_Rectifier_Xfmr/6', 'Bridge2_SCR/3');
catch ME
    fprintf('  Note: T2->Bridge2 wiring may need manual adjustment: %s\n', ME.message);
end

% Pulse generators -> Bridges (gate pulses)
try
    add_line(modelName, 'PulseGen1/1', 'Bridge1_SCR/4');  % Gate port
    add_line(modelName, 'PulseGen2/1', 'Bridge2_SCR/4');  % Gate port
catch ME
    fprintf('  Note: PulseGen->Bridge wiring may need manual adjustment: %s\n', ME.message);
end

% Control System alpha -> Pulse generators
try
    add_line(modelName, 'Control_System/1', 'PulseGen1/2');  % Alpha input
    add_line(modelName, 'Control_System/1', 'PulseGen2/2');  % Alpha input
catch ME
    fprintf('  Note: Control->PulseGen wiring may need manual adjustment: %s\n', ME.message);
end

% Bridge1 DC+ -> L1 -> common bus
% Bridge2 DC+ -> L2 -> common bus
% Common bus -> C_Filter -> L3 -> Klystron_Load -> return
try
    add_line(modelName, 'Bridge1_SCR/LConn1', 'L1_Filter_Inductor/LConn1');
    add_line(modelName, 'Bridge2_SCR/LConn1', 'L2_Filter_Inductor/LConn1');
catch ME
    fprintf('  Note: Bridge->Filter wiring may need manual adjustment: %s\n', ME.message);
end

fprintf('Power path wiring complete (check for manual adjustments needed).\n');

%% ========================================================================
%  SECTION 13: FEEDBACK CONNECTIONS
%  ========================================================================

fprintf('\n--- Wiring Feedback ---\n');

% Voltage feedback: V_Measure -> divider -> to_kV -> Control System input 1
% Current feedback: I_Measure -> Control System input 2
try
    add_line(modelName, 'V_to_kV/1', 'Control_System/1');  % V_measured_kV
    add_line(modelName, 'I_Measure_DC/1', 'Control_System/2');  % I_measured_A
catch ME
    fprintf('  Note: Feedback wiring may need manual adjustment: %s\n', ME.message);
end

% Voltage & Current to scopes and workspace
try
    add_line(modelName, 'V_to_kV/1', 'Scope_Output/1');
    add_line(modelName, 'V_to_kV/1', 'WS_Voltage_kV/1');
    add_line(modelName, 'I_Measure_DC/1', 'Scope_Output/2');
    add_line(modelName, 'I_Measure_DC/1', 'WS_Current_A/1');
    add_line(modelName, 'Control_System/1', 'Scope_Control/1');
    add_line(modelName, 'Control_System/1', 'WS_Alpha_deg/1');
catch ME
    fprintf('  Note: Scope/WS wiring may need manual adjustment: %s\n', ME.message);
end

fprintf('Feedback wiring complete.\n');

%% ========================================================================
%  SECTION 14: MODEL ANNOTATIONS AND DOCUMENTATION
%  ========================================================================

% Title annotation
add_block('built-in/Note', [modelName '/Title'], ...
    'Position', [400 10 900 70], ...
    'FontSize', 14, ...
    'Text', sprintf(['SPEAR3 HVPS Legacy System - Simulink Model\n' ...
    '12-Pulse Thyristor Phase-Controlled Rectifier\n' ...
    '-77 kV DC @ 22 A (1.7 MW) | Building 514 -> 118']));

% Protection layer annotations
add_block('built-in/Note', [modelName '/Note_Protection'], ...
    'Position', [1080 460 1300 540], ...
    'Text', sprintf(['4-Layer Arc Protection:\n' ...
    'L1: Passive (500 Ohm isolation) <40J\n' ...
    'L2: Semi-active (star-point bypass) 4-8ms\n' ...
    'L3: Active (SCR crowbar) <5J, ~1us\n' ...
    'L4: Cable inductors (200uH) limit dI/dt']));

% Key equations annotation
add_block('built-in/Note', [modelName '/Note_Equations'], ...
    'Position', [80 500 450 620], ...
    'Text', sprintf(['Key System Equations:\n' ...
    'V_dc = (6*sqrt(2)/pi) * V_LL * cos(alpha) = 2.70 * V_LL * cos(alpha)\n' ...
    'V_dc_max = %.1f kV (alpha=0)\n' ...
    'V_nominal = %.1f kV (alpha=%.1f deg)\n' ...
    'Ripple: 3.41%% unfiltered -> <0.02%% filtered (720 Hz)\n' ...
    'LC filter: fc=%.1f Hz, attenuation=%.0f dB at 720 Hz\n' ...
    'I_beam = kappa * V^(3/2) (perveance model)'], ...
    P.V_dc_max/1e3, abs(P.V_nominal)/1e3, ...
    acosd(abs(P.V_nominal)/P.V_dc_max), ...
    P.LC_resonance, ...
    20*log10((P.f_ripple/P.LC_resonance)^2)));

% System overview annotation
add_block('built-in/Note', [modelName '/Note_Overview'], ...
    'Position', [80 640 450 750], ...
    'Text', sprintf(['Signal Path:\n' ...
    '12.47kV 3ph -> T0(+/-15deg) -> T1/T2(2.67:1) -> 2x6-pulse SCR ->\n' ...
    'L1+L2(0.3H) -> C(8uF)+R(500ohm) -> L3(200uH) -> Klystron(3.5kohm)\n\n' ...
    'Control Path:\n' ...
    'EPICS -> VXI -> PLC(N7:10,N7:11) -> Regulator(PI) -> Enerpro(PLL) -> alpha']));

%% ========================================================================
%  SECTION 15: SAVE MODEL
%  ========================================================================

% Auto-arrange the model layout
% set_param(modelName, 'ZoomFactor', 'FitSystem');

% Save the model
save_system(modelName);
fprintf('\n=== Model "%s.slx" saved successfully ===\n', modelName);
fprintf('To run: sim(''%s'') or click Run in Simulink\n', modelName);

%% ========================================================================
%  SECTION 16: POST-SIMULATION ANALYSIS SCRIPT
%  ========================================================================
%  Run this section AFTER simulation completes to generate analysis plots.
%  Results are in workspace variables: V_out_kV, I_out_A, alpha_deg, P_out_MW

fprintf('\n=== Post-Simulation Analysis ===\n');
fprintf('After simulation, run the code below to analyze results:\n\n');

disp('% --- Run Simulation ---');
disp('simOut = sim(''SPEAR3_HVPS'');');
disp('');
disp('% --- Extract Results ---');
disp('t = simOut.tout;');
disp('V = simOut.V_out_kV.signals.values;');
disp('I = simOut.I_out_A.signals.values;');
disp('alpha = simOut.alpha_deg.signals.values;');
disp('');

%% ========================================================================
%  SECTION 17: ANALYSIS AND PLOTTING FUNCTIONS
%  ========================================================================
%  These functions can be called after simulation to analyze results.

fprintf('Defining analysis functions...\n');

% --- Function: Plot System Overview ---
function plot_spear3_overview(t, V_kV, I_A, alpha_deg)
    % PLOT_SPEAR3_OVERVIEW Generate 4-panel overview of HVPS operation
    %
    %   plot_spear3_overview(t, V_kV, I_A, alpha_deg)
    %
    %   Matches the Python simulation's plot_system_overview output.
    
    figure('Name', 'SPEAR3 HVPS System Overview', ...
           'Position', [100 100 1200 900]);
    
    % Panel 1: Output Voltage
    subplot(4,1,1);
    plot(t, V_kV, 'b-', 'LineWidth', 1.5);
    hold on;
    yline(-77, 'r--', 'Nominal -77 kV', 'LineWidth', 1);
    xlabel('Time (s)'); ylabel('Voltage (kV)');
    title('HVPS Output Voltage (Ch1: DC Voltage Monitor)');
    grid on; legend('V_{out}', 'Nominal');
    
    % Panel 2: Output Current
    subplot(4,1,2);
    plot(t, I_A, 'Color', [0.8 0.4 0], 'LineWidth', 1.5);
    hold on;
    yline(22, 'r--', 'Nominal 22 A', 'LineWidth', 1);
    xlabel('Time (s)'); ylabel('Current (A)');
    title('HVPS Output Current (Ch2: Danfysik DC-CT)');
    grid on; legend('I_{out}', 'Nominal');
    
    % Panel 3: Firing Angle
    subplot(4,1,3);
    plot(t, alpha_deg, 'Color', [0.2 0.6 0.2], 'LineWidth', 1.5);
    xlabel('Time (s)'); ylabel('\alpha (degrees)');
    title('SCR Firing Angle (Enerpro FCOG1200 output)');
    grid on;
    ylim([0 180]);
    
    % Panel 4: Power
    P_MW = abs(V_kV .* I_A) * 1e-3;  % kV * A = kW, /1000 = MW
    subplot(4,1,4);
    plot(t, P_MW, 'm-', 'LineWidth', 1.5);
    hold on;
    yline(1.7, 'r--', 'Nominal 1.7 MW', 'LineWidth', 1);
    xlabel('Time (s)'); ylabel('Power (MW)');
    title('Output Power');
    grid on; legend('P_{out}', 'Nominal');
    
    sgtitle('SPEAR3 HVPS Legacy System - Simulink Simulation Results', ...
            'FontSize', 14, 'FontWeight', 'bold');
end

% --- Function: Ripple Analysis ---
function analyze_ripple(t, V_kV, t_start)
    % ANALYZE_RIPPLE Compute ripple metrics from steady-state voltage
    %
    %   analyze_ripple(t, V_kV, t_start)
    %   t_start: time (s) after which to consider steady-state
    
    if nargin < 3, t_start = max(t) * 0.5; end
    
    idx = t >= t_start;
    V_ss = V_kV(idx);
    V_mean = mean(abs(V_ss));
    
    ripple_pp = max(V_ss) - min(V_ss);
    ripple_rms = std(V_ss);
    
    fprintf('\n=== Ripple Analysis (t > %.2f s) ===\n', t_start);
    fprintf('  Mean voltage:    %.2f kV\n', V_mean);
    fprintf('  Ripple P-P:      %.3f kV (%.3f%%)\n', ripple_pp, ripple_pp/V_mean*100);
    fprintf('  Ripple RMS:      %.4f kV (%.4f%%)\n', ripple_rms, ripple_rms/V_mean*100);
    fprintf('  Spec P-P:        <1%% -> %s\n', iff(ripple_pp/V_mean*100 < 1, 'PASS', 'FAIL'));
    fprintf('  Spec RMS:        <0.2%% -> %s\n', iff(ripple_rms/V_mean*100 < 0.2, 'PASS', 'FAIL'));
    
    % FFT analysis
    dt = mean(diff(t(idx)));
    Fs = 1/dt;
    N = length(V_ss);
    Y = fft(V_ss - mean(V_ss));
    f = (0:N/2-1) * Fs / N;
    mag = 2 * abs(Y(1:N/2)) / N;
    
    figure('Name', 'SPEAR3 HVPS Ripple Spectrum');
    subplot(2,1,1);
    plot(t(idx), V_ss, 'b-');
    xlabel('Time (s)'); ylabel('Voltage (kV)');
    title('Steady-State Voltage Waveform');
    grid on;
    
    subplot(2,1,2);
    stem(f, mag, 'b-', 'MarkerSize', 3);
    xlim([0 5000]);
    xlabel('Frequency (Hz)'); ylabel('Magnitude (kV)');
    title('Ripple Frequency Spectrum');
    xline(720, 'r--', '720 Hz (12-pulse)', 'LineWidth', 1.5);
    xline(1440, 'g--', '1440 Hz', 'LineWidth', 1);
    grid on;
    
    sgtitle('SPEAR3 HVPS Output Ripple Analysis');
end

% --- Function: Protection Event Analysis ---
function analyze_protection(t, V_kV, I_A, arc_time)
    % ANALYZE_PROTECTION Analyze crowbar/arc protection response
    %
    %   analyze_protection(t, V_kV, I_A, arc_time)
    
    window = 0.05;  % 50 ms window around event
    idx = (t >= arc_time - window) & (t <= arc_time + window);
    
    figure('Name', 'SPEAR3 HVPS Protection Event');
    
    subplot(2,1,1);
    plot(t(idx)*1000, V_kV(idx), 'b-', 'LineWidth', 1.5);
    xlabel('Time (ms)'); ylabel('Voltage (kV)');
    title(sprintf('Voltage During Arc Event at t = %.3f s', arc_time));
    xline(arc_time*1000, 'r--', 'Arc', 'LineWidth', 2);
    grid on;
    
    subplot(2,1,2);
    plot(t(idx)*1000, I_A(idx), 'r-', 'LineWidth', 1.5);
    xlabel('Time (ms)'); ylabel('Current (A)');
    title('Current During Arc Event');
    xline(arc_time*1000, 'r--', 'Arc', 'LineWidth', 2);
    grid on;
    
    % Estimate arc energy (simplified)
    dt = mean(diff(t));
    arc_idx = (t >= arc_time) & (t <= arc_time + 0.001);  % 1 ms window
    E_arc = sum(abs(V_kV(arc_idx)*1e3 .* I_A(arc_idx))) * dt;
    fprintf('\n=== Protection Event Analysis ===\n');
    fprintf('  Arc time:        %.3f s\n', arc_time);
    fprintf('  Est. arc energy: %.1f J (spec: <5 J with crowbar)\n', E_arc);
    
    sgtitle('SPEAR3 HVPS Arc Protection Response');
end

% Helper function
function result = iff(condition, trueVal, falseVal)
    if condition
        result = trueVal;
    else
        result = falseVal;
    end
end

%% ========================================================================
%  SECTION 18: QUICK SIMULATION SCRIPT
%  ========================================================================
%  Uncomment and run this section to execute the simulation directly.

% fprintf('\n=== Running Simulation ===\n');
% simOut = sim(modelName, 'StopTime', num2str(P.sim_time));
% 
% % Extract results
% t = simOut.tout;
% V = simOut.get('V_out_kV');
% I = simOut.get('I_out_A');
% A = simOut.get('alpha_deg');
% 
% % Plot overview
% if ~isempty(V) && ~isempty(I) && ~isempty(A)
%     plot_spear3_overview(t, V.signals.values, I.signals.values, A.signals.values);
%     analyze_ripple(t, V.signals.values, P.sim_time * 0.5);
% else
%     fprintf('Warning: Some signals not captured. Check model wiring.\n');
% end
% 
% fprintf('\n=== Simulation Complete ===\n');

fprintf('\n');
fprintf('========================================================\n');
fprintf(' SPEAR3 HVPS Simulink Model Built Successfully!\n');
fprintf('========================================================\n');
fprintf(' Model: %s.slx\n', modelName);
fprintf(' Blocks: AC Source, T0 Phase-Shift, T1/T2 Rectifier,\n');
fprintf('         2x 6-Pulse SCR Bridges, LC Filter, Klystron Load,\n');
fprintf('         Control System (PLC+PI+Enerpro), Crowbar Protection\n');
fprintf(' Solver: %s, dt_max = %.0f us, t_stop = %.1f s\n', ...
    P.sim_solver, P.sim_dt_max*1e6, P.sim_time);
fprintf('========================================================\n');
fprintf('\n');
fprintf('Next steps:\n');
fprintf('  1. Open model: open_system(''%s'')\n', modelName);
fprintf('  2. Verify/adjust wiring (power ports may need manual connection)\n');
fprintf('  3. Run simulation: sim(''%s'')\n', modelName);
fprintf('  4. Analyze: plot_spear3_overview(t, V, I, alpha)\n');
fprintf('  5. For arc fault test: set Crowbar_Trigger step time < sim_time\n');
fprintf('\n');
