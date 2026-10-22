function configure_comb(hObject, eventdata, handles)
% hObject    handle to loadDataPb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
% configure_comb.m - Measures the open loop transfer function of the comb
%                    filter feedback loop and optimizes the loop parameters.
%                    Also stores the no-beam klystron RF power reqired to
%                    generate the station gap voltage.  This power value
%                    is used during automated station phasing operation.
%                    Paul 10/7/98

%MOD: 01-14-2004 W. Colocho, For NOISE_I_BL_SMALL.out (and Q) use RF_DATA/<station>
%     (u_header) instead of RFTBL.
% MOD: W. Colocho, 06/01/2003 - Made into a function(). It uses handles
% structure to pass data. Called by RFguiInvasive.m

%clear
format compact
%help configure_comb

fprintf(1,'\n*** Beginning Comb Filter Loop Configuration Sequence ***\n');


%Use handles structure
%station = getenv('STATION');
station = handles.station;
gainFactor = get_RFP_noise_gain(station);%RFP module dependent gain
%rf_data = getenv('RF_DATA');
rf_data = handles.rfData;	
%rf_tbl = getenv('RFTBL');
rf_tbl = handles.tableDir; 
rf_module    = [station,':STN:RFP'];
handles.rfModule = rf_module; % Needed to pass rf_module to save_RFP_mux
comb_module1    = [station,':STN:CFM1'];
comb_module2    = [station,':STN:CFM2'];
% for RFP REV 4 we incresed the size of the noise file for this measurement
noise_I_file = '/dat/NOISE_I_BL'; % file to load into I DAC
noise_Q_file = '/dat/NOISE_Q_BL'; % file to load into Q DAC
% previously measured noise files
measured_I_noise = '/NOISE_I_BL.out';  
measured_Q_noise = '/NOISE_Q_BL.out'; 
% define the measured loop response file names
v_header = '/dat'; % string for the augeas stuff
u_header = [rf_data,'/',station];    % string for the unix stuff
measured_comb_I = '/COMB_I_OPEN'; 
measured_comb_Q = '/COMB_Q_OPEN';
DSP_file = handles.dspFile;       % define DSP files = /dsp/rippleRfp normally
IIR_file_HER = ['/cfmIirCoefsHER.tbl']; % define COMB IIR files - HER
IIR_file_LER = ['/cfmIirCoefsLER.tbl']; % define COMB IIR files - LER
equalizer_file_HER = '/tbl/detunEqHER.tbl';  % equalizer coeffs - HER
equalizer_file_LER = '/tbl/detunEqLER.tbl';  % equalizer coeffs - LER

% some configuration values
desired_gain_db = 17;		% desired open loop gain - dB
max_count = 10;			% maximum number of tries to write data files
f_rf = 476e6;			% RF frequency - Hz
w_rf = 2*pi*f_rf;		% RF frequency - radians/sec
fs = 72*476e6/3492;  		% clock frequency
ts = 1/fs;			% sampling interval
num_data = 2^18;		% set the desired length of the data files
num_fft  = 2^15;		% set the desired length of FFTs
t  = linspace(0,ts*num_data,num_data);	% time vector
f_sync_HER = 5.69e3;		% synchrotron frequency - HER
f_sync_LER = 3.40e3;		% synchrotron frequency - LER
f_rev = f_rf/3492;		% revolution frequency
T0 = 1/f_rev;			% revolution period
delay_default = 3000;		% default 1-turn delay setting - ns
freq_span = 600e3;		% bandwidth of comb response fitting 800 kHz nominal
plot_span = 800e3;		% bandwidth of comb response plotting 2 MHz nominal

% make sure the RF is on - remove carrige return
fprintf(1,'\nConfiguring RF system - please be patient\n');
[status,answer] = caShell(['caget -t -w 20 ', rf_module,':RFENABLE']);
if status ~=0
   fprintf(1,'Error - unable to read RF on/off status\n');
   return
end
if strcmp(answer(1:2),'ON') ~= 1
   fprintf(1,'Error - RF must be on to configure comb loop\n');
   return
end

%save_RFP_mux	% remember the state of the muxes for fast fault data
save_RFP_mux(hObject, eventdata, handles)
handles = guidata(handles.output);   %Updates handles with mux info.

% determine if the station is a HER (4 cavities) or an LER (2 cavities)
[status,answer] = caShell(['caget -t -w 20 ', station,':STN:RING:PLC']);
if status ~=0
   fprintf(1,'Error - unable to read RF station type\n');
   return
end
if strcmp (answer(1:3),'HER' ) == 1
   f_sync   = f_sync_HER;
   IIR_file = IIR_file_HER;
   equalizer_file = equalizer_file_HER;
elseif strcmp (answer(1:3),'LER' ) == 1
   f_sync   = f_sync_LER;
   IIR_file = IIR_file_LER;
   equalizer_file = equalizer_file_LER;
else
   fprintf(1,'Error - incorrection station type - not HER or LER\n');
   return
end

% read the present amount of klystron power needed to generate gap voltage
fprintf(1,'Reading klystron output RF power\n');
[status,answer] = caShell(['caget -t -w 20 ', station,':KLYSOUTFRWD:POWER']);
if status ~=0
   fprintf(1,'Error - unable to read present klystron RF output power\n');
   return
end
no_beam_power = str2num(answer);
% make sure no_beam_power is large enough to be valid
if no_beam_power > 150
  fprintf(1,['Writing no beam klystron output RF power to database = %4.1f kW\n'],no_beam_power);
  [status,answer] = caShell(['caput -w 20 ', station,':KLYSOUTFRWD:POWER:NORM ', ...
                           num2str(no_beam_power)]);
else
fprintf(1,['No beam klystron output RF power too small, value = %4.1f kW\n'],no_beam_power);
fprintf(1,'Database value for no beam power not updated\n');
end

if 0 % don't update the fast turn-on voltage for now - set this to 1 to configure fast turn-on settings
% read the present amount of klystron voltage needed to generate gap voltage
[status,answer] = caShell(['caget -t -w 20 ', station,':HVPS:VOLT:CTRL.VAL']);
if status ~=0
   fprintf(1,'Error - unable to read present klystron voltage\n');
   return
end
no_beam_voltage = str2num(answer);
% make sure no_beam_voltage is large enough to be valid
if no_beam_voltage > 55
  fprintf(1,['Writing no beam klystron voltage to database = %4.1f kV\n'],no_beam_voltage);
  [status,answer] = caShell(['caput -w 20 ', station,':HVPS:VOLT:FASTON ', ...
                           num2str(no_beam_voltage)]);
else
fprintf(1,['No beam klystron voltage too small, value = %4.1f kW\n'],no_beam_voltage);
fprintf(1,'Database value for no beam klystron voltage not updated\n');
end
end % don't update the fast turn-on voltage for now

% read the present amount of gap counts needed to generate gap voltage
[status,answer] = caShell(['caget -t -w 20 ', station,':STN:GFF:IQ.A']);
if status ~=0
   fprintf(1,'Error - unable to read present gap DAC counts\n');
   return
end
no_beam_DAC = str2num(answer);
% make sure no_beam_DAC is large enough to be valid
if no_beam_DAC > 500
  fprintf(1,['Writing no beam GAP DAC counts = %4.0f counts\n'],no_beam_DAC);
  [status,answer] = caShell(['caput -w 20 ', station,':STN:GFFFAST:INIT ', ...
                           num2str(no_beam_DAC)]);
else
fprintf(1,['No beam GAP DAC counts too small, value = %4.1f counts\n'],no_beam_DAC);
fprintf(1,'Database value for no beam GAP DAC counts not updated\n');
end

% write the desired comb gain to the feedback panel
[status,answer] = caShell(['caput -w 20 ', station,':STNCOMB:LOOP:COUNTS.A ', ...
                         num2str(desired_gain_db)]);
if status ~=0
   fprintf(1,'Error - can not set the desired comb gainh\n');
   return
end

% write the desired length of the data files to the RF module driver
[status,answer] = caShell(['caput -w 20 ', rf_module,':MODU.RMSZ ', num2str(num_data/1024)]);
if status ~=0
   fprintf(1,'Error - can not set the desired file length\n');
   return
end

% make sure the ripple loop is closed - remove carrige return
[status,answer] = caShell(['caget -t -w 20 ', rf_module,':RIPPLELOOP']);
if status ~=0
   fprintf(1,'Error - unable to read ripple loop status\n');
   return
end
if strcmp(answer(1:2),'On') ~= 1
   fprintf(1,'Activating Ripple loop\n');
   [status,answer] = caShell(['caput -w 20 ', rf_module,':RIPPLELOOP 1']);
   if status ~=0
      fprintf(1,'Error - can not close the ripple loop\n');
      return
   end
end

% make sure the direct RF loop is closed - remove carrige return
[status,answer] = caShell(['caget -t -w 20 ', rf_module,':DIRECTLOOP']);
if status ~=0
   fprintf(1,'Error - unable to read direct RF loop status\n');
   return
end
if strcmp(answer(1:2),'On') ~= 1
   fprintf(1,'Error - Direct RF loop must be closed to configure comb loop\n');
   return
end

% open the comb loop
[status,answer] = caShell(['caput -w 20 ', rf_module,':COMBLOOP 0']);
if status ~=0
   fprintf(1,'Error - can not open the comb loop\n');
   return
end

% set the comb loop gain offset to zero
[status,answer] = caShell(['caput -t -w 20 ', station, ...
                        ':STNCOMB:LOOP:COUNTS.B 0']);
if status ~=0
   fprintf(1,'Error - unable to clear comb loop gain offset\n');
   return
end

% set the comb loop phase offset to zero
[status,answer] = caShell(['caput -t -w 20 ', station, ...
                        ':STNCOMB:LOOP:PHASE.C 0']);
if status ~=0
   fprintf(1,'Error - unable to clear comb loop phase offset\n');
   return
end

% place the RF module in Reset mode
[status,answer] = caShell(['caput -w 20 ', rf_module,':STATE 0']);
if status ~=0
   fprintf(1,'Error - can not place RF module in Reset state\n');
   return
end

% place the RF module in Load mode
[status,answer] = caShell(['caput -w 20 ', rf_module,':STATE 1']);
if status ~=0
   fprintf(1,'Error - can not place RF module in Load state\n');
   return
end


fprintf(1,'Initializing comb filters\n');
% place the I comb filter module in Load mode
[status,answer] = caShell(['caput -w 20 ', comb_module1,':STATE 0']);
if status ~=0
   fprintf(1,'Error - can not place I comb filter module in Load state\n');
   return
end

% place the Q comb filter module in Load mode
[status,answer] = caShell(['caput -w 20 ', comb_module2,':STATE 0']);
if status ~=0
   fprintf(1,'Error - can not place Q comb filter module in Load state\n');
   return
end

% if delay is not close to default value load the default 1-turn delay value 
% into the comb filters
[status,answer] = caShell(['caget -t -w 20  ', comb_module1,':MODU.F0FO']);
if status ~=0
   fprintf(1,'Error - can not read 1-turn delay from I comb filter module\n');
   return
end
delay_I = str2num(answer);
[status,answer] = caShell(['caget -t -w 20  ', comb_module2,':MODU.F0FO']);
if status ~=0
   fprintf(1,'Error - can not read 1-turn delay from Q comb filter module\n');
   return
end
delay_Q = str2num(answer);

if (delay_I ~= delay_Q) | (abs(delay_I - delay_default) > 1000) | ...
                          (abs(delay_Q - delay_default)> 1000)
  fprintf(1,'Loading default 1-turn delay in I comb filter module\n');
  delay_I = delay_default;	% remember what the delay is set to
  [status,answer] = caShell(['caput -w 20 ', comb_module1, ...
                          ':MODU.F0FO ',num2str(delay_default)]);
  if status ~=0
     fprintf(1,'Error - can not load 1-turn delay in I comb filter module\n');
     return
  end
  fprintf(1,'Loading default 1-turn delay in Q comb filter module\n');
  [status,answer] = caShell(['caput -w 20 ', comb_module2, ...
                         ':MODU.F0FO ',num2str(delay_default)]);
  if status ~=0
     fprintf(1,'Error - can not load 1-turn delay in Q comb filter module\n');
     return
  end
end

% see what IIR files are in the COMBs - load correct files if necessary
% first do the I COMB (#1)
[status,answer] = caShell(['caget -t -w 20  ', comb_module1,':MODU.IMCF']);
if status ~=0
   fprintf(1,'Error - unable to read COMB #1 IIR coefficient filename\n');
   return
end

%if strcmp(answer(1:length(answer)-1),['/tbl',IIR_file]) ~= 1  % 7/16/2003 W.Colocho removed -1 
if strcmp(answer(1:length(answer)),['/tbl',IIR_file]) ~= 1
   fprintf(1,'loading correct COMB IIR file to comb module #1\n');
   [status,answer] = caShell(['caput -w 20 ', comb_module1, ...
                           ':MODU.IMCF /tbl',IIR_file]);
   if status ~=0
      fprintf(1,'Error - can not write the COMB #1 IIR filename\n');
      return
   end
   [status,answer] = caShell(['caput -w 20 ', comb_module1,':MODU.LIMC 1']);
   if status ~=0
      fprintf(1,'Error - can not load the COMB #1 IIR file\n');
      return
   end
   test = 0;	% force the first pass in the while loop
   count = 0;	% count how many times we look at the status mesasage
   pause(2);	% wait 2 seconds to allow things to start
   while test ~= 1,
      [status,answer] = caShell(['caget -t -w 20 ', comb_module1,':MODU.FSTT']);
      count = count +1;
      test = strcmp(answer(1),'N');
      if count > max_count
         fprintf(1,'Error - can not load the COMB #1 IIR file - timed out\n');
         return
      end
      if test ~= 1, pause(1); end;	% sleep for 1 seconds
   end; % end of the while loop
end
% now we do the Q COMB (#2)
[status,answer] = caShell(['caget -t -w 20  ', comb_module2,':MODU.IMCF']);
if status ~=0
   fprintf(1,'Error - unable to read COMB #2 IIR coefficient filename\n');
   return
end
%if strcmp(answer(1:length(answer)-1),['/tbl',IIR_file]) ~= 1 %7/16/03 W.Colocho: removed -1
if strcmp(answer(1:length(answer)),['/tbl',IIR_file]) ~= 1
   fprintf(1,'loading correct COMB IIR file to comb module #2\n');
   [status,answer] = caShell(['caput -w 20 ', comb_module2, ...
                           ':MODU.IMCF /tbl',IIR_file]);
   if status ~=0
      fprintf(1,'Error - can not write the COMB #2 IIR filename\n');
      return
   end
   [status,answer] = caShell(['caput -w 20 ', comb_module2,':MODU.LIMC 1']);
   if status ~=0
      fprintf(1,'Error - can not load the COMB #2 IIR file\n');
      return
   end
   test = 0;	% force the first pass in the while loop
   count = 0;	% count how many times we look at the status mesasage
   pause(1);	% wait 1 seconds to allow things to start
   while test ~= 1,
      [status,answer] = caShell(['caget -t -w 20 ', comb_module2,':MODU.FSTT']);
      count = count +1;
      test = strcmp(answer(1),'N');
      if count > max_count
         fprintf(1,'Error - can not load COMB #2 IIR file - timed out\n');
         return
      end
      if test ~= 1, pause(1); end;	% sleep for 1 seconds
   end; % end of the while loop
end

% see what equalizer files are in the COMBs - load correct files if necessary
% first do the I COMB (#1) - we will use equalzier bank #0
[status,answer] = caShell(['caget -t -w 20  ', comb_module1,':MODU.E0CF']);
if status ~=0
   fprintf(1,'Error - unable to read COMB #1 equalizer bank #0 coefficient filename\n');
   return
end
%if strcmp(answer(1:length(answer)-1),equalizer_file) ~= 1  %7/16/03 W.Colocho removed -1
if strcmp(answer(1:length(answer)),equalizer_file) ~= 1
   fprintf(1,'loading correct COMB equalizer bank 0 file to comb module #1\n');
   [status,answer] = caShell(['caput -w 20 ', comb_module1,':MODU.E0CF ', ...
                            equalizer_file]);
   if status ~=0
      fprintf(1,'Error - can not write the COMB #1 equalzier bank #0 filename\n');
      return
   end
   [status,answer] = caShell(['caput -w 20 ', comb_module1,':MODU.LE0C 1']);
   if status ~=0
      fprintf(1,'Error - can not load the COMB #1 equalzier bank #0 file\n');
      return
   end
   test = 0;	% force the first pass in the while loop
   count = 0;	% count how many times we look at the status mesasage
   pause(2);	% wait 2 seconds to allow things to start
   while test ~= 1,
      [status,answer] = caShell(['caget -t -w 20 ', comb_module1,':MODU.E0AS']);
      count = count +1;
      test = strcmp(answer(1),'N');
      if count > max_count
         fprintf(1,'Error - can not load the COMB #1 equalzier bank #0 file - timed out\n');
         return
      end
      if test ~= 1, pause(1); end;	% sleep for 1 seconds
   end; % end of the while loop
end
% now we do the Q COMB (#2)
[status,answer] = caShell(['caget -t -w 20  ', comb_module2,':MODU.E0CF']);
if status ~=0
   fprintf(1,'Error - unable to read COMB #2 equalizer bank #0 coefficient filename\n');
   return
end
%if strcmp(answer(1:length(answer)-1),equalizer_file) ~= 1 %7/16/03 W.colocho removed -1
if strcmp(answer(1:length(answer)),equalizer_file) ~= 1
   fprintf(1,'loading correct COMB equalizer bank 0 file to comb module #2\n');
   [status,answer] = caShell(['caput -w 20 ', comb_module2,':MODU.E0CF ', ...
                            equalizer_file]);
   if status ~=0
      fprintf(1,'Error - can not write the COMB #2 equalzier bank #0 filename\n');
      return
   end
   [status,answer] = caShell(['caput -w 20 ', comb_module2,':MODU.LE0C 1']);
   if status ~=0
      fprintf(1,'Error - can not load the COMB #2 equalzier bank #0 file\n');
      return
   end
   test = 0;	% force the first pass in the while loop
   count = 0;	% count how many times we look at the status mesasage
   pause(2);	% wait 2 seconds to allow things to start
   while test ~= 1,
      [status,answer] = caShell(['caget -t -w 20 ', comb_module2,':MODU.E0AS']);
      count = count +1;
      test = strcmp(answer(1),'N');
      if count > max_count
         fprintf(1,'Error - can not load the COMB #2 equalzier bank #0 file - timed out\n');
         return
      end
      if test ~= 1, pause(1); end;	% sleep for 1 seconds
   end; % end of the while loop
end

% see what files are in the RF module fast DACs - load correct files if necessary
% first do the I DACs
[status,answer] = caShell(['caget -t -w 20 ', rf_module,':MODU.DIRF']);
if status ~=0
   fprintf(1,'Error - unable to read DAC_I filename\n');
   return
end
%if strcmp(answer(1:length(answer)-1),noise_I_file) ~= 1  % 7/16/03 W.Colocho removed -1
if strcmp(answer(1:length(answer)),noise_I_file) ~= 1
   fprintf(1,'loading correct DAC_I file to module RAM\n');
   [status,answer] = caShell(['caput -w 20 ', rf_module,':MODU.DIRF ',noise_I_file]);
   if status ~=0
      fprintf(1,'Error - can not write the DAC_I filename\n');
      return
   end
   [status,answer] = caShell(['caput -w 20 ', rf_module,':MODU.LDIR 1']);
   if status ~=0
      fprintf(1,'Error - can not load the DAC_I file\n');
      return
   end
   test = 0;	% force the first pass in the while loop
   count = 0;	% count how many times we look at the status mesasage
   pause(2);	% wait 2 seconds to allow things to start
   while test ~= 1,
      [status,answer] = caShell(['caget -t -w 20 ', rf_module,':MODU.DIST']);
      count = count +1;
      test = strcmp(answer(1),'N');
      if count > max_count
         fprintf(1,'Error - can not load the DAC_I file - timed out\n');
         return
      end
      if test ~= 1, pause(1); end;	% sleep for 1 seconds
   end; % end of the while loop
end

% next do the Q DACs
[status,answer] = caShell(['caget -t -w 20 ', rf_module,':MODU.DQRF']);
if status ~=0
   fprintf(1,'Error - unable to read DAC_Q filename\n');
   return
end
%if strcmp(answer(1:length(answer)-1),noise_Q_file) ~= 1 % 7/16/2003 W.Colocho removed -1
if strcmp(answer(1:length(answer)),noise_Q_file) ~= 1
   fprintf(1,'loading correct DAC_Q file to module RAM\n') ;
   [status,answer] = caShell(['caput -w 20 ', rf_module,':MODU.DQRF ',noise_Q_file]);
   if status ~=0
      fprintf(1,'Error - can not write the DAC_Q filename\n');
      return
   end
   [status,answer] = caShell(['caput -w 20 ', rf_module,':MODU.LDQR 1']);
   if status ~=0
      fprintf(1,'Error - can not load the DAC_Q file\n') ;
      return
   end
   test = 0;	% force the first pass in the while loop
   count = 0;	% count how many times we look at the status mesasage
   pause(2);	% wait 2 seconds to allow things to start
   while test ~= 1,
      [status,answer] = caShell(['caget -t -w 20 ', rf_module,':MODU.DQST']);
      count = count +1;
      test = strcmp(answer(1),'N');
      if count > max_count
         fprintf(1,'Error - can not load the DAC_Q file - timed out\n') ;
         return
      end
      if test ~= 1, pause(1); end;	% sleep for 1 seconds
   end; % end of the while loop
end

% write the corrrect file names to save data
[status,answer] = caShell(['caput -t -w 20 ', rf_module,':MODU.SIRF ', ...
                         v_header,measured_comb_I]);
if status ~=0
   fprintf(1,'Error - unable to write SIG_I filename\n');
   return
end
[status,answer] = caShell(['caput -t -w 20 ', rf_module,':MODU.SQRF ', ...
                         v_header,measured_comb_Q]);
if status ~=0
   fprintf(1,'Error - unable to write SIG_Q filename\n');
   return
end

% turn on the comb filters
[status,answer] = caShell(['caput -w 20 ', comb_module1,':STATE 1']);
if status ~=0
   fprintf(1,'Error - can not place the comb module #1 in RUN mode\n');
   return
end
[status,answer] = caShell(['caput -w 20 ', comb_module2,':STATE 1']);
if status ~=0
   fprintf(1,'Error - can not place the comb module #2 in RUN mode\n');
   return
end

% set the comb filters for no filtering to clear any IIR overflows 
% use IIR comb set 3
[status,answer] = caShell(['caput -w 20 ', comb_module1,':CMBSETSEL 3']);
if status ~=0
   fprintf(1,'Error - can not select COMB module #1 IIR filter set #3\n');
   return
end
[status,answer] = caShell(['caput -w 20 ', comb_module2,':CMBSETSEL 3']);
if status ~=0
   fprintf(1,'Error - can not select COMB module #2 IIR filter set #3\n');
   return
end

% set the comb filters for comb filtering - use IIR comb set 2
[status,answer] = caShell(['caput -w 20 ', comb_module1,':CMBSETSEL 1']);
if status ~=0
   fprintf(1,'Error - can not select COMB module #1 IIR filter set #1\n');
   return
end
[status,answer] = caShell(['caput -w 20 ', comb_module2,':CMBSETSEL 1']);
if status ~=0
   fprintf(1,'Error - can not select COMB module #2 IIR filter set #1\n');
   return
end

% place the module in single shot mode
[status,answer] = caShell(['caput -w 20 ', rf_module,':SSCONT 0']);
if status ~=0
   fprintf(1,'Error - can not place the module in Single Shot mode\n');
   return
end

% enable the DACs
[status,answer] = caShell(['caput -w 20 ', rf_module,':DACS 1']);
if status ~=0
   fprintf(1,'Error - can not enable the DACs\n');
   return
end

% set SIGNAL multiplexer to COMB OUT
[status,answer] = caShell(['caput -w 20 ', rf_module,':FBSIG 1']);
if status ~=0
   fprintf(1,'Error - can not set the feedback signal to COMB OUT\n');
   return
end

%  take a single shot of data - go to run mode
fprintf(1,'\nTaking a single shot of data\n');
[status,answer] = caShell(['caput -w 20 ', rf_module,':STATE 2']);
if status ~=0
   fprintf(1,'Error - can not place RF module in Run state\n');
   return
end

% place the module in Load mode
[status,answer] = caShell(['caput -w 20 ', rf_module,':STATE 1']);
if status ~=0
   fprintf(1,'Error - can not place RF module in Load state\n');
   return
end

% get the data files
% read the SIGNAL_I file first
[status,answer] = caShell(['caput -w 20 ', rf_module,':MODU.GSIR 1']);
if status ~=0
   fprintf(1,'Error - can not activate the SIGNAL_I file read\n');
   return
end
fprintf(1,'Moving data from I channel to file\n');
test = 0;	% force the first pass in the while loop
count = 0;	% count how many times we look at the status mesasage
pause(2);	% wait 2 seconds to allow things to start
while test ~= 1,
   [status,answer] = caShell(['caget -t -w 20 ', rf_module,':MODU.SIST']);
   count = count +1;
   test = strcmp(answer(1),'N');
   if count > max_count
      fprintf(1,'Error - can not read the SIGNAL_I file - timed out\n');
      return
   end
   if test ~= 1, pause(1); end;	% sleep for 1 seconds
end; % end of the while loop

% read the SIGNAL_Q file now
[status,answer] = caShell(['caput -w 20 ', rf_module,':MODU.GSQR 1']);
if status ~=0
   fprintf(1,'Error - can not activate the SIGNAL_Q file read\n');
   return
end
fprintf(1,'Moving data from Q channel to file\n');
test = 0;	% force the first pass in the while loop
count = 0;	% count how many times we look at the status mesasage
pause(2);	% wait 2 seconds to allow things to start
while test ~= 1,
   [status,answer] = caShell(['caget -t -w 20 ', rf_module,':MODU.SQST']);
   count = count +1;
   test = strcmp(answer(1),'N');
   if count > max_count
      fprintf(1,'Error - can not read the SIGNAL_Q file - timed out\n');
      return
   end
   if test ~= 1, pause(1); end;	% sleep for 1 seconds
end; % end of the while loop

% make the file ID's
fid1 = -1;
fid2 = -1;
while (fid1 == -1), fid1 = fopen([u_header,measured_comb_I],'r','ieee-be'); end;
while (fid2 == -1), fid2 = fopen([u_header,measured_comb_Q],'r','ieee-be'); end;
fid3 = -1;
fid4 = -1;
%while (fid3 == -1), fid3 = fopen([rf_tbl,measured_I_noise],'r','ieee-be'); end;
%while (fid4 == -1), fid4 = fopen([rf_tbl,measured_Q_noise],'r','ieee-be'); end;
while (fid3 == -1), fid3 = fopen([u_header,measured_I_noise],'r','ieee-be'); end;
while (fid4 == -1), fid4 = fopen([u_header,measured_Q_noise],'r','ieee-be'); end;

% read the measured data files
[header,count] = fread(fid1,[1,16],'char');
fprintf(1,'Reading %s%s\n',u_header,measured_comb_I);
[i_dat,count] = fread(fid1,[1,inf],'short'); fclose(fid1);
header = setstr (header);
if count ~= (num_data)
   ['length of file in ',header,' is incorrect. Length = ',num2str(count)]
   return
end
[header,count] = fread(fid2,[1,16],'char');
fprintf(1,'Reading %s%s\n',u_header,measured_comb_Q);
[q_dat,count] = fread(fid2,[1,inf],'short'); fclose(fid2);
header = setstr (header);
if count ~= (num_data)
   ['length of file in ',header,' is incorrect. Length = ',num2str(count)]
   return
end
% i_dat = (((i_dat/16)*2.0) + 1.0)/4095;
% q_dat = (((q_dat/16)*2.0) + 1.0)/4095;
% RFP REV 4 has a lower comb gain at this point in the circuit
i_dat = (((i_dat/16)*2.0) + 1.0)/2048; % x2 change
q_dat = (((q_dat/16)*2.0) + 1.0)/2048; % x2 change
out_data = i_dat + j*q_dat;
clear i_dat
clear q_dat

% read the recorded noise files
[header,count] = fread(fid3,[1,16],'char');
%fprintf(1,'Reading %s%s\n',rf_tbl,measured_I_noise);
fprintf(1,'Reading %s%s\n',u_header,measured_I_noise);
[i_dat,count] = fread(fid3,[1,num_data],'short'); fclose(fid3);
header          = setstr (header);
if count ~= (num_data)
   ['length of file in ',header,' is incorrect. Length = ',num2str(count)]
   return
end
[header,count] = fread(fid4,[1,16],'char');
%fprintf(1,'Reading %s%s\n',rf_tbl,measured_Q_noise);
fprintf(1,'Reading %s%s\n',u_header,measured_Q_noise);
[q_dat,count] = fread(fid4,[1,num_data],'short'); fclose(fid4);
header          = setstr (header);
if count ~= (num_data)
   ['length of file in ',header,' is incorrect. Length = ',num2str(count)]
   return
end
i_dat = (((i_dat/16)*2.0) + 1.0)/4095;
q_dat = (((q_dat/16)*2.0) + 1.0)/4095;
in_data =  (i_dat + j*q_dat) / gainFactor;
clear i_dat
clear q_dat

fprintf(1,'Calculating open loop comb path transfer function\n');
[Hsum,FF]=tfestimate(in_data,out_data,hanning(num_fft),[],num_fft,fs);
clear FF
clear out_data
Hsum=Hsum';	% this transpose is needed to get the proper phase slope
% reorder the results to go from -freq to + freq and filter the data
Hsum = [Hsum(num_fft/2+2:num_fft) Hsum(1:num_fft/2+1)];

% make a baseband frequency vector 
delta_f=fs/(num_fft);
baseband_freq=delta_f*[((-1*(num_fft/2 -1)):-1) 0 (1:num_fft/2) ];
[value,chop] = min(abs(baseband_freq+freq_span));	% zoom into freq_span

magnitude = 20*log10(abs(Hsum));
phases = angle(Hsum);

%figure(1)
clf
figHandles = handles.figHandles; % retrieve figure data
figInd=length(figHandles);
figInd=figInd+1; figure(figInd); clf; figHandles(figInd) = figInd;
handles.figHandles = figHandles;
guidata(handles.output, handles); % update  handles data
subplot(211)
plot(baseband_freq(chop:num_fft-chop)/1e3,magnitude(chop:num_fft-chop),'r') 
grid on
title(['Measured Open Loop Transfer Function of Comb Filter Loop - ',station])
xlabel('baseband frequency - kHz')
ylabel('amplitude - dB')
junk = axis;
axis([junk(1:2) -30 30])

subplot(212)
plot(baseband_freq(chop:num_fft-chop)/1e3,(180/pi)*phases(chop:num_fft-chop),'r')
grid on
xlabel('baseband frequency - kHz')
ylabel('phase - degrees')
%drawnow

% read the current settings of the loop gain and phase shift
[status,answer] = caShell(['caget -t -n -w 20 ', station, ...
                        ':STNCOMB:LOOP:COUNTS.A']);
old_magnitude_db = str2num(answer);
if status ~=0
   fprintf(1,'Error - unable to read comb loop gain\n');
   return
end

[status,answer] = caShell(['caget -t -n -w 20 ', station, ...
                        ':STNCOMB:LOOP:PHASE.A']);
old_phase = str2num(answer);
if status ~=0
   fprintf(1,'Error - unable to read comb loop phase\n');
   return
end

% read the comb IIR coefficient selection (0-3)
[status,answer] = caShell(['caget -t -n -w 20 ', comb_module1,':CMBSETSEL']);
comb_set = str2num(answer);
if status ~=0
   fprintf(1,'Error - unable to read comb IIR coefficeint set number\n');
   return
end
% read the comb IIR coeffieient file
fid5 = -1;
while (fid5 == -1), fid5 = fopen([rf_tbl,IIR_file],'r','ieee-be'); end;
% read the IIR coefficient file header
[header] = fgetl(fid5);
% read the measured data files
[IIR_coeffs, count] = fscanf(fid5,'%f'); fclose(fid5);
% parse into the individual coefficients
% compensate for /2 scaling used in actual hardware
% because hardware coeffs are limited to -1.0 < X < 1.0
% and invert denominator coeffs
den2 = IIR_coeffs(1:4)*(-2);
den1 = IIR_coeffs(5:8)*(-2);
num1 = IIR_coeffs(9:12);
num0 = IIR_coeffs(13:16);

% begin comb configuration calculations here

% fit the data to a comb model over the freq_span range
numpoints = fix((num_fft - fix(freq_span/delta_f))/2);
Wfit = 2*pi*(f_rf+baseband_freq(numpoints:num_fft-numpoints));
Hfit  = Hsum(numpoints:num_fft-numpoints);

% determine the gain, delay and phase offset
% guess for the system magnitude based on data and comb gain
mag_guess = num0(comb_set+1);	% pass in the numerator coefficient	
delay_guess = T0*1e9;		% guess for the system delay - ns
% guess the phase offset - look at f_rev/2 - should be 180 degrees here
offset_guess = pi - phases((num_fft/2) + round((f_rev/2)/delta_f));

x0 = [mag_guess delay_guess offset_guess];	% make the guess vector
% options(14) = length(Wfit);	% allow more iterations
% options(1) = 0;			% enables fitting display when option(1) = 1
% options(17) = .01;		% lower the max variation for finite difference
options = optimset('MaxFunEvals',length(Wfit),'Display','off');
% call the fitting routine
fprintf(1,'Fitting measured transfer function to system model\n');
% [x,options] = fmins('comb_fit',x0,options,[],Wfit,Hfit,T0,w_rf, ...
%                      den1(comb_set+1),den2(comb_set+1));
x = fminsearch(@comb_fit,x0,options,Wfit,Hfit,T0,w_rf, ...
                     den1(comb_set+1),den2(comb_set+1));
fitted_gain_db = 20*log10(abs(freqresp([x(1) -x(1) 0], ...
                 [1 den1(comb_set+1) den2(comb_set+1)], exp(j*2*pi*f_sync*T0)))); % dB
fitted_delay   = x(2);		% nano seconds
fitted_offset  = x(3)*(180/pi);	% degrees

% fitted model parameters - taken from comb_fit.m
Gc = x(1);              % gain term for the filter volts/volt
Td = x(2);              % time delay (1-turn) - ns
offset = x(3);          % phase offset for the filter
num = [Gc -Gc 0];
den = [1 den1(comb_set+1) den2(comb_set+1)];

% calculate the fitted response
combresp   = freqresp(num,den,exp(sqrt(-1)*2*pi*baseband_freq(chop:num_fft-chop)*T0)).'; 
delay_resp = exp(-j*(2*pi*baseband_freq(chop:num_fft-chop))*Td*1e-9);
combmodel  = combresp.* delay_resp.* exp(j*offset) ;
fitted_mag = 20*log10(abs(combmodel)+0.0001);	% prevent log of zero
fitted_phase = 180/pi*angle(combmodel);

% add the fitted response to the measured data plot
%figure(1)
figure(figInd)
subplot(211)
hold on
plot(baseband_freq(chop:num_fft-chop)/1e3, fitted_mag,'b')
subplot(212)
hold on
plot(baseband_freq(chop:num_fft-chop)/1e3 , fitted_phase,'b')
%drawnow

% calculate the desired new delay setting - ns
delta_delay = -1*(fitted_delay-(T0*1e9));
fprintf(1,'Changing 1-turn delay by %4.1f ns\n',delta_delay);
new_delay = delay_I + delta_delay;
% calculate the desired new gain setting
gain_change_db = desired_gain_db - fitted_gain_db;
fprintf(1,'Changing loop gain by %4.1f dB\n',gain_change_db);

% update the conversion factor for the comb loop gain setting
[status,answer] = caShell(['caget -t -n -w 20 ', station, ':STNCOMB:LOOP:COUNTS.E']);
conversion = str2num(answer);
if status ~=0
   fprintf(1,'Error - unable to read comb loop conversion factor\n');
   return
end
conversion_change = 10^((old_magnitude_db-fitted_gain_db)/20);
conversion = conversion_change*conversion;
[status,answer] = caShell(['caput -t -w 20 ', station, ...
                        ':STNCOMB:LOOP:COUNTS.E ', num2str(conversion)]);
if status ~=0
   fprintf(1,'Error - unable to write comb loop conversion factor\n');
   return
end

% calculate the desired new phase setting
phase_adjust = mod(fitted_offset + 180,360);
if (fitted_offset > 0) phase_adjust = fitted_offset - 180; end
if (fitted_offset < 0) phase_adjust = fitted_offset + 180; end
fprintf(1,'Changing comb loop phase by %4.1f degrees\n',phase_adjust);
new_phase = mod(old_phase + phase_adjust,360);

% update the phase
[status,answer] = caShell(['caput -t -w 20 ', station,':STNCOMB:LOOP:PHASE.A ', ...
                         num2str(new_phase)]);
if status ~=0
   fprintf(1,'Error - unable to write direct loop phase\n');
   return
end

% Update the 1-turn delay value in the comb modules
% place the I comb filter module in Load mode
[status,answer] = caShell(['caput -w 20 ', comb_module1,':STATE 0']);
if status ~=0
   fprintf(1,'Error - can not place I comb filter module in Load state\n');
   return
end
% place the Q comb filter module in Load mode
[status,answer] = caShell(['caput -w 20 ', comb_module2,':STATE 0']);
if status ~=0
   fprintf(1,'Error - can not place Q comb filter module in Load state\n');
   return
end
% load the default 1-turn delay value into the comb filters
fprintf(1,'Setting 1-turn delay value to %4.1f ns\n',new_delay);
[status,answer] = caShell(['caput -w 20 ', comb_module1, ...
                        ':MODU.F0FO ',num2str(new_delay)]);
if status ~=0
   fprintf(1,'Error - can not load 1-turn delay in I comb filter module\n');
   return
end
[status,answer] = caShell(['caput -w 20 ', comb_module2, ...
                        ':MODU.F0FO ',num2str(new_delay)]);
if status ~=0
   fprintf(1,'Error - can not load 1-turn delay in Q comb filter module\n');
   return
end

% turn on the comb filters
[status,answer] = caShell(['caput -w 20 ', comb_module1,':STATE 1']);
if status ~=0
   fprintf(1,'Error - can not place the comb module #1 in RUN mode\n');
   return
end
[status,answer] = caShell(['caput -w 20 ', comb_module2,':STATE 1']);
if status ~=0
   fprintf(1,'Error - can not place the comb module #2 in RUN mode\n');
   return
end

% set the comb filters for no filtering to clear any IIR overflows 
% use IIR comb set 3
[status,answer] = caShell(['caput -w 20 ', comb_module1,':CMBSETSEL 3']);
if status ~=0
   fprintf(1,'Error - can not select COMB module #1 IIR filter set #3\n');
   return
end
[status,answer] = caShell(['caput -w 20 ', comb_module2,':CMBSETSEL 3']);
if status ~=0
   fprintf(1,'Error - can not select COMB module #2 IIR filter set #3\n');
   return
end

% set the comb filters for comb filtering - use IIR comb set 1
[status,answer] = caShell(['caput -w 20 ', comb_module1,':CMBSETSEL 1']);
if status ~=0
   fprintf(1,'Error - can not select COMB module #1 IIR filter set #1\n');
   return
end
[status,answer] = caShell(['caput -w 20 ', comb_module2,':CMBSETSEL 1']);
if status ~=0
   fprintf(1,'Error - can not select COMB module #2 IIR filter set #1\n');
   return
end

% place the RF module in Reset mode
[status,answer] = caShell(['caput -w 20 ', rf_module,':STATE 0']);
if status ~=0
   fprintf(1,'Error - can not place RF module in Reset state\n');
   return
end

% place the RF module in Load mode
[status,answer] = caShell(['caput -w 20 ', rf_module,':STATE 1']);
if status ~=0
   fprintf(1,'Error - can not place RF module in Load state\n');
   return
end

%  take a single shot of data - go to run mode
fprintf(1,'\nTaking a single shot of data\n');
[status,answer] = caShell(['caput -w 20 ', rf_module,':STATE 2']);
if status ~=0
   fprintf(1,'Error - can not place RF module in Run state\n');
   return
end

% place the module in Load mode
[status,answer] = caShell(['caput -w 20 ', rf_module,':STATE 1']);
if status ~=0
   fprintf(1,'Error - can not place RF module in Load state\n');
   return
end

% get the data files
% read the SIGNAL_I file first
[status,answer] = caShell(['caput -w 20 ', rf_module,':MODU.GSIR 1']);
if status ~=0
   fprintf(1,'Error - can not activate the SIGNAL_I file read\n');
   return
end
fprintf(1,'Moving data from I channel to file\n');
test = 0;	% force the first pass in the while loop
count = 0;	% count how many times we look at the status mesasage
pause(2);	% wait 2 seconds to allow things to start
while test ~= 1,
   [status,answer] = caShell(['caget -t -w 20 ', rf_module,':MODU.SIST']);
   count = count +1;
   test = strcmp(answer(1),'N');
   if count > max_count
      fprintf(1,'Error - can not read the SIGNAL_I file - timed out\n');
      return
   end
   if test ~= 1, pause(1); end;	% sleep for 1 seconds
end; % end of the while loop

% read the SIGNAL_Q file now
[status,answer] = caShell(['caput -w 20 ', rf_module,':MODU.GSQR 1']);
if status ~=0
   fprintf(1,'Error - can not activate the SIGNAL_Q file read\n');
   return
end
fprintf(1,'Moving data from Q channel to file\n');
test = 0;	% force the first pass in the while loop
count = 0;	% count how many times we look at the status mesasage
pause(2);	% wait 2 seconds to allow things to start
while test ~= 1,
   [status,answer] = caShell(['caget -t -w 20 ', rf_module,':MODU.SQST']);
   count = count +1;
   test = strcmp(answer(1),'N');
   if count > max_count
      fprintf(1,'Error - can not read the SIGNAL_Q file - timed out\n');
      return
   end
   if test ~= 1, pause(1); end;	% sleep for 1 seconds
end; % end of the while loop

%restore_RFP_mux  % restore the mux setting for fast history buffers
restore_RFP_mux(hObject, eventdata, handles)

% make the file ID's
fid1 = -1;
fid2 = -1;
while (fid1 == -1), fid1 = fopen([u_header,measured_comb_I],'r','ieee-be'); end;
while (fid2 == -1), fid2 = fopen([u_header,measured_comb_Q],'r','ieee-be'); end;

% read the measured data files
[header,count] = fread(fid1,[1,16],'char');
fprintf(1,'Reading %s%s\n',u_header,measured_comb_I);
[i_dat,count] = fread(fid1,[1,inf],'short'); fclose(fid1);
header = setstr (header);
if count ~= (num_data)
   ['length of file in ',header,' is incorrect. Length = ',num2str(count)]
   return
end
[header,count] = fread(fid2,[1,16],'char');
fprintf(1,'Reading %s%s\n',u_header,measured_comb_Q);
[q_dat,count] = fread(fid2,[1,inf],'short'); fclose(fid2);
header = setstr (header);
if count ~= (num_data)
   ['length of file in ',header,' is incorrect. Length = ',num2str(count)]
   return
end
% i_dat = (((i_dat/16)*2.0) + 1.0)/4095;
% q_dat = (((q_dat/16)*2.0) + 1.0)/4095;
% for the rev 4 RFP the comb signal is a factor of 2 smaller
i_dat = (((i_dat/16)*2.0) + 1.0)/2047;
q_dat = (((q_dat/16)*2.0) + 1.0)/2047;
out_data = i_dat + j*q_dat;
clear i_dat
clear q_dat

fprintf(1,'Calculating open loop comb path transfer function\n');
[Hsum,FF]=tfestimate(in_data,out_data,hanning(num_fft),[],num_fft,fs);
clear FF
Hsum=Hsum';	% this transpose is needed to get the proper phase slope
% reorder the results to go from -freq to + freq and filter the data
Hsum = [Hsum(num_fft/2+2:num_fft) Hsum(1:num_fft/2+1)];

magnitude = 20*log10(abs(Hsum));	% filter the mag data
phases = (180/pi)*angle(-1*Hsum);	% invert the phase for the smile plot

[value,chop] = min(abs(baseband_freq+plot_span));	% zoom into plot_span

%figure(1)
figure(figInd)
clf
subplot(211)
plot(baseband_freq(chop:num_fft-chop)/1e3,magnitude(chop:num_fft-chop),'r') 
grid on
title('Measured Open Loop Transfer Function of Comb Filter Loop')
xlabel('baseband frequency - kHz')
ylabel('amplitude - dB')
junk = axis;
axis([junk(1:2) -30 30])

subplot(212)
plot(baseband_freq(chop:num_fft-chop)/1e3,phases(chop:num_fft-chop),'r')

grid on
text(-1800,-180,'0 degrees is actually 180 degrees - (subtraction assumed)')
xlabel('baseband frequency - kHz')
ylabel('phase - degrees')
%drawnow

% determine the gain, delay and phase offset
% guess for the system magnitude based on data and comb gain
mag_guess = num0(comb_set+1);	% pass in the numerator coefficient	
delay_guess = T0*1e9;		% guess for the system delay - ns
% guess the phase offset - look at f_rev/2 - should be 180 degrees here
offset_guess = pi - phases((num_fft/2) + round((f_rev/2)/delta_f));
Hfit  = Hsum(numpoints:num_fft-numpoints);	% prepare the new data for comb_fit

x0 = [mag_guess delay_guess offset_guess];	% make the guess vector
% options(14) = length(Wfit);	% allow more iterations
% options(1) = 0;			% enables fitting display when option(1) = 1
% options(17) = .01;		% lower the max variation for finite difference
options = optimset('MaxFunEvals',length(Wfit),'Display','off');
% call the fitting routine
fprintf(1,'Fitting measured transfer function to system model\n');
% [x,options] = fmins('comb_fit',x0,options,[],Wfit,Hfit,T0,w_rf, ...
%                      den1(comb_set+1),den2(comb_set+1));
x = fminsearch(@comb_fit,x0,options,Wfit,Hfit,T0,w_rf, ...
                     den1(comb_set+1),den2(comb_set+1));
fitted_gain_db = 20*log10(abs(freqresp([x(1) -x(1) 0], ...
                 [1 den1(comb_set+1) den2(comb_set+1)], exp(j*2*pi*f_sync*T0)))); % dB
fitted_delay   = x(2);		% nano seconds
fitted_offset  = x(3)*(180/pi);	% degrees

% fitted model parameters - taken from comb_fit.m
Gc = x(1);              % gain term for the filter volts/volt
Td = x(2);              % time delay (1-turn) - ns
offset = x(3);          % phase offset for the filter
num = [Gc -Gc 0];
den = [1 den1(comb_set+1) den2(comb_set+1)];

% calculate the fitted response
combresp   = freqresp(num,den,exp(sqrt(-1)*2*pi*baseband_freq*T0)).'; 
delay_resp = exp(-j*(2*pi*baseband_freq)*Td*1e-9);
combmodel  = combresp.* delay_resp.* exp(j*offset);
fitted_mag = 20*log10(abs(combmodel)+0.0001);	% prevent log of zero
fitted_phase = 180/pi*angle(-combmodel);

% add the fitted response to the measured data plot

% increment to the next figure
%figure(1)
figure(figInd)

subplot(211)
hold on
plot(baseband_freq(chop:num_fft-chop)/1e3, fitted_mag(chop:num_fft-chop),'b')
subplot(212)
hold on
plot(baseband_freq(chop:num_fft-chop)/1e3 , fitted_phase(chop:num_fft-chop),'b')
%drawnow

% add the phase margins to the plot
max_phase=360;		% clear the max and min phase memory
min_phase=360;
for index = chop:num_fft-chop-1,
  if fitted_mag(index) < 0
    if fitted_mag(index+1) >= 0
      subplot(212), plot(baseband_freq(index)/1e3,fitted_phase(index),'g*')
      test = fitted_phase(index);
      if test < -90
        test = 360 + test;
      end
      if 180 - test < max_phase
        max_phase = 180 - test;
      end
    end
  end
  if fitted_mag(index) > 0
    if fitted_mag(index+1) <= 0
      subplot(212), plot(baseband_freq(index)/1e3,fitted_phase(index),'m*')
      test = fitted_phase(index);
      if 180 + test < min_phase
        min_phase = 180 + test;
      end
    end
  end
end

% force a graphics update
%drawnow

% assuming 1-turn delay is correct check phase margins
upper_phase_margin = max_phase;
fprintf(1,'Upper phase margin is %4.1f degrees\n',upper_phase_margin);
lower_phase_margin = min_phase;
fprintf(1,'Lower phase margin is %4.1f degrees\n',lower_phase_margin);

fprintf(1,'*** Comb Filter Loop Configuration Sequence Complete ***\n');

return






