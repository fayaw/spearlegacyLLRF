function plot_TFC2(hObject, eventdata, handles);

% measure_tf.m  - plots the transfer function of all the station
%                 cavities measured through the RF module with
%                 or without the RF feedback loops on - Paul 12/26/97
%
% Modified by Dmitry Teytelman on 7/9/2001 to be used interactively
%
% 01-19-2007 W. Colocho function to compile measure_tfC2.m 
% Original by Paul and then Dmitry
%
% This function does the following:
% measure_tfC2
% posttf
% setup_tf
% pltf
% fit_all
% cmpprm 
%
% 2008-jul-29  jjs
%  use NOISE_I_BL_SMALL, etc., for excitation signals

station = upper(handles.station);

% Determine the noise gain in the RFP
noise_gain = get_RFP_noise_gain(station); %Use version compatible
                                          %with SPEAR

rf_data  = handles.rfData;
rf_module    = [station,':STN:RFP'];
handles.rfModule = rf_module; % Needed to pass rf_module to save_RFP_mux
noise_I_file = '/NOISE_I_BL_SMALL'; % file to load into I DAC
noise_Q_file = '/NOISE_Q_BL_SMALL'; % file to load into Q DAC
% previously measured noise files
measured_I_noise = '/NOISE_I_BL_SMALL.out';  
measured_Q_noise = '/NOISE_Q_BL_SMALL.out'; 
% noise_I_file = '/NOISE_I_BL'; % file to load into I DAC
% noise_Q_file = '/NOISE_Q_BL'; % file to load into Q DAC
% % previously measured noise files
% measured_I_noise = '/NOISE_I_BL.out';  
% measured_Q_noise = '/NOISE_Q_BL.out'; 
% define the measured loop response file names
% v_header is the directory path as seen from the ioc
v_header = '/dat';
% u_header is the directory path as seen from the matlab application
u_header = fullfile(rf_data, station);   % string for the unix stuff
measured_direct_I = '/DIRECT_I_CLOSED'; 
measured_direct_Q = '/DIRECT_Q_CLOSED';

% some config values
max_count = 20;			% maximum number of tries to write data files
Tsample = handles.Tsample;      % sampling interval from handles
fs = 1/Tsample; %72*476e6/3492;  % clock frequency
Tsample = 1/fs;			% sampling interval
f_rf = handles.rfFrequency; %476e6;	% rf frequency - Hz
w_rf = f_rf*2*pi;		% rfum frequency - radians/sec
num_data = 2^19;		% set the desired length of the data files
maxSampFft = 2^13 + 2^9;
num_fft = floor(maxSampFft/handles.samplesPerRev)*handles.samplesPerRev;
freq_span = 1.2e6;

% make sure the RF is on - remove carrige return
fprintf(1,'\nConfiguring RF system - please be patient\n');
try
    answer = char(lcaGet([rf_module,':RFENABLE']));
catch
   fprintf(1,'Error - unable to read RF on/off status\n');
   return
end
if strcmp(answer(1:2),'ON') ~= 1
   fprintf(1,'Error - RF must be on\n');
   return
end

% remember the state of the muxes for fast fault data
% muxData = saverfpmux(rf_module);
pvNamesMux = {
    [rf_module, ':FBSIG'];
    [rf_module, ':CAVSEL'];
    [rf_module, ':DINJ']
    };
pvDataMux = lcaGet(pvNamesMux,0,'int');

% make sure the direct loop is on
try
    answer = char(lcaGet([station,':STNDIRECT:LOOP:CTRL']));
catch
   fprintf(1,'Error - unable to read direct loop on/off status\n');
   return
end

% write the desired length of the data files to the RF module driver
try
    lcaPut([rf_module,':MODU.RMSZ'], num_data/1024);
catch
   fprintf(1,'Error - can not set the desired file length\n');
   return
end

% place module in operate mode
try
    lcaPut([rf_module,':RUNMODE'], 1);
catch
   fprintf(1,'Error - can not place RF module into operate mode\n');
   return
end

loadrfstates( rf_module );

% increase the time allowed for some of these operations
currRetryCount = lcaGetRetryCount;
lcaSetRetryCount( 800 );

% see what files are in the DACs - load correct files if necessary
% first do the I DACs
try
    answer = char(lcaGet([rf_module,':MODU.DIRF']));
catch
   fprintf(1,'Error - unable to read DAC_I filename\n');
   return
end
% for portability, do not use fullfile here since a pc will write a pc
% compatible name and not a unix compatible name to the ioc
if strcmp(answer,[v_header, noise_I_file]) ~= 1
    fprintf(1,'loading correct DAC_I file to module RAM\n');
    try
        lcaPut([rf_module,':MODU.DIRF'], [v_header, noise_I_file]);
    catch
        fprintf(1,'Error - can not write the DAC_I filename\n');
        return
    end
    try
        lcaPut([rf_module,':MODU.LDIR'], 1);
    catch
        fprintf(1,'Error - can not load the DAC_I file\n');
        return
    end
    test = 0;	% force the first pass in the while loop
    count = 0;	% count how many times we look at the status mesasage
    pause(2);	% wait 2 seconds to allow things to start
    while test ~= 1,
        answer = char(lcaGet([rf_module,':MODU.DIST']));
        count = count +1;
        test = strcmp(answer(1),'N');
        if count > max_count
            fprintf(1,'Error - can not load the DAC_I file - timed out\n');
            return
        end
        if test ~= 1, pause(1), end;	% sleep for 1 seconds
    end; % end of the while loop
end

% next do the Q DACs
try
    answer = char(lcaGet([rf_module,':MODU.DQRF']));
catch
    fprintf(1,'Error - unable to read DAC_Q filename\n');
    return
end
if strcmp(answer,[v_header, noise_Q_file]) ~= 1
    fprintf(1,'loading correct DAC_Q file to module RAM\n') ;
    try
        lcaPut([rf_module,':MODU.DQRF'], [v_header, noise_Q_file]);
    catch
        fprintf(1,'Error - can not write the DAC_Q filename\n');
        return
    end
    try
        lcaPut([rf_module,':MODU.LDQR'], 1);
    catch
        fprintf(1,'Error - can not load the DAC_Q file\n') ;
        return
    end
    test = 0;	% force the first pass in the while loop
    count = 0;	% count how many times we look at the status mesasage
    pause(2);	% wait 2 seconds to allow things to start
    while test ~= 1,
        answer = char(lcaGet([rf_module,':MODU.DQST']));
        count = count + 1;
        test = strcmp(answer(1),'N');
        if count > max_count
            fprintf(1,'Error - can not load the DAC_Q file - timed out\n') ;
            return
        end
        if test ~= 1, pause(1), end;	% sleep for 1 seconds
    end; % end of the while loop
end

% write the correct file names to save data
try
    lcaPut([rf_module,':MODU.SIRF'], ...
        [v_header, measured_direct_I]);
catch
    fprintf(1,'Error - unable to write SIG_I filename\n');
    return
end
try
    lcaPut([rf_module,':MODU.SQRF'], ...
        [v_header, measured_direct_Q]);
catch
    fprintf(1,'Error - unable to write SIG_Q filename\n');
    return
end
% reset timeout values
lcaSetRetryCount( currRetryCount );

% place the module in single shot mode
try
    lcaPut([rf_module,':SSCONT'], 'Single Shot');
catch
    fprintf(1,'Error - can not place the module in Single Shot mode\n');
    return
end

% enable the DACs
try
    lcaPut([rf_module,':DACS'], 1);
catch
    fprintf(1,'Error - can not enable the DACs\n');
    return
end

% set SIGNAL multiplexer to TOTAL
try
    lcaPut([rf_module,':FBSIG'], 0);
catch
    fprintf(1,'Error - can not set the feedback signal to TOTAL\n');
    return
end

cyclerfstates( rf_module );

% Now get all the dynamics channels as close to the single shot as possible
fprintf(1, 'Reading station parameters\n');
% check for existence of comb module
try
    combSevr = lcaGet([station, ':STN:CF2:MODU.SEVR'], 0, 'int');
catch
    fprintf(1,'error recorded in reading of %s\n', ...
        [station, ':STN:CF2:MODU.SEVR']);
end
% 3 == 'INVALID', which holds if the comb module is not installed
combPresent = (combSevr ~= 3);

if combPresent,
    fprintf(1,'comb module present\n');
    pvNames = {
        [station, ':STNDIRECT:LOOP:PHASE']
        [station, ':STNDIRECT:LOOP:PHASE.K']
        [station, ':STNDIRECT:LOOP:COUNTS']
        [station, ':CAV:FREQ:OFFS']
        [station, ':KLYSOUTFRWD:POWER']
        [station, ':HVPS:VOLT']
        [station, ':STNCOMB:LOOP:COUNTS']
        [station, ':STNCOMB:LOOP:PHASE']
        [station, ':STNCOMB:LOOP:PHASE.K']
        [station, ':STN:CF2:MODU.FIFO']
        };
    try
        pvData = lcaGet( pvNames );
    catch
        fprintf(1, 'Error - unable to read station values\n');
        return
    end
    dph = pvData(1);
    dph_off = pvData(2);
    dgn = pvData(3);
    detune = pvData(4);
    fwd = pvData(5);
    hvps = pvData(6);
    cgn = pvData(7);
    cph = pvData(8);
    cph_off = pvData(9);
    cdel = pvData(10);
else
    fprintf(1,'no comb module present\n');
    pvNames = {
        [station, ':STNDIRECT:LOOP:PHASE']
        [station, ':STNDIRECT:LOOP:PHASE.K']
        [station, ':STNDIRECT:LOOP:COUNTS']
        [station, ':CAV:FREQ:OFFS']
        [station, ':KLYSOUTFRWD:POWER']
        [station, ':HVPS:VOLT']
        };
    try
        pvData = lcaGet( pvNames );
    catch
        fprintf(1, 'Error - unable to read station values\n');
        return
    end
    dph = pvData(1);
    dph_off = pvData(2);
    dgn = pvData(3);
    detune = pvData(4);
    fwd = pvData(5);
    hvps = pvData(6);
end % if combPresent,

% read in RFP settings and DAC setpoints
pvNamesRfp = {
    [rf_module, ':RFENABLE']   % RF off/on
    [rf_module, ':RUNMODE']    % RF Mode
    [rf_module, ':DIRECTLOOP'] % RF Direct Loop
    [rf_module, ':COMBLOOP']   % RF Comb Loop
    [rf_module, ':RIPPLELOOP'] % RF DSP Ripple Loop
    [rf_module, ':STATE']      % RF State
    [rf_module, ':LEADCOMP']   % RF Lead Comp
    [rf_module, ':INTCOMP']    % RF Integral Comp
    [rf_module, ':ARIPPLELOOP']% RF Analog Ripple Loop
    [rf_module, ':CAV1.A']     % DAC Combiner    Value  II Cavity 1
    [rf_module, ':CAV1.B']     % DAC Combiner    Offset II Cavity 1
    [rf_module, ':CAV1.C']     % DAC Combiner    Value  IQ Cavity 1
    [rf_module, ':CAV1.D']     % DAC Combiner    Offset IQ Cavity 1
    [rf_module, ':CAV1.E']     % DAC Combiner    Value  QI Cavity 1
    [rf_module, ':CAV1.F']     % DAC Combiner    Offset QI Cavity 1
    [rf_module, ':CAV1.G']     % DAC Combiner    Value  QQ Cavity 1
    [rf_module, ':CAV1.H']     % DAC Combiner    Offset QQ Cavity 1
    [rf_module, ':CAV2.A']     % DAC Combiner    Value  II Cavity 2
    [rf_module, ':CAV2.B']     % DAC Combiner    Offset II Cavity 2
    [rf_module, ':CAV2.C']     % DAC Combiner    Value  IQ Cavity 2
    [rf_module, ':CAV2.D']     % DAC Combiner    Offset IQ Cavity 2
    [rf_module, ':CAV2.E']     % DAC Combiner    Value  QI Cavity 2
    [rf_module, ':CAV2.F']     % DAC Combiner    Offset QI Cavity 2
    [rf_module, ':CAV2.G']     % DAC Combiner    Value  QQ Cavity 2
    [rf_module, ':CAV2.H']     % DAC Combiner    Offset QQ Cavity 2
    [rf_module, ':CAV3.A']     % DAC Combiner    Value  II Cavity 3
    [rf_module, ':CAV3.B']     % DAC Combiner    Offset II Cavity 3
    [rf_module, ':CAV3.C']     % DAC Combiner    Value  IQ Cavity 3
    [rf_module, ':CAV3.D']     % DAC Combiner    Offset IQ Cavity 3
    [rf_module, ':CAV3.E']     % DAC Combiner    Value  QI Cavity 3
    [rf_module, ':CAV3.F']     % DAC Combiner    Offset QI Cavity 3
    [rf_module, ':CAV3.G']     % DAC Combiner    Value  QQ Cavity 3
    [rf_module, ':CAV3.H']     % DAC Combiner    Offset QQ Cavity 3
    [rf_module, ':CAV4.A']     % DAC Combiner    Value  II Cavity 4
    [rf_module, ':CAV4.B']     % DAC Combiner    Offset II Cavity 4
    [rf_module, ':CAV4.C']     % DAC Combiner    Value  IQ Cavity 4
    [rf_module, ':CAV4.D']     % DAC Combiner    Offset IQ Cavity 4
    [rf_module, ':CAV4.E']     % DAC Combiner    Value  QI Cavity 4
    [rf_module, ':CAV4.F']     % DAC Combiner    Offset QI Cavity 4
    [rf_module, ':CAV4.G']     % DAC Combiner    Value  QQ Cavity 4
    [rf_module, ':CAV4.H']     % DAC Combiner    Offset QQ Cavity 4
    [rf_module, ':DIRECT.A']   % DAC Direct Loop Value  II
    [rf_module, ':DIRECT.B']   % DAC Direct Loop Offset II
    [rf_module, ':DIRECT.C']   % DAC Direct Loop Value  IQ
    [rf_module, ':DIRECT.D']   % DAC Direct Loop Offset IQ
    [rf_module, ':DIRECT.E']   % DAC Direct Loop Value  QI
    [rf_module, ':DIRECT.F']   % DAC Direct Loop Offset QI
    [rf_module, ':DIRECT.G']   % DAC Direct Loop Value  QQ
    [rf_module, ':DIRECT.H']   % DAC Direct Loop Offset QQ
    [rf_module, ':COMB.A']     % DAC Comb   Loop Value  II
    [rf_module, ':COMB.B']     % DAC Comb   Loop Offset II
    [rf_module, ':COMB.C']     % DAC Comb   Loop Value  IQ
    [rf_module, ':COMB.D']     % DAC Comb   Loop Offset IQ
    [rf_module, ':COMB.E']     % DAC Comb   Loop Value  QI
    [rf_module, ':COMB.F']     % DAC Comb   Loop Offset QI
    [rf_module, ':COMB.G']     % DAC Comb   Loop Value  QQ
    [rf_module, ':COMB.H']     % DAC Comb   Loop Offset QQ
    [rf_module, ':MODU.CO1I']  % DAC Combiner Output Offset I Cavity 1
    [rf_module, ':MODU.CO1Q']  % DAC Combiner Output Offset Q Cavity 1
    [rf_module, ':MODU.CO2I']  % DAC Combiner Output Offset I Cavity 2
    [rf_module, ':MODU.CO2Q']  % DAC Combiner Output Offset Q Cavity 2
    [rf_module, ':MODU.CO3I']  % DAC Combiner Output Offset I Cavity 3
    [rf_module, ':MODU.CO3Q']  % DAC Combiner Output Offset Q Cavity 3
    [rf_module, ':MODU.CO4I']  % DAC Combiner Output Offset I Cavity 4
    [rf_module, ':MODU.CO4Q']  % DAC Combiner Output Offset Q Cavity 4
    [rf_module, ':MODU.GO1I']  % DAC Gain     Output Offset I Cavity 1
    [rf_module, ':MODU.GO1Q']  % DAC Gain     Output Offset Q Cavity 1
    [rf_module, ':MODU.GO2I']  % DAC Gain     Output Offset I Cavity 2
    [rf_module, ':MODU.GO2Q']  % DAC Gain     Output Offset Q Cavity 2
    [rf_module, ':MODU.GO3I']  % DAC Gain     Output Offset I Cavity 3
    [rf_module, ':MODU.GO3Q']  % DAC Gain     Output Offset Q Cavity 3
    [rf_module, ':MODU.GO4I']  % DAC Gain     Output Offset I Cavity 4
    [rf_module, ':MODU.GO4Q']  % DAC Gain     Output Offset Q Cavity 4
    [rf_module, ':TUNE.A']     % DAC Tune Mode      Value  I
    [rf_module, ':TUNE.B']     % DAC Tune Mode      Offset I
    [rf_module, ':TUNE.C']     % DAC Tune Mode      Value  Q
    [rf_module, ':TUNE.D']     % DAC Tune Mode      Offset Q
    [rf_module, ':MODU.DNIO']  % DAC Difference     Offset I
    [rf_module, ':MODU.DNQO']  % DAC Difference     Offset Q
    [rf_module, ':MODU.KLIO']  % DAC Klystron Mod   Offset I
    [rf_module, ':MODU.KLQO']  % DAC Klystron Mod   Offset Q
    [rf_module, ':MODU.RFIO']  % DAC RF Mod         Offset I
    [rf_module, ':MODU.RFQO']  % DAC RF Mod         Offset Q
    [rf_module, ':MODU.CSIO']  % DAC Comp Stage     Offset I
    [rf_module, ':MODU.CSQO']  % DAC Comp Stage     Offset Q
    [rf_module, ':MODU.DLIO']  % DAC Dir Loop Ctrl  Offset I
    [rf_module, ':MODU.DLQO']  % DAC Dir Loop Ctrl  Offset Q
    [rf_module, ':MODU.CLIO']  % DAC Comb Loop      Offset I
    [rf_module, ':MODU.CLQO']  % DAC Comb Loop      Offset Q
    [rf_module, ':MODU.SNIO']  % DAC Summing Node   Offset I
    [rf_module, ':MODU.SNIO']  % DAC Summing Node   Offset Q
    [rf_module, ':MODU.KLOI']  % DAC Klystron Demod Offset I
    [rf_module, ':MODU.KLOQ']  % DAC Klystron Demod Offset Q
    [rf_module, ':MODU.KMII']  % DAC Klystron Mod DAC Offset II
    [rf_module, ':MODU.KMIQ']  % DAC Klystron Mod DAC Offset IQ
    [rf_module, ':MODU.KMQI']  % DAC Klystron Mod DAC Offset QI
    [rf_module, ':MODU.KMQQ']  % DAC Klystron Mod DAC Offset QQ
    [rf_module, ':RLCOEF.A']   % DAC Analog Ripple Loop Value  II_QQ
    [rf_module, ':RLCOEF.B']   % DAC Analog Ripple Loop Offset II_QQ
    [rf_module, ':RLCOEF.C']   % DAC Analog Ripple Loop Value  IQ_QI
    [rf_module, ':RLCOEF.D']   % DAC Analog Ripple Loop Offset IQ_QI
    [rf_module, ':IREF.A']     % DAC Internal Reference Value  I
    [rf_module, ':IREF.B']     % DAC Internal Reference Offset I
    [rf_module, ':IREF.C']     % DAC Internal Reference Value  Q
    [rf_module, ':IREF.D']     % DAC Internal Reference Offset Q
    [rf_module, ':MODU.MDRV']  % DAC Maximum Drive
    };
pvValuesRfp = lcaGet( pvNamesRfp, 0, 'double' );

% read the beam current
% jjs  put this in parameter files
switch station(1)
    case 'H'
        currPv = 'HB60:DCCT:SUMY';
    case 'L'
        currPv = 'LB60:DCCT:SUMY';
    case 'S'
        currPv = 'SRF1:STN:BEAM:CURR';
    otherwise
        error(['unknown station ', station]);
end
try
    beamCurrent = lcaGet( currPv );
catch
    fprintf(1,'Error - unable to read beam current\n');
    return
end
fprintf(1, 'Done reading station parameters\n');

% get the data files
% this process can take some time, so increase lca retry count
currRetryCount = lcaGetRetryCount;
lcaSetRetryCount( 800 );
% read the SIGNAL_I file first
try
    lcaPut([rf_module,':MODU.GSIR'], 1);
catch
    fprintf(1,'Error - can not activate the SIGNAL_I file read\n');
    return
end
fprintf(1,'Moving data from I channel to file\n');
test = 0;	% force the first pass in the while loop
count = 0;	% count how many times we look at the status mesasage
pause(2);	% wait 2 seconds to allow things to start
while test ~= 1,
    answer = char(lcaGet([rf_module,':MODU.SIST']));
    count = count +1;
    test = strcmp(answer(1),'N');
    if count > max_count
        fprintf(1,'Error - can not read the SIGNAL_I file - timed out\n');
        return
    end
    if test ~= 1, pause(1), end;	% sleep for 1 second
end; % end of the while loop

% read the SIGNAL_Q file now
try
    lcaPut([rf_module,':MODU.GSQR'], 1);
catch
    fprintf(1,'Error - can not activate the SIGNAL_Q file read\n');
    return
end
fprintf(1,'Moving data from Q channel to file\n');
test = 0;	% force the first pass in the while loop
count = 0;	% count how many times we look at the status mesasage
pause(2);	% wait 2 seconds to allow things to start
while test ~= 1,
    answer = char(lcaGet([rf_module,':MODU.SQST']));
    count = count +1;
    test = strcmp(answer(1),'N');
    if count > max_count
        fprintf(1,'Error - can not read the SIGNAL_Q file - timed out\n');
        return
    end
    if test ~= 1, pause(1), end;	% sleep for 1 second
end; % end of the while loop

% restorerfpmux(rf_module, muxData);
lcaPut(pvNamesMux, pvDataMux);
lcaPut({[rf_module, ':DACS']; [rf_module, ':SSCONT']}, [0;1]);
% reset, load, run
for ind = 0:2,
    lcaPut([rf_module, ':STATE'], ind);
    % force a wait to insure module goes through this state
    pause(0.1);
end % for ind = 0:2,

% restore lca retry count
lcaSetRetryCount( currRetryCount );

% make the file ID's
fid1 = -1;
fid2 = -1;
while (fid1 == -1),
    fid1 = fopen(fullfile(u_header,measured_direct_I),'r','ieee-be');
end;
while (fid2 == -1),
    fid2 = fopen(fullfile(u_header,measured_direct_Q),'r','ieee-be');
end;
fid3 = -1;
fid4 = -1;
while (fid3 == -1),
    fid3 = fopen(fullfile(u_header,measured_I_noise),'r','ieee-be');
end;
while (fid4 == -1),
    fid4 = fopen(fullfile(u_header,measured_Q_noise),'r','ieee-be');
end;

% read the recorded noise files
fprintf(1,'Reading data files\n');
[header,count] = fread(fid3,[1,16],'char');
fprintf(1,'Reading %s\n',fullfile(u_header,measured_I_noise));
[i_dat,count] = fread(fid3,[1,num_data],'short'); fclose(fid3);
header = char(header);
if count ~= (num_data)
    fprintf(1, 'length of file in %s is incorrect. Length = %d\n', ...
        header, count)
   return
end
[header,count] = fread(fid4,[1,16],'char');
fprintf(1,'Reading %s\n',fullfile(u_header,measured_Q_noise));
[q_dat,count] = fread(fid4,[1,num_data],'short'); fclose(fid4);
header = char(header);
if count ~= (num_data)
    fprintf(1, 'length of file in %s is incorrect. Length = %d\n', ...
        header, count)
   return
end

in_data_I = int16(i_dat);
in_data_Q = int16(q_dat);
clear('i_dat', 'q_dat');

% read the measured data files
[header,count] = fread(fid1,[1,16],'char');
fprintf(1,'Reading %s\n',fullfile(u_header,measured_direct_I));
[i_dat,count] = fread(fid1,[1,inf],'short'); fclose(fid1);
header = char(header);
if count ~= (num_data)
    fprintf(1, 'length of file in %s is incorrect. Length = %d\n', ...
        header, count)
   return
end
[header,count] = fread(fid2,[1,16],'char');
fprintf(1,'Reading %s\n',fullfile(u_header,measured_direct_Q));
[q_dat,count] = fread(fid2,[1,inf],'short'); fclose(fid2);
header = char(header);
if count ~= (num_data)
    fprintf(1, 'length of file in %s is incorrect. Length = %d\n', ...
        header, count)
   return
end


out_data_I = int16(i_dat);
out_data_Q = int16(q_dat);
clear('i_dat', 'q_dat');
s_title=['Measured transfer function - ',...
        station,'  ',datestr(now,0), ' Io = ', num2str(beamCurrent), ' mA'];

% This section unfolds input and output data vectors from
% separate int16 I and Q

in_data = fliplr(itof(in_data_I, in_data_Q))/noise_gain;
out_data = fliplr(itof(out_data_I, out_data_Q));
out_data = out_data-mean(out_data);
clear( 'in_data_I', 'in_data_Q', 'out_data_I', 'out_data_Q' );

% This section prepares closed-loop transfer function for
% model extraction. Revolution harmonics are removed and
% transfer function is recomputed

out_data=remrev(out_data, Tsample,f_rf/handles.h);
in_data=in_data(1:length(out_data));

% This section uses in_data and out_data vectors
% to compute and plot closed-loop transfer function

% Select the fitting span
switch station(1)
    case {'H', 'L'}
        fspanL=1000e3;
        fspanU=1000e3;
        fExclude = 1e4;
    case 'S'
        fspanL = 500e3;
        fspanU = 250e3;
        fExclude = 1.5e4;
end

[Hsum,FF]=tfestimate(in_data,out_data,hanning(num_fft),[],num_fft,fs);
Hsum(1) = Hsum(2);      % ignore the DC term - usually has large errors
Hsum=Hsum';
% reorder the results to go from -freq to + freq
u = find(FF>fs/2);
FF(u) = FF(u) - fs;
Hsum = fftshift(Hsum);
baseband_freq = fftshift(FF).';

u1 = find(baseband_freq>fExclude & baseband_freq < freq_span);
u2 = find(baseband_freq<-fExclude & baseband_freq > -freq_span);
u3 = find((-fExclude <= baseband_freq) & (baseband_freq >= fExclude));
% Reconstruct open-loop TF
freq = [baseband_freq(u1) NaN*size(u3) baseband_freq(u2)]/1e3;
H1 = [Hsum(u1) NaN*size(u3) Hsum(u2)];
magnitude = 20*log10(abs(H1));
phases = angle(H1);

% increment to the next figure
figHandles = handles.figHandles;
figInd=length(figHandles);
figInd=figInd+1; figure(figInd); clf; figHandles(figInd) = figInd;
handles.figHandles = figHandles;
guidata(handles.output, handles); % update  handles data
figOne = figInd;

subplot(211);
plot(freq, magnitude, 'r');
ysc = get(gca, 'ylim');
if (ysc(1) < -25), ysc(1) = -25; end
if (ysc(2) > 30), ysc(2) = 30; end
set(gca, 'ylim', ysc);
grid on
title(s_title);
ylabel('Gain (dB)');

subplot(212)
plot(freq, (180/pi)*phases, 'r');
grid on
xlabel('Frequency (kHz)');
ylabel('Phase (degrees)');
zoom on

% This section fits direct & comb model to a closed-loop transfer function 
% measured to the TOTAL signal.

v = find( ((-fspanL < baseband_freq) & (baseband_freq < -fExclude)) ...
    | ((fExclude < baseband_freq) & (baseband_freq < fspanU)) );
frfit = baseband_freq(v)/1e3;

% scale coefficients for direct loop variables
scale = [1e7 1 10 1e-6 10]; 
scaleDir = scale;
% scale coefficients for comb loop variables
scale1 = [1 1e-5 1];
% define prm structure for fitting
clear('prm');
prm = struct( ...
    'wrf', w_rf, ...                        % rf frequency in rad/s
    'Ql', handles.cavityQ/(1+handles.cavityBeta), ... % loaded Q of the cavity
    'H', Hsum(v), ...                       % Closed-loop TF to TOTAL, all loops closed
    'w', 2*pi*baseband_freq(v) + w_rf, ...  % frequency vector
    'T0', 2*pi*handles.h/w_rf, ...          % revolution period
    'f_comb', handles.samplesPerRev*(w_rf/(2*pi*handles.h)), ... % sampling frequency
    'Weight', ones(size(v)), ...            % weighting vector
    'detune', detune, ...                   % detuning factor
    'scale', scale, ...                     % scaling factor for variables (1 added for Ql)
    'scale1', scale1, ...                   % additional scaling factor for variables
    'combPresent', combPresent, ...         % flag to check for presence of comb module
    'num', [], ...                          % comb filter numerator
    'den', [], ...                          % comb filter denominator
    'Beq', 0, ...                           % comb equalizer coefficient
    'dirmodel', ones(size(scale)), ...      % direct model coefficients
    'dirstd', ones(size(scale)), ...        % deviation coefficients for direct model
    'cmbmodel', ones(size(scale1)), ...     % comb model coefficients
    'cmbstd', ones(size(scale1)), ...       % deviation coefficients for comb model
    'Io', beamCurrent, ...                  % beam current
    'station', station, ...                 % rf station
    'dph', dph, ...                         % direct loop phase
    'dph_off', dph_off, ...                 % direct loop phase offset
    'dgn', dgn, ...                         % direct loop gain
    'cph', 0, ...                           % comb loop phase
    'cph_off', 0, ...                       % comb loop phase offset
    'cgn', 0, ...                           % comb loop gain
    'fwd', fwd, ...                         % forward power
    'hvps', hvps, ...                       % hvps voltage
    'rfEnable', pvValuesRfp(1), ...   % RF off/on
    'runMode', pvValuesRfp(2), ...    % RF Mode
    'directLoop', pvValuesRfp(3), ... % RF Direct Loop
    'combLoop', pvValuesRfp(4), ...   % RF Comb Loop
    'rippleLoop', pvValuesRfp(5), ... % RF DSP Ripple Loop
    'state', pvValuesRfp(6), ...      % RF State
    'leadComp', pvValuesRfp(7), ...   % RF Lead Comp
    'intComp', pvValuesRfp(8), ...    % RF Integral Comp
    'aRippleLoop', pvValuesRfp(9), ...% RF Analog Ripple Loop
    'cav1A', pvValuesRfp(10), ...     % DAC Combiner    Value  II Cavity 1
    'cav1B', pvValuesRfp(11), ...     % DAC Combiner    Offset II Cavity 1
    'cav1C', pvValuesRfp(12), ...     % DAC Combiner    Value  IQ Cavity 1
    'cav1D', pvValuesRfp(13), ...     % DAC Combiner    Offset IQ Cavity 1
    'cav1E', pvValuesRfp(14), ...     % DAC Combiner    Value  QI Cavity 1
    'cav1F', pvValuesRfp(15), ...     % DAC Combiner    Offset QI Cavity 1
    'cav1G', pvValuesRfp(16), ...     % DAC Combiner    Value  QQ Cavity 1
    'cav1H', pvValuesRfp(17), ...     % DAC Combiner    Offset QQ Cavity 1
    'cav2A', pvValuesRfp(18), ...     % DAC Combiner    Value  II Cavity 2
    'cav2B', pvValuesRfp(19), ...     % DAC Combiner    Offset II Cavity 2
    'cav2C', pvValuesRfp(20), ...     % DAC Combiner    Value  IQ Cavity 2
    'cav2D', pvValuesRfp(21), ...     % DAC Combiner    Offset IQ Cavity 2
    'cav2E', pvValuesRfp(22), ...     % DAC Combiner    Value  QI Cavity 2
    'cav2F', pvValuesRfp(23), ...     % DAC Combiner    Offset QI Cavity 2
    'cav2G', pvValuesRfp(24), ...     % DAC Combiner    Value  QQ Cavity 2
    'cav2H', pvValuesRfp(25), ...     % DAC Combiner    Offset QQ Cavity 2
    'cav3A', pvValuesRfp(26), ...     % DAC Combiner    Value  II Cavity 3
    'cav3B', pvValuesRfp(27), ...     % DAC Combiner    Offset II Cavity 3
    'cav3C', pvValuesRfp(28), ...     % DAC Combiner    Value  IQ Cavity 3
    'cav3D', pvValuesRfp(29), ...     % DAC Combiner    Offset IQ Cavity 3
    'cav3E', pvValuesRfp(30), ...     % DAC Combiner    Value  QI Cavity 3
    'cav3F', pvValuesRfp(31), ...     % DAC Combiner    Offset QI Cavity 3
    'cav3G', pvValuesRfp(32), ...     % DAC Combiner    Value  QQ Cavity 3
    'cav3H', pvValuesRfp(33), ...     % DAC Combiner    Offset QQ Cavity 3
    'cav4A', pvValuesRfp(34), ...     % DAC Combiner    Value  II Cavity 4
    'cav4B', pvValuesRfp(35), ...     % DAC Combiner    Offset II Cavity 4
    'cav4C', pvValuesRfp(36), ...     % DAC Combiner    Value  IQ Cavity 4
    'cav4D', pvValuesRfp(37), ...     % DAC Combiner    Offset IQ Cavity 4
    'cav4E', pvValuesRfp(38), ...     % DAC Combiner    Value  QI Cavity 4
    'cav4F', pvValuesRfp(39), ...     % DAC Combiner    Offset QI Cavity 4
    'cav4G', pvValuesRfp(40), ...     % DAC Combiner    Value  QQ Cavity 4
    'cav4H', pvValuesRfp(41), ...     % DAC Combiner    Offset QQ Cavity 4
    'directA', pvValuesRfp(42), ...   % DAC Direct Loop Value  II
    'directB', pvValuesRfp(43), ...   % DAC Direct Loop Offset II
    'directC', pvValuesRfp(44), ...   % DAC Direct Loop Value  IQ
    'directD', pvValuesRfp(45), ...   % DAC Direct Loop Offset IQ
    'directE', pvValuesRfp(46), ...   % DAC Direct Loop Value  QI
    'directF', pvValuesRfp(47), ...   % DAC Direct Loop Offset QI
    'directG', pvValuesRfp(48), ...   % DAC Direct Loop Value  QQ
    'directH', pvValuesRfp(49), ...   % DAC Direct Loop Offset QQ
    'combA', pvValuesRfp(50), ...     % DAC Comb   Loop Value  II
    'combB', pvValuesRfp(51), ...     % DAC Comb   Loop Offset II
    'combC', pvValuesRfp(52), ...     % DAC Comb   Loop Value  IQ
    'combD', pvValuesRfp(53), ...     % DAC Comb   Loop Offset IQ
    'combE', pvValuesRfp(54), ...     % DAC Comb   Loop Value  QI
    'combF', pvValuesRfp(55), ...     % DAC Comb   Loop Offset QI
    'combG', pvValuesRfp(56), ...     % DAC Comb   Loop Value  QQ
    'combH', pvValuesRfp(57), ...     % DAC Comb   Loop Offset QQ
    'moduCo1I', pvValuesRfp(58), ...  % DAC Combiner Output Offset I Cavity 1
    'moduCo1Q', pvValuesRfp(59), ...  % DAC Combiner Output Offset Q Cavity 1
    'moduCo2I', pvValuesRfp(60), ...  % DAC Combiner Output Offset I Cavity 2
    'moduCo2Q', pvValuesRfp(61), ...  % DAC Combiner Output Offset Q Cavity 2
    'moduCo3I', pvValuesRfp(62), ...  % DAC Combiner Output Offset I Cavity 3
    'moduCo3Q', pvValuesRfp(63), ...  % DAC Combiner Output Offset Q Cavity 3
    'moduCo4I', pvValuesRfp(64), ...  % DAC Combiner Output Offset I Cavity 4
    'moduCo4Q', pvValuesRfp(65), ...  % DAC Combiner Output Offset Q Cavity 4
    'moduGo1I', pvValuesRfp(66), ...  % DAC Gain     Output Offset I Cavity 1
    'moduGo1Q', pvValuesRfp(67), ...  % DAC Gain     Output Offset Q Cavity 1
    'moduGo2I', pvValuesRfp(68), ...  % DAC Gain     Output Offset I Cavity 2
    'moduGo2Q', pvValuesRfp(69), ...  % DAC Gain     Output Offset Q Cavity 2
    'moduGo3I', pvValuesRfp(70), ...  % DAC Gain     Output Offset I Cavity 3
    'moduGo3Q', pvValuesRfp(71), ...  % DAC Gain     Output Offset Q Cavity 3
    'moduGo4I', pvValuesRfp(72), ...  % DAC Gain     Output Offset I Cavity 4
    'moduGo4Q', pvValuesRfp(73), ...  % DAC Gain     Output Offset Q Cavity 4
    'tuneA', pvValuesRfp(74), ...     % DAC Tune Mode      Value  I
    'tuneB', pvValuesRfp(75), ...     % DAC Tune Mode      Offset I
    'tuneC', pvValuesRfp(76), ...     % DAC Tune Mode      Value  Q
    'tuneD', pvValuesRfp(77), ...     % DAC Tune Mode      Offset Q
    'moduDnIO', pvValuesRfp(78), ...  % DAC Difference     Offset I
    'moduDnQO', pvValuesRfp(79), ...  % DAC Difference     Offset Q
    'moduKlIO', pvValuesRfp(80), ...  % DAC Klystron Mod   Offset I
    'moduKlQO', pvValuesRfp(81), ...  % DAC Klystron Mod   Offset Q
    'moduRfIO', pvValuesRfp(82), ...  % DAC RF Mod         Offset I
    'moduRfQO', pvValuesRfp(83), ...  % DAC RF Mod         Offset Q
    'moduCsIO', pvValuesRfp(84), ...  % DAC Comp Stage     Offset I
    'moduCsQO', pvValuesRfp(85), ...  % DAC Comp Stage     Offset Q
    'moduDlIO', pvValuesRfp(86), ...  % DAC Dir Loop Ctrl  Offset I
    'moduDlQO', pvValuesRfp(87), ...  % DAC Dir Loop Ctrl  Offset Q
    'moduClIO', pvValuesRfp(88), ...  % DAC Comb Loop      Offset I
    'moduClQO', pvValuesRfp(89), ...  % DAC Comb Loop      Offset Q
    'moduSnIO', pvValuesRfp(90), ...  % DAC Summing Node   Offset I
    'moduSnQO', pvValuesRfp(91), ...  % DAC Summing Node   Offset Q
    'moduKlOI', pvValuesRfp(92), ...  % DAC Klystron Demod Offset I
    'moduKlOQ', pvValuesRfp(93), ...  % DAC Klystron Demod Offset Q
    'moduKmII', pvValuesRfp(94), ...  % DAC Klystron Mod DAC Offset II
    'moduKmIQ', pvValuesRfp(95), ...  % DAC Klystron Mod DAC Offset IQ
    'moduKmQI', pvValuesRfp(96), ...  % DAC Klystron Mod DAC Offset QI
    'moduKmQQ', pvValuesRfp(97), ...  % DAC Klystron Mod DAC Offset QQ
    'rlCoefA', pvValuesRfp(98), ...   % DAC Analog Ripple Loop Value  II_QQ
    'rlCoefB', pvValuesRfp(99), ...   % DAC Analog Ripple Loop Offset II_QQ
    'rlCoefC', pvValuesRfp(100), ...  % DAC Analog Ripple Loop Value  IQ_QI
    'rlCoefD', pvValuesRfp(101), ...  % DAC Analog Ripple Loop Offset IQ_QI
    'iRefA', pvValuesRfp(102), ...    % DAC Internal Reference Value  I
    'iRefB', pvValuesRfp(103), ...    % DAC Internal Reference Offset I
    'iRefC', pvValuesRfp(104), ...    % DAC Internal Reference Value  Q
    'iRefD', pvValuesRfp(105), ...    % DAC Internal Reference Offset Q
    'moduMdrv', pvValuesRfp(106) ...  % DAC Maximum Drive
    );

if (beamCurrent < 5)
    prm.detune = 0;
end

if combPresent,
    prm.cph = cph;
    prm.cph_off = cph_off;
    prm.cgn = cgn;
    % Read comb coefficients
    [num0, num1, den1, den2] = read_comb_IIR_C2(station);
    % Read equalizer coefficients
    prm.Beq = read_comb_eq(handles);
    % Filter numerator
    prm.num = [1 -1 0];
    % Filter denominator
%     cset = 1;
    prm.den = [1 den1 den2];
%     prm.den(2) = -1.83896;
end % if combPresent,

% Set up the weights
prm.Weight = ones(size(prm.w));

% keep this code for now
% note that after the next pair, the weights for freq > 500k will be 2
%  after the following pair, the weights for freq > 500k will be 4
ix = find(abs(prm.w-prm.wrf) > 2*pi*500e3);
prm.Weight(ix) = 2*prm.Weight(ix);

ix = find(abs(prm.w-prm.wrf) > 2*pi*150e3);
prm.Weight(ix) = 2*prm.Weight(ix);

ix = find(abs(prm.w-prm.wrf) < 2*pi*90e3);
prm.Weight(ix) = 0;

x0(1) = prm.wrf+2e3*pi*prm.detune;

% printprm( prm );

switch station(1),
    case 'H'
        % HER
        % x0(2) = 5; At High current!
        x0(2) = prm.Ql;
        x0(3) = 3;
        x0(4) = 450e-9;
        x0(5) = 160/180*pi;
        x0(6) = 0.2;
        x0(7) = 4800e-9;
        x0(8) = 40/180*pi;
    case 'L'
        % LER
        x0(2) = prm.Ql;
        x0(3) = 4.;
        x0(4) = 485e-9;
        x0(5) = 165/180*pi;
        x0(6) = 0.15;
        x0(7) = 5400e-9;
        x0(8) = 20/180*pi;
    case 'S'
        % SPEAR
        x0(2) = prm.Ql;
%         x0(3) = 3.55;
        x0(3) = -2.28;
%         x0(4) = 565e-9;
        x0(4) = 355e-9;
%         x0(5) = (180+65)/180*pi;
        x0(5) = 83/180*pi;
        x0(6) = 0;
        x0(7) = 0;
        x0(8) = 0;
    otherwise
        error(['unknown station ', station]);
end % switch station(1),

% printx('x0', x0);

x0 = x0./[prm.scale prm.scale1];

% printx('x0', x0);

% use medium scale since we supply neither the gradient nor the Hessian
opts = optimset('Display', 'iter', ...
    'LargeScale', 'off');
opts = optimset(opts, 'TolX', 1e-8, 'TolFun', 1e-8);
opts = optimset(opts, 'DiffMaxChange', 1e-5, ...
                'MaxFunEvals', 1e3, 'MaxIter', 1e3);

[x, norm, exitflag, output, grad, hess] = fminunc(@fit_loop3, x0, opts, prm);

% printx('x', x);
x(1) = (prm.wrf+2e3*pi*prm.detune)/prm.scale(1);
% printx('x', x);

switch station(1)
    case {'H', 'L'}
        sigma_x = sqrt(norm*diag(inv(hess/2))/(2*length(prm.w)-length(x0)))';
    case 'S'
        % hessian not invertible for values with no variation
        % find non-zero elements on diagonal to find size of hessian to
        % invert
        % negative values of hessian probably should be due to numerical
        % error so set these to zero
        negInd = find(hess < 0);
        hess(negInd) = 0;

        fprintf(1,'hessian = \n');
        [mH,nH] = size(hess);
        for i1 = 1:mH,
            fprintf(1,'\t%g', hess(i1,:));
            fprintf(1,'\n');
        end % for i1 = 1:mH,
        
        sigma_x = zeros(size(x));
        sInd = find(diag(hess) ~= 0);
        sigma_x(sInd) = ...
            sqrt(norm*diag(inv(hess(sInd,sInd)/2))/(2*length(prm.w)-length(x0)))';
    otherwise
        fprintf(1,'unknown station  no sigma calculation\n');
end % switch station(1)
        
% printx('sigma_x', sigma_x);

Ldir = rftfresponse(x(1:5).*scaleDir, prm);
if combPresent,
    Lcmb = compute_comb(x(6:8), prm);
    L = Ldir./(1-(1+Lcmb).*Ldir);
else
    L = Ldir./(1-Ldir);
end % if combPresent

scalePlot = [1/2e6/pi 1 1 1e9 180/pi 1 1e9 180/pi];
xx = x.*[prm.scale prm.scale1].*scalePlot;
sxx = sigma_x.*[prm.scale prm.scale1].*scalePlot;
% printx('scale', scalePlot);
% printx('xx', xx);
% printx('sxx', sxx);

[xx, sxx] = format_sigma(xx, sxx);

sfitd = ['Direct: F_r = ', num2str(xx(1)), '\pm', num2str(sxx(1)), ...
        ' MHz; Ql = ', num2str(xx(2)), '\pm', num2str(sxx(2)), ...
        '; G = ', num2str(xx(3)), '\pm', num2str(sxx(3)), ...
        '; T_d = ', num2str(xx(4)), '\pm', num2str(sxx(4)), ...
	' ns; \phi = ', num2str(xx(5)), '\pm', num2str(sxx(5)), ...
    ' deg'];
if combPresent,
    sfitc = ['Comb: Gc = ', num2str(xx(6)), '\pm', num2str(sxx(6)), ...
        '; T_c = ', num2str(xx(7)), '\pm', num2str(sxx(7)), ...
        ' ns; \phi_c = ', num2str(xx(8)), '\pm', num2str(sxx(8)), ...
        ' deg'];
end % if combPresent,

figure(figOne); clf
subplot(211); set(gca, 'fontsize', 12);
h=plot(frfit, 20*log10(abs(L)), 'g', frfit, 20*log10(abs(prm.H)), 'r');
set(h(1), 'linewidth', 2);
legend('Fit', 'Data');
%xlabel('Frequency (kHz)');
ylabel('Gain (dB)');
ysc = get(gca, 'ylim');
if (ysc(1) < -25), ysc(1) = -25; end
if (ysc(2) > 20), ysc(2) = 20; end
set(gca, 'ylim', ysc);
grid;
title(sfitd);
subplot(212); set(gca, 'fontsize', 12);
h1=plot(frfit, 180/pi*angle(L), 'g', ...
       frfit, 180/pi*angle(prm.H), 'r');
set(h1(1), 'linewidth', 2);
xlabel('Frequency (kHz)');
ylabel('Phase (degrees)');
grid;
if combPresent,
    title(sfitc);
end % if combPresent,

prm.w = 2e3*pi*freq + prm.wrf;
L1dir  = rftfresponse(x(1:5).*scaleDir, prm);
if combPresent,
    L1comb = compute_comb(x(6:8), prm);
    L1 = L1dir./(1-(1+L1comb).*L1dir);
else
    L1 = L1dir./(1-L1dir);
end % if combPresent
L1m = 20*log10(abs(L1));

% increment to the next figure
figHandles = handles.figHandles;
figInd=length(figHandles);
figInd=figInd+1; figure(figInd); clf; figHandles(figInd) = figInd;
handles.figHandles = figHandles;
guidata(handles.output, handles); % update  handles data
subplot(211);
h2=plot(freq, L1m, 'g', freq, magnitude, 'r', ...
       [-fspanL -fspanL]/1e3, [min(L1m) max(L1m)], 'b--', ...
       [fspanU fspanU]/1e3, [min(L1m) max(L1m)], 'b--');
set(h2(1), 'Linewidth', 2);
set(h2(3), 'Linewidth', 2);
set(h2(4), 'Linewidth', 2);
legend('Fit', 'Data', 'Fit span');
xlabel('Frequency (kHz)');
ylabel('Gain (dB)');
grid;
title('Measured closed-loop transfer function and a model fit');
subplot(212);
h3=plot(freq, 180/pi*angle(L1), 'g', freq, 180/pi*phases, 'r');
set(h3(1), 'linewidth', 2);
xlabel('Frequency (kHz)');
ylabel('Phase (degrees)');
grid;

% Configure parameters for the full_loop_chk.m
prm.dirmodel = x(1:5).*prm.scale;
prm.dirstd   = sigma_x(1:5).*prm.scale;
prm.scale    = ones(size(prm.dirmodel));
if combPresent,
    prm.cmbmodel = x(6:8).*prm.scale1;
    prm.cmbstd   = sigma_x(6:8).*prm.scale1;
    prm.scale1   = ones(size(prm.scale1));
end % if combPresent,
 
printprm(prm);

switch station(1)
    case {'H', 'L'}
        cmpprm(prm);
    case 'S'
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% handles = guidata(handles.output);  % Updates handles structure
fprintf(1,'Plot Tranfer Function completed for station %s\n',handles.station)
return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function printprm( s )
names = fieldnames( s );
lenNames = length(names);
for ind = 1:lenNames,
    if isempty(s.(names{ind})),
        fprintf(1,'%s = []\n', names{ind});
    elseif length(s.(names{ind})) > 10,
        fprintf(1,'%s has %d elements\n', names{ind}, length(s.(names{ind})));
    else
        fprintf(1,'%s =', names{ind});
        for i1 = 1:length(s.(names{ind})),
            fprintf(1,'  %g', s.(names{ind})(i1) );
        end
        fprintf(1,'\n');
    end
end
return
end

function printx( label, x )
fprintf(1,'%s =', label);
fprintf(1,'  %g', x);
fprintf(1,'\n');
return
end