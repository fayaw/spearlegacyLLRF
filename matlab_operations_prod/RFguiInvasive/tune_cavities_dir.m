function tune_cavities_dir(hObject, eventdata, handles)
% hObject    handle to loadDataPb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
% tune_cavities_dir.m - Turns off RF power, measures the four cavities
%                       in a HER station and moves tuners to place all
%                       cavities at resonance (476 MHz). Then applies
%                       CW RF power to allow nulling the cavity phases
%                       and tuner loop phases.
%                                                        Paul 1/21/97
%                       Added measurement of cavity coupler directivies
%                       after coarse tuning is completed.  Directivity
%                       corrections are then written to EPICS database.
%                                                        Paul 3/1/99

% J. Sebek 10/31/2006  - restore original DSP file name if desired one
% cannot be loaded
% MOD: W. Colocho, 06/1/2003 - Made into a function(). It uses handles
% structure to pass data. Called by RFguiInvasive.m

%clear
format compact
%help tune_cavities_dir

fprintf(1,'\n*** Beginning Tuning Cavites with Directivity Correction ***\n');

% here are some configuration strings
gainFactor = get_RFP_noise_gain(station);%RFP module dependent gain
%station = getenv('STATION');
station = handles.station
%rf_data = getenv('RF_DATA');
rf_data = handles.rfData
%rf_mat  = getenv('RFMAT');
rf_module    = [station,':STN:RFP'];

% set this to 1 to allow calculating directivities and then
% writing correction matrix to database
% a 0 setting will take directivity data and store in files for
% offline study but not impliment any directivity correction
do_correction = 1;

noise_I_file = '/dat/NOISE_I_BL'; % file to load into I DAC
noise_Q_file = '/dat/NOISE_Q_BL'; % file to load into Q DAC
% previously measured noise files
measured_I_noise = '/dat/NOISE_I_BL.out';  
measured_Q_noise = '/dat/NOISE_Q_BL.out'; 
% define the measured loop response file names
v_header = '/dat'; % string for the augeas stuff
u_header = [rf_data,'/',station];   % string for the unix stuff
measured_cavity_I = '/CAVITY_I'; 
measured_cavity_Q = '/CAVITY_Q';
DSP_file = ['/dsp/rippleRfp']; % define DSP files

% some config values
combiner_gain = 1900;	% default gain of combining network - LER=1900 HER=1900
hvps_voltage_HER = 58;  % use this value for tuning HER - allows no drive signal
hvps_voltage_LER = 52;  % use this value for tuning LER - allows no drive signal
drive_power = 10;	% default value of drive power after initial tuning is done
noise_I_file = '/dat/NOISE_I_BL'; % file to load into I DAC
noise_Q_file = '/dat/NOISE_Q_BL'; % file to load into Q DAC
measured_I_noise = '/dat/NOISE_I_BL.out';  
measured_Q_noise = '/dat/NOISE_Q_BL.out'; 

max_count = 30;			% maximum number of tries to write data files
max_pass = 100;			% maximum number of tries to tune cavities
delta_f_coarse_max = 20.0;	% maximum coarse cavity tuning error - kHz
delta_f_fine_max = 0.7;		% maximum fine cavity tuning error - kHz
delta_f_directivity = 100;	% maximum frequency offset for measuring directivity - kHz
num_offsets = 4;		% number of offset frequency points used for directivity
delta_degrees = -20;		% phase offset used to measure tuner sensitivity - degrees
f_rf = 476e6;			% rf frequency - Hz
w_rf = f_rf*2*pi;		% rf frequency - radians/sec
fs = 72*f_rf/3492;  		% clock frequency
ts = 1/fs;			% sampling interval
num_data = 2^17;		% set the desired length of the data files
num_fft  = 2^14;		% set the desired length of FFTs
poly_order = 3;			% order of polynomials for cavity frequency vs. position
t  = linspace(0,ts*num_data,num_data);	% time vector
Q_guess = 7000;			% starting value for optimization/fitting
Q0 = 32000;			% unloaded cavity Q - guess for now
Beta = 3.8;			% cavity coupling coefficient
chop=7000;			% how much of the data is chopped off
coef1 = '.A';			% string for use in writing octal DAC coefficients
coef2 = '.C';			% string for use in writing octal DAC coefficients
coef3 = '.E';			% string for use in writing octal DAC coefficients
coef4 = '.G';			% string for use in writing octal DAC coefficients

coefC1 = ['A' 'B' 'E' 'F'];	% strings for use in writing directivity coefficients
coefC2 = ['C' 'D' 'G' 'H'];	% strings for use in writing directivity coefficients
name1 = 'FRWD';			% string for writing forward directivity coefficients
name2 = 'REFL';			% string for writing reflected directivity coefficients

%****************************Change

% determine if the station is a HER (4 cavities) or an LER (2 cavities)
%[status,answer] = caShell(['caget -t -w 20 ', station,':STN:RING:PLC']);
%if status ~=0
%   fprintf(1,'Error - unable to read RF station type\n');
%   return
%end
%if strcmp (answer(1:3),'HER' ) == 1
%   num_cavities = 4;
%elseif strcmp (answer(1:3),'LER' ) == 1
%   num_cavities = 2;
%else
%   fprintf(1,'Error - incorrection station type - not HER or LER\n');
%   return
%end

% determine if the station is 4 cavities or 2 cavities
[status,answer] = system(['caget -t -w 20 ', station,':STN:NCV:PLC']);
if status ~=0
   fprintf(1,'Error - unable to read number of cavities\n');
   return
end
if strcmp (answer(1:3),'4CV' ) == 1
   num_cavities = 4;
elseif strcmp (answer(1:3),'2CV' ) == 1
   num_cavities = 2;
else
   fprintf(1,'Error - incorrect cavity number - not 4CV or 2CV\n');
   return
end


%***********************************************

% parameters for the filter used to smooth the FFT outputs
[B,A] = butter(3,0.100);

% make sure the RF is on - remove carrige return
fprintf(1,'Configuring RF system - please be patient\n');
[status,answer] = caShell(['caget -t -w 20 ', rf_module,':RFENABLE']);
if status ~=0
   fprintf(1,'Error - unable to read RF tune/operate status\n');
   return
end
if strcmp(answer(1:2),'ON') ~= 1
   fprintf(1,'Error - RF must be on to tune cavities\n');
   return
end

% make sure the direct loop is off - remove carrige return
[status,answer] = caShell(['caget -t -w 20 ', station,':STNDIRECT:LOOP:CTRL']);
if status ~=0
   fprintf(1,'Error - unable to read direct loop on/off status\n');
   return
end
if strcmp(answer(1:3),'OFF') ~= 1
   fprintf(1,'Error - Direct loop must be open for this measurement\n');
   return
end

% make sure the comb loop is off - remove carrige return
[status,answer] = caShell(['caget -t -w 20 ', station,':STNCOMB:LOOP:CTRL']);
if status ~=0
   fprintf(1,'Error - unable to read comb loop on/off status\n');
   return
end
if strcmp(answer(1:3),'OFF') ~= 1
   fprintf(1,'Error - Comb loop must be open for this measurement\n');
   return
end

% open the HVPS voltage loop
[status,answer] = caShell(['caput -w 20 ', station,':HVPS:LOOP:CTRL 0']);
if status ~=0
   fprintf(1,'Error - can not disable HVPS loop\n');
   return
end

% set HVPS voltage
fprintf(1,'Setting desired station HVPS operating voltage\n');
if num_cavities == 4,
  [status,answer] = caShell(['caput -w 20 ', station,':HVPS:VOLT:CTRL.VAL ', ...
                           num2str(hvps_voltage_HER)]);
  if status ~=0
     fprintf(1,'Error - can not set HVPS output voltage\n');
     return
  end
else
  [status,answer] = caShell(['caput -w 20 ', station,':HVPS:VOLT:CTRL.VAL ', ...
                           num2str(hvps_voltage_LER)]);
  if status ~=0
     fprintf(1,'Error - can not set HVPS output voltage\n');
     return
  end
end

% make sure the RF is in operate mode - remove carrige return
[status,answer] = caShell(['caput -w 20 ', rf_module,':RUNMODE 1']);
if status ~=0
   fprintf(1,'Error - unable to place RF module in OPERATE mode\n');
   return
end

fprintf(1,'Reading original station drive power setting\n');
% write the desired drive power
[status,answer] = caShell(['caget -t -n -w 20 ', station,':KLYSDRIVFRWD:POWER:ON']);
if status ~=0
   fprintf(1,'Error - can not read original drive power setpoint\n');
   return
end
original_drive_power = str2num(answer); 

fprintf(1,'Writing desired station drive power\n');
% write the desired drive power
[status,answer] = caShell(['caput -w 20 ', station,':KLYSDRIVFRWD:POWER:ON ', num2str(drive_power)]);
if status ~=0
   fprintf(1,'Error - can not load ON_CW drive power setpoint\n');
   return
end

% enable the drive power loop for ON_CW mode
[status,answer] = caShell(['caput -w 20 ', station,':STN:ON:CTRL 1']);
if status ~=0
   fprintf(1,'Error - can not enable drive power loop for ON_CW mode\n');
   return
end

% load default set points into cavity combiner coefficients
fprintf(1,'Loading default values into cavity combining network\n');
for cavity = 1:num_cavities,
  for count = 1:3:4,     
    [status,answer] = caShell(['caput -w 20 ', rf_module,':CAV',num2str(cavity), ...
                      eval(['coef',num2str(count)]),' ', num2str(combiner_gain)]);
    if status ~=0
       fprintf(1,['Error - can not load cavity ',num2str(cavity), ...
                 ' combiner gain ',eval(['coef',num2str(count)]),' coefficient\n']);
       return
    end
  end
  for count = 2:3,     
    [status,answer] = caShell(['caput -w 20 ', rf_module,':CAV',num2str(cavity), ...
                      eval(['coef',num2str(count)]),' ', num2str(0)]);
    if status ~=0
       fprintf(1,['Error - can not load cavity ',num2str(cavity), ...
                 ' combiner gain ',eval(['coef',num2str(count)]),' coefficient\n']);
       return
    end
  end
end

[status,answer] = caShell(['caput -w 20 ', rf_module,':MODU.LOD 1']);
if status ~=0
   fprintf(1,'Error - unable to load RF module octal DAC coefficients\n');
   return
end

% disable tuner loop
fprintf(1,'Deactivating tuner loop\n');
[status,answer] = caShell(['caput -w 20 ', station,':CAVTUNR:LOOP:CTRL 0']);
if status ~=0
   fprintf(1,'Error - can not disable the tuner loop\n');
   return
end

% move the tuners back to home
fprintf(1,['Moving all tuners to HOME position\n']);, ...
[status,answer] = caShell(['caput -w 20 ', station,':CAVTUNR:LOOPON:RESET.PROC 1']);
if status ~=0
   fprintf(1,['Error - unable to HOME tuners\n']);
   return
end

% write the desired length of the data files to the RF module driver
fprintf(1,'Setting data file length\n');
[status,answer] = caShell(['caput -w 20 ', rf_module,':MODU.RMSZ ', num2str(num_data/1024)]);
if status ~=0
   fprintf(1,'Error - can not set the desired file length\n');
   return
end

% make sure the ripple loop is closed - remove carrige return
fprintf(1,'Checking status of RIPPLE loop\n');
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

% place the module in Reset mode
[status,answer] = caShell(['caput -w 20 ', rf_module,':STATE 0']);
if status ~=0
   fprintf(1,'Error - can not place RF module in Reset state\n');
   return
end

% place the module in Load mode
[status,answer] = caShell(['caput -w 20 ', rf_module,':STATE 1']);
if status ~=0
   fprintf(1,'Error - can not place RF module in Load state\n');
   return
end

% see what files are in the DACs - load correct files if necessary
% first do the I DACs
[status,answer] = caShell(['caget -t -w 20 ', rf_module,':MODU.DIRF']);
if status ~=0
   fprintf(1,'Error - unable to read DAC_I filename\n');
   return
end
if strcmp(answer(1:length(answer)-1),noise_I_file) ~= 1
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
      if test ~= 1, pause(1), end;	% sleep for 1 seconds
   end; % end of the while loop
end

% next do the Q DACs
[status,answer] = caShell(['caget -t -w 20 ', rf_module,':MODU.DQRF']);
if status ~=0
   fprintf(1,'Error - unable to read DAC_Q filename\n');
   return
end
if strcmp(answer(1:length(answer)-1),noise_Q_file) ~= 1
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
      if test ~= 1, pause(1), end;	% sleep for 1 seconds
   end; % end of the while loop
end

% write the corrrect file names to save data
[status,answer] = caShell(['caput -t -w 20 ', rf_module,':MODU.CIRF ', ...
                         v_header,measured_cavity_I]);
if status ~=0
   fprintf(1,'Error - unable to write CAV_I filename\n');
   return
end
[status,answer] = caShell(['caput -t -w 20 ', rf_module,':MODU.CQRF ', ...
                         v_header,measured_cavity_Q]);
if status ~=0
   fprintf(1,'Error - unable to write CAV_Q filename\n');
   return
end

% write the corrrect file for the DSP and reload it
[status,answer] = caShell(['caget -t -w 20 ', rf_module,':MODU.DSPE']);
if status ~=0
   fprintf(1,'Error - unable to read DSP filename\n');
   return
end
if strcmp(answer(1:length(answer)),DSP_file) ~= 1
    origFileName = answer;
   fprintf(1,'replacing DSP file %s with %s\n', origFileName, DSP_file );
   [status,answer] = caShell(['caput -t -w 20 ', rf_module,':MODU.DSPE ',DSP_file]);
   if status ~=0
      fprintf(1,'Error - unable to write the DSP filename\n');
      return
   end
   [status,answer] = caShell(['caput -t -w 20 ', rf_module,':MODU.LDSP 1']);
   if status ~=0
      fprintf(1,'Error - unable to load the DSP file %s; restoring %s\n', ...
          DSP_file, origFileName);
       [status,answer] = ...
           caShell(['caput -t -w 20 ', rf_module,':MODU.DSPE ',origFileName]);
       if status ~=0
          fprintf(1,'Error - unable to restore the DSP filename %s\n', ...
              origFileName);
       end
      return
   end
   test = 0;	% force the first pass in the while loop
   count = 0;	% count how many times we look at the status mesasage
   pause(2);	% wait 2 seconds to allow things to start
   while test ~= 1,
      [status,answer] = caShell(['caget -t -w 20 ', rf_module,':MODU.DSTT']);
      count = count +1;
      test = strcmp(answer(1),'N');
      if count > max_count
         fprintf(1,'Error - can not load the DSP file - timed out\n');
         fprintf(1,'  restoring original DSP file name %s\n', origFileName);
           [status,answer] = ...
               caShell(['caput -t -w 20 ', rf_module,':MODU.DSPE ',origFileName]);
           if status ~=0
              fprintf(1,'Error - unable to restore the DSP filename %s\n', ...
                  origFileName);
           end
         return
      end
      if test ~= 1, pause(1), end;	% sleep for 1 seconds
   end; % end of the while loop
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

% turn off the lead compensation
[status,answer] = caShell(['caput -w 20 ', rf_module,':LEADCOMP 0']);
if status ~=0
   fprintf(1,'Error - can not turn off the lead compensation\n');
   return
end

% turn off the integral compensation
[status,answer] = caShell(['caput -w 20 ', rf_module,':INTCOMP 0']);
if status ~=0
   fprintf(1,'Error - can not turn off the integral compensation\n');
   return
end

pass = 0;		% clear the pass counter
max_error = 999;	% set the max_error for first run through cavities

% here is the loop which coarse tunes the cavities
while ((abs(max_error) > delta_f_coarse_max) & (pass < max_pass)),
 pass = pass +1;
 max_error = 0;	% reset the max_error for next run through cavities
 for cavity = 1:num_cavities,

  % set CAVITY multiplexer to variable=cavity-1
  [status,answer] = caShell(['caput -s -w 20 ', rf_module,':CAVSEL ',num2str(cavity)]);
  if status ~=0
     fprintf(1,['Error - can not set the CAVITY signal to ',num2str(cavity),'\n']);
     return
  end

  % place the module in Reset mode
  [status,answer] = caShell(['caput -w 20 ', rf_module,':STATE 0']);
  if status ~=0
     fprintf(1,'Error - can not place RF module in Reset state\n');
     return
  end

  % place the module in Load mode
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
  % read the CAVITY_I file first
  [status,answer] = caShell(['caput -w 20 ', rf_module,':MODU.GCIR 1']);
  if status ~=0
     fprintf(1,'Error - can not activate the CAVITY_I file read\n');
     return
  end
  fprintf(1,'Moving data from I channel to file\n');
  test = 0;	% force the first pass in the while loop
  count = 0;	% count how many times we look at the status mesasage
  pause(2);	% wait 2 seconds to allow things to start
  while test ~= 1,
     [status,answer] = caShell(['caget -t -w 20 ', rf_module,':MODU.CIST']);
     count = count +1;
     test = strcmp(answer(1),'N');
     if count > max_count
        fprintf(1,'Error - can not read the CAVITY_I file - timed out\n');
        return
     end
     if test ~= 1, pause(1), end;	% sleep for 1 seconds
  end; % end of the while loop

  % read the CAVITY_Q file now
  [status,answer] = caShell(['caput -w 20 ', rf_module,':MODU.GCQR 1']);
  if status ~=0
     fprintf(1,'Error - can not activate the CAVITY_Q file read\n');
     return
  end
  fprintf(1,'Moving data from Q channel to file\n');
  test = 0;	% force the first pass in the while loop
  count = 0;	% count how many times we look at the status mesasage
  pause(2);	% wait 2 seconds to allow things to start
  while test ~= 1,
     [status,answer] = caShell(['caget -t -w -20 ', rf_module,':MODU.CQST']);
     count = count +1;
     test = strcmp(answer(1),'N');
     if count > max_count
        fprintf(1,'Error - can not read the CAVITY_Q file - timed out\n');
        return
     end
     if test ~= 1, pause(1), end;	% sleep for 1 seconds
  end; % end of the while loop

  % make the file ID's
  fid1 = -1;
  fid2 = -1;
  while (fid1 == -1), fid1 = fopen([u_header,measured_cavity_I],'r','ieee-be'); end;
  while (fid2 == -1), fid2 = fopen([u_header,measured_cavity_Q],'r','ieee-be'); end;
  if (pass == 1) & (cavity == 1), 		% only read once
  fid3 = -1;
  fid4 = -1;
  while (fid3 == -1), fid3 = fopen([rf_data,measured_I_noise],'r','ieee-be'); end;
  while (fid4 == -1), fid4 = fopen([rf_data,measured_Q_noise],'r','ieee-be'); end;
  end

  % read the measured data files
  [header,count] = fread(fid1,[1,16],'char');
  fprintf(1,'Reading %s%s\n',u_header,measured_cavity_I);
  [i_dat,count] = fread(fid1,[1,inf],'short'); fclose(fid1);
  header = setstr (header);
  if count ~= (num_data)
     ['length of file in ',header,' is incorrect. Length = ',num2str(count)]
     return
  end
  [header,count] = fread(fid2,[1,16],'char');
  fprintf(1,'Reading %s%s\n',u_header,measured_cavity_Q);
  [q_dat,count] = fread(fid2,[1,inf],'short'); fclose(fid2);
  header = setstr (header);
  if count ~= (num_data)
     ['length of file in ',header,' is incorrect. Length = ',num2str(count)]
     return
  end

  i_dat = (fix(i_dat/16))/2047;	% shift data and scale
  q_dat = (fix(q_dat/16))/2047;	% shift data and scale
  out_data = i_dat + j*q_dat;
  out_data = out_data-mean(out_data);
  clear i_dat
  clear q_dat

  if (pass == 1) & (cavity ==1),
    % read the recorded noise files
    [header,count] = fread(fid3,[1,16],'char');
    fprintf(1,'Reading %s\n',measured_I_noise);
    [i_dat,count] = fread(fid3,[1,num_data],'short'); fclose(fid3);
    header          = setstr (header);
    if count ~= (num_data)
       ['length of file in ',header,' is incorrect. Length = ',num2str(count)]
       return
    end
    [header,count] = fread(fid4,[1,16],'char');
    fprintf(1,'Reading %s\n',measured_Q_noise);
    [q_dat,count] = fread(fid4,[1,num_data],'short'); fclose(fid4);
    header          = setstr (header);
    if count ~= (num_data)
       ['length of file in ',header,' is incorrect. Length = ',num2str(count)]
       return
    end

    i_dat = (fix(i_dat/16))/2047;
    q_dat = (fix(q_dat/16))/2047;
     in_data = (i_dat + j*q_dat) / gainFactor;
    clear i_dat
    clear q_dat
  end

  fprintf(1,['Calculating cavity #',num2str(cavity),' transfer function\n']);
  [Hsum,FF]=tfestimate(in_data,out_data,hanning(num_fft),[],num_fft,fs);
  Hsum(1) = Hsum(2);	% ignore the DC term - usually has large errors
  Hsum=Hsum';
  % reorder the results to go from -freq to + freq
  Hsum = [Hsum(num_fft/2+2:num_fft) Hsum(1:num_fft/2+1)]; % reorder by frequency

  magnitude = 20*log10(abs(Hsum));
  phases = angle(Hsum);

  if (pass == 1) & (cavity ==1),
    delta_f=fs/(num_fft);
    baseband_freq=delta_f*[((-1*(num_fft/2 -1)):-1) 0 (1:num_fft/2)];
  end

  %figure(1)
  figHandles = handles.figHandles; % retrieve figure data
  figInd=length(figHandles);
  figInd=figInd+1; figure(figInd); clf; figHandles(figInd) = figInd;
  handles.figHandles = figHandles;
  guidata(handles.output, handles); % update  handles data
  figIndOne = figInd;
  clf
  subplot(211)
  plot(baseband_freq(chop:num_fft-chop)/1e3, ...
       magnitude(chop:num_fft-chop),'r.')
  junk=axis;
  axis([junk(1:2) -30 30])
  grid on 
  title(['Measured Transfer Function of Cavity #',num2str(cavity),' - ',station])
  xlabel('baseband frequency - kHz')
  ylabel('amplitude - dB')

  subplot(212)
  plot(baseband_freq(chop:num_fft-chop)/1e3, ...
       (180/pi)*phases(chop:num_fft-chop),'r.') 
  grid on
  xlabel('baseband frequency - kHz')
  ylabel('phase - degrees')
  %drawnow

  % Script to determine parameters from cavity resonance data
  % and adjust the feedback loop for correct phase margins
  % R. Tighe 12/17/96

  fprintf(1,['Fitting cavity #',num2str(cavity), ...
              ' system parameters to measured data\n']);

  % find the initial center freq to help the fitting function
  ordered_magnitude = magnitude(chop:num_fft-chop);
  ordered_phase = filtfilt(B,A,(phases(chop:num_fft-chop)));
  ordered_freq = baseband_freq(chop:num_fft-chop);
  [value,index] = max(filtfilt(B,A,ordered_magnitude));		% filter to get rid of any spikes
  initial_freq = 476+(ordered_freq(index)/1e6);			% units are MHz
  initial_magnitude = 10^(ordered_magnitude(index+10)/20);	% units are volts/volt
								% offset by 10 to avoid carrier
  initial_phase = (180/pi)*ordered_phase(index);		% units are degrees
  if (initial_phase < 0) initial_phase = initial_phase +360; end;

  % determine the center frequency (Wc) and the loaded Q (Ql)
  w=2*pi*(476+baseband_freq(chop:num_fft-chop)/1e6);	% make w vector
  options(1) = 0; 	% show optimization progess
  options(3) = 1e-6; 	% increase termination requirement for error
  options(14) = 600*length(baseband_freq(chop:num_fft-chop)); 	  % more iterations
  x0 = [initial_freq,6000,initial_magnitude,450,initial_phase];   % initial conditions
  % call the optimization routine to determine center freq, Ql, gain, delay and offset

  [x,options] = constr('cavity_fit',x0,options,[initial_freq-0.1,4000,initial_magnitude/2,350,-10], ...
                        [initial_freq+0.1,8000,initial_magnitude*2,550,400],[],w,w_rf/1e6, ...
                        Hsum(chop:num_fft-chop));

  Wc = x(1)*2*pi;
  Ql = x(2);
  k  = x(3);
  Td = x(4);
  phase_offset = x(5);
  fprintf(1,'Fitted cavity frequency is %7.4f MHz\n',Wc/(2*pi));
  fprintf(1,'Fitted loaded cavity Q is %4.0f\n',Ql);
  fprintf(1,'Fitted loop gain is %3.1f volts/volt\n',k);
  fprintf(1,'Fitted system delay is %3.0f ns\n',Td);
  fprintf(1,'Fitted phase shift is %4.1f degrees\n',phase_offset);

  % make a fitted magnitude vector and plot it on top of the measured data
  fitted_magnitude = 20*log10(abs(k*sqrt(w.^2*Wc^2./ ...
                    (Ql^2*w.^4 + w.^2*Wc.^2 - 2*Ql^2*w.^2*Wc.^2+Ql^2*Wc.^4))));

  % store the maximim gain (V/V) for the fitted cavity magnitude
  fitted_gain(cavity) = 10^(max(fitted_magnitude)/20);

  % make a fitted phase vector and plot it on top of the measured data
  fitted_phase =  (phase_offset*(pi/180)) - (w-w_rf/1e6)*Td/1000 + ...
                   atan((Ql.*(-w.^2 + Wc^2))./(w*Wc));

  % plot the fitted results
  %figure(1)
  figure(figIndOne)
  subplot(211)
  hold on
  plot(baseband_freq(chop:num_fft-chop)/1e3,fitted_magnitude,'b')
  subplot(212)
  hold on
  plot(baseband_freq(chop:num_fft-chop)/1e3, ...
      (180/pi)*angle(exp(j*fitted_phase)),'b')
  %drawnow

  % read the current setting for the cavity baseband modulator
  [status,answer] = caShell(['caget -t -n -w 20 ', rf_module,':CAV',num2str(cavity),'.A']);
  cavity_II = str2num(answer);
  if status ~=0
    fprintf(1,['Error - unable to read cavity #',num2str(cavity),' II coefficient\n']);
    return
  end
  [status,answer] = caShell(['caget -n -t -w 20 ', rf_module,':CAV',num2str(cavity),'.C']);
  cavity_IQ = str2num(answer);
  if status ~=0
    fprintf(1,['Error - unable to read cavity #',num2str(cavity),' IQ coefficient\n']);
    return
  end
  [status,answer] = caShell(['caget -t -n -w 20 ', rf_module,':CAV',num2str(cavity),'.E']);
  cavity_QI = str2num(answer);
  if status ~=0
    fprintf(1,['Error - unable to read cavity #',num2str(cavity),' QI coefficient\n']);
    return
  end
  [status,answer] = caShell(['caget -t -n -w 20 ', rf_module,':CAV',num2str(cavity),'.G']);
  cavity_QQ = str2num(answer);
  if status ~=0
    fprintf(1,['Error - unable to read cavity #',num2str(cavity),' QQ coefficient\n']);
    return
  end

  % calculate the phase and magnitude of the cavity coefficients
  old_phases(cavity)     = (180/pi)*atan2(mean([cavity_IQ, cavity_QI]), ...
                                 mean([cavity_II, cavity_QQ]));
  old_magnitude(cavity) = sqrt((mean([cavity_IQ, cavity_QI]))^2 + ...
                       (mean([cavity_II, cavity_QQ]))^2);

 % calculate the required phase adjustment
  phase_adjust = rem(x(5)+180,360);	% add 180 degrees - it help fitting converge
  fprintf(1,['Changing cavity #',num2str(cavity), ...
             ' phase by %4.1f degrees\n'],phase_adjust);
  new_phases(cavity) = rem(old_phases(cavity) + phase_adjust,360);

  % calculate the new cavity coefficients
  cavity_II = old_magnitude(cavity) * cos((pi/180) * new_phases(cavity));
  cavity_QI = old_magnitude(cavity) * sin((pi/180) * new_phases(cavity));
  cavity_IQ = cavity_QI;	% later we may want to remove modulator errors here
  cavity_QQ = cavity_II;	% and here

  % write the new settings for the direct loop baseband modulator
  [status,answer] = caShell(['caput -t -w 20 ', rf_module,':CAV',num2str(cavity),'.A ', ...
                           num2str(cavity_II)]);
  if status ~=0
     fprintf(1,'Error - unable to write direct loop II coefficient\n');
     return
  end
  [status,answer] = caShell(['caput -t -w 20 ', rf_module,':CAV',num2str(cavity),'.C ', ...
                           num2str(cavity_IQ)]);
  if status ~=0
     fprintf(1,'Error - unable to write direct loop IQ coefficient\n');
     return
  end
  [status,answer] = caShell(['caput -t -w 20 ', rf_module,':CAV',num2str(cavity),'.E ', ...
                           num2str(cavity_QI)]);
  if status ~=0
     fprintf(1,'Error - unable to write direct loop QI coefficient\n');
     return
  end
  [status,answer] = caShell(['caput -t -w 20 ', rf_module,':CAV',num2str(cavity),'.G ', ...
                           num2str(cavity_QQ)]);
  if status ~=0
     fprintf(1,'Error - unable to write direct loop QQ coefficient\n');
     return
  end
  [status,answer] = caShell(['caput -w 20 ', rf_module,':MODU.LOD 1']);
  if status ~=0
     fprintf(1,'Error - unable to load RF module octal DAC coefficients\n');
     return
  end

  % calculate the required tuner movement
  freq_error = (Wc/(2*pi) - 476)*1e3;	% calculate the freq error from 476 (kHz)
  max_error = max([max_error,abs(freq_error)]);
  fprintf(1,['Tuning error for cavity #',num2str(cavity),' = ' ...
              num2str(freq_error),' kHz\n']);
  [status,answer] = caShell(['caget -t -w 20 ', station,':CAV',num2str(cavity), ...
                          'TUNR:POSN:DELTA.C']);
  mm_per_degree = str2num(answer);
  if status ~=0
    fprintf(1,['Error - unable to read cavity #',num2str(cavity),' tuner sensitivity\n']);
    return
  end
  delta_mm = freq_error * (90/((476e3)/Ql)) * (-1*mm_per_degree);  

  % get the present tuner position and calculate the new position
  [status,answer] = caShell(['caget -t -w 20 ', station,':CAV',num2str(cavity), ...
                          'TUNR:STEP:MOTOR.RBV']);
  present_mm = str2num(answer);
  if status ~=0
    fprintf(1,['Error - unable to read cavity #',num2str(cavity),' tuner position\n']);
    return
  end
  new_position = present_mm + delta_mm;

  % move the tuner
  fprintf(1,['Moving cavity #',num2str(cavity),' tuner by ',num2str(delta_mm),' mm\n']);
  [status,answer] = caShell(['caput -w 20 ', station,':CAV',num2str(cavity),'TUNR:POSN:CTRL ', ...
                           num2str(new_position)]);
  if status ~=0
     fprintf(1,['Error - unable to change cavity #',num2str(cavity),' tuner position\n']);
     return
  end
  freq_hist(pass,cavity)   = freq_error;	% save tuning history for diagnostic
  tuning_hist(pass,cavity) = delta_mm;		% save tuner movement for diagnostic
 end	% end of the cavity 1 to num_cavities loop

 % plot the tuning freq_history - not on the first pass
 if pass > 1
   %figure(2)
   figHandles = handles.figHandles; % retrieve figure data
   figInd=length(figHandles);
   figInd=figInd+1; figure(figInd); clf; figHandles(figInd) = figInd;
   handles.figHandles = figHandles;
   guidata(handles.output, handles); % update  handles data
   figIndTwo = figInd;
   clf
   subplot(211)
   plot(freq_hist)
   hold on
   plot(freq_hist,'*')
   title(['Tuning History for All Cavities - ',station])
   xlabel('Iteration Number')
   ylabel('Tuning Error - kHz')
   grid on
   subplot(212)
   plot(tuning_hist)
   hold on
   plot(tuning_hist,'*')
   xlabel('Iteration Number')
   ylabel('Tuner Movement - mm')
   grid on
 end


end	% end of the while loop - max = max_pass

if ((pass > max_pass) & (abs(max_error) > delta_f_coarse_max))
  fprintf(1,['Error - failed to tune cavities in ',num2str(pass),' passes\n']);
  return
else
  fprintf(1,['\nCavities tuned to within ', num2str(max_error),' kHz in ', ...
               num2str(pass),' passes\n\n']);
end

% At this point cavities are within delta_f_coarse_max kHz of 476.  Now we null the tuner
% loop phase offsets, activate tuner loop and enter cavity frequency fine tuning loop.
% Tuner loop will prevent drift due to variations in cavity water temperature.

% read each cavity probe phase and forward phase and enter the necessary offset for 
% each to null transmission phase
for cavity = 1:num_cavities,

  fprintf(1,['Nulling cavity phase measurements for cavity #', num2str(cavity),'\n']);
  % set the cavity loading angle offset to zero and update data base
  [status,answer] = caShell(['caput -w 20 ', station,':CAV',num2str(cavity), ...
                          'LOAD:ANGLE:OFFS.D ', num2str(0)]);
  if status ~=0
     fprintf(1,['Error - unable to zero cavity #',num2str(cavity), ...
               ' loading angle offset\n']);
     return
  end
  % set the probe phase offset to zero and update data base
  [status,answer] = caShell(['caput -w 20 ', station,':CAV',num2str(cavity), ...
                          'PROBE:PHASE:OFFS ', num2str(0)]);
  if status ~=0
     fprintf(1,['Error - unable to set cavity #',num2str(cavity), ...
               ' probe phase offset\n']);
     return
  end
  pause(1);	% wait for the database to update
  % read the current setting for the cavity probe phase 
  [status,answer] = caShell(['caget -t -n -w 20 ', station,':CAV',num2str(cavity),'PROBE:PHASE']);
  probe_phases(cavity) = str2num(answer);
  if status ~=0
    fprintf(1,['Error - unable to read cavity #',num2str(cavity),' probe phase\n']);
    return
  end
  % calculate the probe phase offset and update data base
  new_probe_phase_offset(cavity) = -probe_phases(cavity);
  [status,answer] = caShell(['caput -w 20 ', station,':CAV',num2str(cavity), ...
                          'PROBE:PHASE:OFFS ', num2str(new_probe_phase_offset(cavity))]);
  if status ~=0
     fprintf(1,['Error - unable to change cavity #',num2str(cavity), ...
               ' probe phase offset\n']);
     return
  end

  % set the cavity forward phase offset to zero and update data base
  [status,answer] = caShell(['caput -w 20 ', station,':CAV',num2str(cavity), ...
                          'FRWD:PHASE:OFFS ', num2str(0)]);
  if status ~=0
     fprintf(1,['Error - unable to change cavity #',num2str(cavity), ...
               ' forward phase offset\n']);
     return
  end
  pause(1);	% wait for the database to update
  % read the current setting for the cavity forward phase 
  [status,answer] = caShell(['caget -t -n -w 20 ', station,':CAV',num2str(cavity),'FRWD:PHASE']);
  forward_phases(cavity) = str2num(answer);
  if status ~=0
    fprintf(1,['Error - unable to read cavity #',num2str(cavity),' forward phase\n']);
    return
  end
  % calculate the new probe phase offset and update data base
  new_forward_phase_offset(cavity) = -forward_phases(cavity);
  [status,answer] = caShell(['caput -w 20 ', station,':CAV',num2str(cavity), ...
                          'FRWD:PHASE:OFFS ', num2str(new_forward_phase_offset(cavity))]);
  if status ~=0
     fprintf(1,['Error - unable to change cavity #',num2str(cavity), ...
               ' forward phase offset\n']);
     return
  end

  % set the cavity reflected phase offset to zero and update data base
  [status,answer] = caShell(['caput -w 20 ', station,':CAV',num2str(cavity), ...
                          'REFL:PHASE:OFFS ', num2str(0)]);
  if status ~=0
     fprintf(1,['Error - unable to change cavity #',num2str(cavity), ...
               ' reflected phase offset\n']);
     return
  end
  pause(1);	% wait for the database to update
  % read the current setting for the cavity reflected phase 
  [status,answer] = caShell(['caget -t -n -w 20 ', station,':CAV',num2str(cavity),'REFL:PHASE']);
  reflected_phases(cavity) = str2num(answer);
  if status ~=0
    fprintf(1,['Error - unable to read cavity #',num2str(cavity),' reflected phase\n']);
    return
  end
  % calculate the new reflected phase offset and update data base
  new_reflected_phase_offset(cavity) = -reflected_phases(cavity);
  [status,answer] = caShell(['caput -w 20 ', station,':CAV',num2str(cavity), ...
                          'REFL:PHASE:OFFS ', num2str(new_reflected_phase_offset(cavity))]);
  if status ~=0
     fprintf(1,['Error - unable to change cavity #',num2str(cavity), ...
               ' reflected phase offset\n']);
     return
  end

end	% end of cavity loop to null phase offsets

% turn tuner loop to "ON" mode - enable loop
fprintf(1,'Activating tuner loop\n');
[status,answer] = caShell(['caput -w 20 ', station,':CAVTUNR:LOOP:CTRL 1']);
if status ~=0
   fprintf(1,'Error - can not enable the tuner loop\n');
   return
end

% at this point cavities are tuned to the coarse value and the tuner loop
% is activated.  we now measure each cavity at the present "coarse" frequency
% and then +/- delta_f_directivity using num_offsets measurements.  the
% data is fit using coupler_model.m to determine both forward and reflected
% directivity.  corrections are calculated and written to the EPICS database.
% cavity frequency is the restored to "coarse" value and cavity tuning
% procedure is resumed.

% make a list of the desired cavity frequency offsets
freq_offset = [0,-delta_f_directivity*[1:num_offsets]/num_offsets, ...
                  delta_f_directivity*[1:num_offsets]/num_offsets];

for cavity = 1:num_cavities,
  fprintf(1,['\nMeasuring Coupler Directivity for Cavity #',num2str(cavity),'\n'])
  for num_measure = 1:length(freq_offset),
    % remember the original loading angle offset and then set to 75 degrees
    if num_measure == 1
      % remember the current maximum loading angle offset
      [status,answer] = caShell(['caget -t -w 20 ', station,':CAV',num2str(cavity), ...
                              'LOAD:ANGLE:OFFS.C']);
      original_offset_limit(cavity) = str2num(answer);
      if status ~=0
        fprintf(1,['Error - unable to read cavity #',num2str(cavity), ...
                  ' loading angle offset limit\n']);
        return
      end
      % set the maximum loading angle offset limit to 75 degrees
      [status,answer] = caShell(['caput -w 20 ', station,':CAV',num2str(cavity), ...
                              'LOAD:ANGLE:OFFS.C ', num2str(75)]);
      if status ~=0
         fprintf(1,['Error - unable to set cavity #',num2str(cavity), ...
                   ' loading angle offset limit\n']);
         return
      end
    else

      % convert phase offset from desired freq_offset note we use Ql
      % from last cavity fit, since first measurment skipped this block it's OK
      delta_offset_phase = (180/pi)*atan(2*Ql*freq_offset(num_measure)/(f_rf/1e3));	
    
      % offset the loading angle by delta_offset_phase degrees
      [status,answer] = caShell(['caput -w 20 ', station,':CAV',num2str(cavity), ...
                              'LOAD:ANGLE:OFFS.D ',num2str(delta_offset_phase)]);
      if status ~=0
         fprintf(1,['Error - unable to change cavity #',num2str(cavity), ...
                           ' loading angle offset\n']);
         return
      end
      fprintf(1,['\nOffsetting cavity #',num2str(cavity),' frequency by %4.1f kHz\n'],...
                  freq_offset(num_measure))
      % wait for the tuners to move and tuner polynomials to settle
      pause(30)
    end

    % measure the cavity frequency
    % set CAVITY multiplexer to variable=cavity-1
    [status,answer] = caShell(['caput -s -w 20 ', rf_module,':CAVSEL ',num2str(cavity)]);
    if status ~=0
       fprintf(1,['Error - can not set the CAVITY signal to ',num2str(cavity),'\n']);
       return
    end

    % place the module in Reset mode
    [status,answer] = caShell(['caput -w 20 ', rf_module,':STATE 0']);
    if status ~=0
       fprintf(1,'Error - can not place RF module in Reset state\n');
       return
    end

    % place the module in Load mode
    [status,answer] = caShell(['caput -w 20 ', rf_module,':STATE 1']);
    if status ~=0
       fprintf(1,'Error - can not place RF module in Load state\n');
       return
    end

    % take a single shot of data - go to run mode
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
    % read the CAVITY_I file first
    [status,answer] = caShell(['caput -w 20 ', rf_module,':MODU.GCIR 1']);
    if status ~=0
       fprintf(1,'Error - can not activate the CAVITY_I file read\n');
       return
    end
    fprintf(1,'Moving data from I channel to file\n');
    test = 0;	% force the first pass in the while loop
    count = 0;	% count how many times we look at the status mesasage
    pause(2);	% wait 2 seconds to allow things to start
    while test ~= 1,
       [status,answer] = caShell(['caget -t -w 20 ', rf_module,':MODU.CIST']);
       count = count +1;
       test = strcmp(answer(1),'N');
       if count > max_count
          fprintf(1,'Error - can not read the CAVITY_I file - timed out\n');
          return
       end
       if test ~= 1, pause(1), end;	% sleep for 1 seconds
    end; % end of the while loop

    % read the CAVITY_Q file now
    [status,answer] = caShell(['caput -w 20 ', rf_module,':MODU.GCQR 1']);
    if status ~=0
       fprintf(1,'Error - can not activate the CAVITY_Q file read\n');
       return
    end
    fprintf(1,'Moving data from Q channel to file\n');
    test = 0;	% force the first pass in the while loop
    count = 0;	% count how many times we look at the status mesasage
    pause(2);	% wait 2 seconds to allow things to start
    while test ~= 1,
       [status,answer] = caShell(['caget -t -w 20 ', rf_module,':MODU.CQST']);
       count = count +1;
       test = strcmp(answer(1),'N');
       if count > max_count
          fprintf(1,'Error - can not read the CAVITY_Q file - timed out\n');
          return
       end
       if test ~= 1, pause(1), end;	% sleep for 1 seconds
    end; % end of the while loop

    % make the file ID's
    fid1 = -1;
    fid2 = -1;
    while (fid1 == -1), fid1 = fopen([u_header,measured_cavity_I],'r','ieee-be'); end;
    while (fid2 == -1), fid2 = fopen([u_header,measured_cavity_Q],'r','ieee-be'); end;

    % read the measured data files
    [header,count] = fread(fid1,[1,16],'char');
    fprintf(1,'Reading %s%s\n',u_header,measured_cavity_I);
    [i_dat,count] = fread(fid1,[1,inf],'short'); fclose(fid1);
    header = setstr (header);
    if count ~= (num_data)
       ['length of file in ',header,' is incorrect. Length = ',num2str(count)]
       return
    end
    [header,count] = fread(fid2,[1,16],'char');
    fprintf(1,'Reading %s%s\n',u_header,measured_cavity_Q);
    [q_dat,count] = fread(fid2,[1,inf],'short'); fclose(fid2);
    header = setstr (header);
    if count ~= (num_data)
       ['length of file in ',header,' is incorrect. Length = ',num2str(count)]
       return
    end

    i_dat = (fix(i_dat/16))/2047;	% shift data and scale
    q_dat = (fix(q_dat/16))/2047;	% shift data and scale
    out_data = i_dat + j*q_dat;
    clear i_dat
    clear q_dat

    fprintf(1,['Calculating cavity #',num2str(cavity),' transfer function\n']);
    [Hsum,FF]=tfestimate(in_data,out_data,hanning(num_fft),[],num_fft,fs);
    Hsum=Hsum';
    % reorder the results to go from -freq to + freq
    Hsum = [Hsum(num_fft/2+2:num_fft) Hsum(1:num_fft/2+1)]; % reorder by frequency

    magnitude = 20*log10(abs(Hsum));	% filter the data
    phases = angle(Hsum);	% filter the data

    %figure(1)
    figure(figIndOne)
    clf
    subplot(211)
    plot(baseband_freq(chop:num_fft-chop)/1e3, ...
         magnitude(chop:num_fft-chop),'r.')
    junk=axis;
    axis([junk(1:2) -30 30])
    grid on 
    title(['Measured Transfer Function of Cavity #',num2str(cavity),' - ',station])
    xlabel('baseband frequency - kHz')
    ylabel('amplitude - dB')

    subplot(212)
    plot(baseband_freq(chop:num_fft-chop)/1e3, ...
         (180/pi)*phases(chop:num_fft-chop),'r.') 
    grid on
    xlabel('baseband frequency - kHz')
    ylabel('phase - degrees')
    %drawnow

    % Script to determine parameters from cavity resonance data
    % and adjust the feedback loop for correct phase margins
    % R. Tighe 12/17/96

    fprintf(1,['Fitting cavity #',num2str(cavity), ...
                ' system parameters to measured data\n']);

    % find the initial center freq to help the fitting function
    ordered_magnitude = magnitude(chop:num_fft-chop);
    [value,index] = max(filtfilt(B,A,ordered_magnitude));	% filter to remove any spikes
    initial_magnitude = 10^(ordered_magnitude(index+10)/20);	% units are volts/volt
								% offset by 10 to avoid carrier

    % determine the center frequency (Wc) and the loaded Q (Ql)
    w=2*pi*(476+baseband_freq(chop:num_fft-chop)/1e6);	% make w vector
    options(1) = 0; 	% show optimization progess
    options(3) = 1e-6; 	% increase termination requirement for error
    options(14) = 600*length(baseband_freq(chop:num_fft-chop));     % more iterations
    x0 = [476,6000,initial_magnitude,450,180]; % initial conditions
    % call the optimization routine to determine center freq, Ql, gain, delay and offset

    [x,options] = constr('cavity_fit',x0,options,[475.70,4000,.1,350,-10], ...
                          [476.30,8000,50,550,400],[],w,w_rf/1e6,Hsum(chop:num_fft-chop));

    Wc = x(1)*2*pi;
    Ql = x(2);
    k  = x(3);
    Td = x(4);
    phase_offset = x(5);
    fprintf(1,'Fitted cavity frequency is %7.4f MHz\n',Wc/(2*pi));
    fprintf(1,'Fitted loaded cavity Q is %4.0f\n',Ql);
    fprintf(1,'Fitted loop gain is %3.1f volts/volt\n',k);
    fprintf(1,'Fitted system delay is %3.0f ns\n',Td);
    fprintf(1,'Fitted phase shift is %4.1f degrees\n',phase_offset);

    % make a fitted magnitude vector and plot it on top of the measured data
    fitted_magnitude = 20*log10(abs(k*sqrt(w.^2*Wc^2./ ...
                      (Ql^2*w.^4 + w.^2*Wc.^2 - 2*Ql^2*w.^2*Wc.^2+Ql^2*Wc.^4))));

    % make a fitted phase vector and plot it on top of the measured data
    fitted_phase =  (phase_offset*(pi/180)) - (w-w_rf/1e6)*Td/1000 + ...
                     atan((Ql.*(-w.^2 + Wc^2))./(w*Wc));

    % plot the fitted results
    %figure(1)
    figure(figIndOne)
    subplot(211)
    hold on
    plot(baseband_freq(chop:num_fft-chop)/1e3,fitted_magnitude,'b')
    subplot(212)
    hold on
    plot(baseband_freq(chop:num_fft-chop)/1e3, ...
        (180/pi)*angle(exp(j*fitted_phase)),'b')
    %drawnow

    % store the measured cavity frequency 
    freq_cavity(num_measure) = x(1);	% measured cavity frequency - MHz

    % measure the cavity forward vector in IQA volts scaled by IQ conversion loss
    % first read in the I counts
    [status,answer] = caShell(['caget -t -w 20 ', station,':CAV',num2str(cavity), ...
                            'FRWD:SCLIQ.J']);
    I_scaled = str2num(answer);
    if status ~=0
      fprintf(1,['Error - unable to read cavity #',num2str(cavity), ...
                ' forward I scaled\n']);
      return
    end
    % now read in the Q IQA volts scaled by IQ conversion loss
    [status,answer] = caShell(['caget -t -w 20 ', station,':CAV',num2str(cavity), ...
                            'FRWD:SCLIQ.K']);
    Q_scaled = str2num(answer);
    if status ~=0
      fprintf(1,['Error - unable to read cavity #',num2str(cavity), ...
                ' forward Q scaled\n']);
      return
    end   
    % rotate the I&Q_scaled values by the forward phase offsets
    I_rotated = I_scaled*( cos((pi/180)*(-forward_phases(cavity)))) + ...
                Q_scaled*(-sin((pi/180)*(-forward_phases(cavity))));
    Q_rotated = Q_scaled*( cos((pi/180)*(-forward_phases(cavity)))) + ...
                I_scaled*( sin((pi/180)*(-forward_phases(cavity))));
    % calculate the forward corrected complex vector and store
    measured_forward(num_measure) = (I_rotated + j*Q_rotated);

    % measure the cavity reflected vector in IQA raw counts
    % first read in the I voltage scaled by IQA conversion loss
    [status,answer] = caShell(['caget -t -w 20 ', station,':CAV',num2str(cavity), ...
                            'REFL:SCLIQ.J']);
    I_scaled = str2num(answer);
    if status ~=0
      fprintf(1,['Error - unable to read cavity #',num2str(cavity), ...
                ' reflected I scaled\n']);
      return
    end
    % now read in the Q counts
    [status,answer] = caShell(['caget -t -w 20 ', station,':CAV',num2str(cavity), ...
                            'REFL:SCLIQ.K']);
    Q_scaled = str2num(answer);
    if status ~=0
      fprintf(1,['Error - unable to read cavity #',num2str(cavity), ...
                ' reflected Q scaled\n']);
      return
    end
    % rotate the I&Q_scaled values by the reflected phase offsets
    I_rotated = I_scaled*( cos((pi/180)*(-reflected_phases(cavity)))) + ...
                Q_scaled*(-sin((pi/180)*(-reflected_phases(cavity))));
    Q_rotated = Q_scaled*( cos((pi/180)*(-reflected_phases(cavity)))) + ...
                I_scaled*( sin((pi/180)*(-reflected_phases(cavity))));
    % calculate the reflected corrected complex vector and store
    measured_reflected(num_measure) = (I_rotated + j*Q_rotated);

    % measure the cavity probe vector in scaled units
    % first read in the I voltage scaled by IQA conversion loss
    [status,answer] = caShell(['caget -t -w 20 ', station,':CAV',num2str(cavity), ...
                            'PROBE:AMPL']);
    ampl_scaled = str2num(answer);
    if status ~=0
      fprintf(1,['Error - unable to read cavity #',num2str(cavity), ...
                ' probe amplitude scaled\n']);
      return
    end
    % now read in the phase
    [status,answer] = caShell(['caget -t -w 20 ', station,':CAV',num2str(cavity), ...
                            'PROBE:PHASE']);
    phase_scaled = str2num(answer);
    if status ~=0
      fprintf(1,['Error - unable to read cavity #',num2str(cavity), ...
                ' probe phase\n']);
      return
    end
    % calculate the cavity probe complex vector and store
    measured_probe(num_measure) = ampl_scaled * exp(j*(pi/180)*phase_scaled);

  end % end of loop measuring the cavity frequencies, forward and reflected vectors

  % save the directivity data so we can study it offline later
  fprintf(1,['\nSaving Coupler Directivity Data for Cavity #',num2str(cavity),'\n'])
  eval(['save dir_',station,'_',num2str(cavity), ...
        '.mat freq_cavity measured_forward measured_reflected measured_probe;']);

  if do_correction
  fprintf(1,['\nFitting Coupler Directivity for Cavity #',num2str(cavity),' to Model\n'])

  % now we call the optimization routine to calculate forward & reflected directivity
  % make the initial guess vector
  x0 = [0.1,0,0.05,0,1.0,0,0.1,0,1.0,0,300,0,3.9,35];
       % x0(1)  forward directivity (magnitude)
       % x0(2)  forward directivity (phase)
       % x0(3)  reflected directivity (magnitude)
       % x0(4)  reflected directivity (phase)
       % x0(5)  constant RF before TEE (magnitude)
       % x0(6)  constant RF before TEE (phase)
       % x0(7)  magic tee reflection coefficient (magnitude)
       % x0(8)  magic tee reflection coefficient (phase)
       % x0(9)  reflected coupler error (magnitude)
       % x0(10) reflected coupler error (phase)  
       % x0(11) probe coupler error (magnitude)
       % x0(12) probe coupler error (phase)  
       % x0(13) cavity coupling factor
       % x0(14) unloaded cavity Q/1000 

  % configure any options
  options(1)  = 1;	% show optimization in progress
  options(2)  = 1e-6;	% tighten the termination tolerance on X
  options(3)  = 1e-6;	% tighten the termination tolerance on F(X)
  options(14) = 10000;	% maximum function evaluations
  options(17) = 1e-2;	% maximum change when using finite difference

  % define the search boundries
  lower_bound = [-0.2,-400,-0.2,-400,-0.5,-400,-0.2,-400,0.5,-400,100,-400,3.8,30];
  upper_bound = [ 0.2, 400, 0.2, 400, 2.0, 400, 0.2, 400,2.0, 400,400, 400,4.2,40];

  [x,options] = constr('coupler_model_new',x0,options,lower_bound,upper_bound,[], ...
                        freq_cavity,measured_forward,measured_reflected,measured_probe);

  x(14) = x(14)*1000;    % restore the Q0 variable back to true scale

  % display the results - calculations are OK with negative magnitude
  fprintf(1,['\nFitted forward directivity   = %3.1f dB at %3.1f degrees\n'],...
             -20*log10(abs(x(1))),(180/pi)*angle(x(1)*exp(j*(pi/180)*x(2))));
  fprintf(1,['Fitted reflected directivity = %3.1f dB at %3.1f degrees\n'],...
             -20*log10(abs(x(3))),(180/pi)*angle(x(3)*exp(j*(pi/180)*x(4))));
  fprintf(1,['Fitted constant RF           = %1.3f    at %3.1f degrees\n'],...
             abs(x(5)),(180/pi)*angle(x(5)*exp(j*(pi/180)*x(6))));
  fprintf(1,['Fitted magic tee reflection  = %3.1f dB at %3.1f degrees\n'],...
              20*log10(abs(x(7))),(180/pi)*angle(x(7)*exp(j*(pi/180)*x(8))));
  fprintf(1,['Fitted reflected coupling error = %1.3f V/V at %3.1f degrees\n'],...
              abs(x(9)),(180/pi)*angle(x(9)*exp(j*(pi/180)*x(10))));
  fprintf(1,['Fitted probe coupling error = %1.3f V/V at %3.1f degrees\n'],...
              abs(x(11)),(180/pi)*angle(x(11)*exp(j*(pi/180)*x(12))));
  fprintf(1,['Fitted cavity Beta = %1.3f\n'],x(13))
  fprintf(1,['Fitted cavity unloaded Q = %6.1f\n'],x(14))

  fprintf(1,['Writing forward directivity to database\n'])
  [status,answer] = caShell(['caput -w 20 ', station,':CAV',num2str(cavity),...
                          'FRWD:DRCTVTY:DB ',num2str(-20*log10(abs(x(1))))]);
  [status,answer] = caShell(['caput -w 20 ', station,':CAV',num2str(cavity),...
                          'FRWD:DRCTVTY:PHASE ',num2str((180/pi)* ...
                           angle(x(1)*exp(j*(pi/180)*x(2))))]);

  fprintf(1,['Writing reflected directivity to database\n'])
  [status,answer] = caShell(['caput -w 20 ', station,':CAV',num2str(cavity),...
                          'REFL:DRCTVTY:DB ',num2str(-20*log10(abs(x(3))))]);
  [status,answer] = caShell(['caput -w 20 ', station,':CAV',num2str(cavity),...
                          'REFL:DRCTVTY:PHASE ',num2str((180/pi)* ...
                           angle(x(3)*exp(j*(pi/180)*x(4))))]);

  fprintf(1,['\nWriting cavity Beta to database\n'])
  [status,answer] = caShell(['caput -w 20 ', station,':CAV',num2str(cavity),...
                          ':BETA:CTRL ',num2str(x(13))]);
  fprintf(1,['Writing cavity unloaded Q to database\n'])
  [status,answer] = caShell(['caput -w 20 ', station,':CAV',num2str(cavity),...
                          ':Q0:CTRL ',num2str(x(14))]);

  % generate the fitted complex scale factors alpha and zeta 
  alpha = x(9)  * exp(j*(pi/180)*x(10));       % factor for reflected coupler errors
  zeta  = x(11) * exp(j*(pi/180)*x(12));       % factor for probe coupler scaling

  %  make the fitted constant RF vector and fitted magic TEE reflection coefficient
  constant_forward = x(5) * exp(j*(pi/180)*x(6)); % constant RF before magic tee
  TEE_reflection = x(7) * exp(j*(pi/180)*x(8)); % magic tee reflection coefficient

  % next we calculate the complex correction matrix
  correction_matrix = inv([1 x(1)*exp(j*(pi/180)*x(2)); x(3)*exp(j*(pi/180)*x(4)) 1]);

  % include the correction for the reflected coupler errors
  correction_matrix(:,2) = 1/alpha * correction_matrix(:,2);

  % calculate the corrected vectors and plot
  corrected_forward   = correction_matrix(1,:) * [measured_forward; measured_reflected];
  corrected_reflected = correction_matrix(2,:) * [measured_forward; measured_reflected];

  % calculate the forward RF based on the fitted model and the measured probe signal
  s = j*2*pi*476;	% RF frequency of the system - complex MHz
  w_cavity = 2*pi*freq_cavity;	% measured cavity frequency vector rads/sec
  cavity_model = ((x(13)) .* w_cavity .*s) ./ ...
                 (x(14)*(s^2 + (w_cavity/(x(14))*s + w_cavity.^2))); % cavity impedance
  cavity_model = conj(cavity_model);  % conjugate to match IQA detector where
                                      % more delay gives + phase  
  reflection = ((cavity_model - 1) ./ (cavity_model + 1));% cavity reflection coefficient
  transmission = ((2*cavity_model)./(cavity_model + 1));		% cavity transmission

  % generated the calculated signals to compare with the measured ones
  first_reflected = constant_forward .* reflection;
  second_forward  = first_reflected * TEE_reflection;
  calculated_forward   = constant_forward + second_forward;
  calculated_reflected = calculated_forward .* reflection;

  %figure(3)
  figHandles = handles.figHandles; % retrieve figure data
  figInd=length(figHandles);
  figInd=figInd+1; figure(figInd); clf; figHandles(figInd) = figInd;
  handles.figHandles = figHandles;
  guidata(handles.output, handles); % update  handles data
  clf
  subplot(211)
  plot((freq_cavity - 476)*1000,abs(measured_forward) ,'b+', ...
       (freq_cavity - 476)*1000,abs(corrected_forward),'rx', ...
       (freq_cavity - 476)*1000,abs(calculated_forward),'mo')
  grid on
  xlabel('cavity offset frequency - kHz')
  ylabel('magnitude')
  title(['Cavity Forward Directivity Measurements ',station,' Cavity #',num2str(cavity)])
  legend('measured','corrected','model',0)
  subplot(212)
  plot((freq_cavity - 476)*1000,(180/pi)*angle(measured_forward) ,'b+', ...
       (freq_cavity - 476)*1000,(180/pi)*angle(corrected_forward),'rx', ...
     (freq_cavity - 476)*1000,(180/pi)*angle(calculated_forward),'mo')
  grid on
  xlabel('cavity offset frequency - kHz')
  ylabel('phase - degrees')
  %drawnow

  %figure(4)
  figHandles = handles.figHandles; % retrieve figure data
  figInd=length(figHandles);
  figInd=figInd+1; figure(figInd); figHandles(figInd) = figInd;
  handles.figHandles = figHandles;
  guidata(handles.output, handles); % update  handles data
  clf
  subplot(211)
  plot((freq_cavity - 476)*1000,abs(measured_reflected) ,'b+', ...
       (freq_cavity - 476)*1000,abs(corrected_reflected),'rx', ...
       (freq_cavity - 476)*1000,abs(calculated_reflected),'mo')
  grid on
  xlabel('cavity offset frequency - kHz')
  ylabel('magnitude')
  title(['Cavity Reflected Directivity Measurements ',station,' Cavity #',num2str(cavity)])
  legend('measured','corrected','model',0)
  subplot(212)
  plot((freq_cavity - 476)*1000,(180/pi)*angle(measured_reflected) ,'b+', ...
       (freq_cavity - 476)*1000,(180/pi)*angle(corrected_reflected),'rx', ...
       (freq_cavity - 476)*1000,(180/pi)*angle(calculated_reflected),'mo')
  grid on
  xlabel('cavity offset frequency - kHz')
  ylabel('phase - degrees')
  %drawnow

  fprintf(1,['Writing cavity #',num2str(cavity),' directivity correction matrix\n'])
  % here is the nested loops to write the correction matrix to EPICS in IQ form
  for row = 1:2
  name_out = eval(['name',num2str(row)]);      % name is forward or reflected result
  for column = 1:2  
  name_in  = eval(['name',num2str(column)]);   % name2 is forward or reflected input
    [status,answer] = caShell(['caput -w 20 ', station,':CAV',num2str(cavity), ...
                             name_out,':IQ.',eval(['coefC',num2str(column),'(1)',]), ...
                             ' ' num2str(real(correction_matrix(row,column))) ]);
    if status ~=0
       fprintf(1,['Error - can not load cavity ',num2str(cavity), ...
                 ' I ',name_in,' to I ',name_out,' directivity coefficient\n']);
       return
    end
    [status,answer] = caShell(['caput -w 20 ', station,':CAV',num2str(cavity), ...
                             name_out,':IQ.',eval(['coefC',num2str(column),'(2)',]), ...
                             ' ' num2str(-imag(correction_matrix(row,column))) ]);
    if status ~=0
       fprintf(1,['Error - can not load cavity ',num2str(cavity), ...
                 ' Q ',name_in,' to I ',name_out,' directivity coefficient\n']);
       return
    end
    [status,answer] = caShell(['caput -w 20 ', station,':CAV',num2str(cavity), ...
                             name_out,':IQ.',eval(['coefC',num2str(column),'(3)',]), ...
                             ' ' num2str(imag(correction_matrix(row,column))) ]);
    if status ~=0
       fprintf(1,['Error - can not load cavity ',num2str(cavity), ...
                 ' I ',name_in,' to Q ',name_out,' directivity coefficient\n']);
       return
    end
    [status,answer] = caShell(['caput -w 20 ', station,':CAV',num2str(cavity), ...
                             name_out,':IQ.',eval(['coefC',num2str(column),'(4)',]), ...
                             ' ' num2str(real(correction_matrix(row,column))) ]);
    if status ~=0
       fprintf(1,['Error - can not load cavity ',num2str(cavity), ...
                 ' Q ',name_in,' to Q ',name_out,' directivity coefficient\n']);
       return
    end
  end	% end of column loop
  end	% end of row loop

  end % of "do_correction" if statement

  % set the loading angle back to zero degrees
  [status,answer] = caShell(['caput -w 20 ', station,':CAV',num2str(cavity), ...
                          'LOAD:ANGLE:OFFS.D ',num2str(0)]);
  if status ~=0
     fprintf(1,['Error - unable to set cavity #',num2str(cavity), ...
                       ' loading angle offset back to zero degrees\n']);
     return
  end

  % restore the original maximum loading angle offset limit
  [status,answer] = caShell(['caput -w 20 ', station,':CAV',num2str(cavity), ...
                          'LOAD:ANGLE:OFFS.C ', num2str(original_offset_limit(cavity))]);
  if status ~=0
     fprintf(1,['Error - unable to restore cavity #',num2str(cavity), ...
               ' loading angle offset limit\n']);
     return
  end
end	% end of the cavity directivity correction stuff (cavity loop)

fprintf(1,['\nCoupler directivity correction complete - resuming cavity tuning\n'])
% here is the loop which fine tunes the cavities
% force one pass through the fine tuning loop
max_error = 999;
while ((abs(max_error) > delta_f_fine_max) & (pass < max_pass)),
 pass = pass +1;
 max_error = 0;	% reset the max_error for next run through cavities
 for cavity = 1:num_cavities,

  % set CAVITY multiplexer to variable=cavity-1
  [status,answer] = caShell(['caput -s -w 20 ', rf_module,':CAVSEL ',num2str(cavity)]);
  if status ~=0
     fprintf(1,['Error - can not set the CAVITY signal to ',num2str(cavity),'\n']);
     return
  end

  % place the module in Reset mode
  [status,answer] = caShell(['caput -w 20 ', rf_module,':STATE 0']);
  if status ~=0
     fprintf(1,'Error - can not place RF module in Reset state\n');
     return
  end

  % place the module in Load mode
  [status,answer] = caShell(['caput -w 20 ', rf_module,':STATE 1']);
  if status ~=0
     fprintf(1,'Error - can not place RF module in Load state\n');
     return
  end

  % take a single shot of data - go to run mode
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
  % read the CAVITY_I file first
  [status,answer] = caShell(['caput -w 20 ', rf_module,':MODU.GCIR 1']);
  if status ~=0
     fprintf(1,'Error - can not activate the CAVITY_I file read\n');
     return
  end
  fprintf(1,'Moving data from I channel to file\n');
  test = 0;	% force the first pass in the while loop
  count = 0;	% count how many times we look at the status mesasage
  pause(2);	% wait 2 seconds to allow things to start
  while test ~= 1,
     [status,answer] = caShell(['caget -t -w 20 ', rf_module,':MODU.CIST']);
     count = count +1;
     test = strcmp(answer(1),'N');
     if count > max_count
        fprintf(1,'Error - can not read the CAVITY_I file - timed out\n');
        return
     end
     if test ~= 1, pause(1), end;	% sleep for 1 seconds
  end; % end of the while loop

  % read the CAVITY_Q file now
  [status,answer] = caShell(['caput -w 20 ', rf_module,':MODU.GCQR 1']);
  if status ~=0
     fprintf(1,'Error - can not activate the CAVITY_Q file read\n');
     return
  end
  fprintf(1,'Moving data from Q channel to file\n');
  test = 0;	% force the first pass in the while loop
  count = 0;	% count how many times we look at the status mesasage
  pause(2);	% wait 2 seconds to allow things to start
  while test ~= 1,
     [status,answer] = caShell(['caget -t -w 20 ', rf_module,':MODU.CQST']);
     count = count +1;
     test = strcmp(answer(1),'N');
     if count > max_count
        fprintf(1,'Error - can not read the CAVITY_Q file - timed out\n');
        return
     end
     if test ~= 1, pause(1), end;	% sleep for 1 seconds
  end; % end of the while loop

  % make the file ID's
  fid1 = -1;
  fid2 = -1;
  while (fid1 == -1), fid1 = fopen([u_header,measured_cavity_I],'r','ieee-be'); end;
  while (fid2 == -1), fid2 = fopen([u_header,measured_cavity_Q],'r','ieee-be'); end;

  % read the measured data files
  [header,count] = fread(fid1,[1,16],'char');
  fprintf(1,'Reading %s%s\n',u_header,measured_cavity_I);
  [i_dat,count] = fread(fid1,[1,inf],'short'); fclose(fid1);
  header = setstr (header);
  if count ~= (num_data)
     ['length of file in ',header,' is incorrect. Length = ',num2str(count)]
     return
  end
  [header,count] = fread(fid2,[1,16],'char');
  fprintf(1,'Reading %s%s\n',u_header,measured_cavity_Q);
  [q_dat,count] = fread(fid2,[1,inf],'short'); fclose(fid2);
  header = setstr (header);
  if count ~= (num_data)
     ['length of file in ',header,' is incorrect. Length = ',num2str(count)]
     return
  end

  i_dat = (fix(i_dat/16))/2047;	% shift data and scale
  q_dat = (fix(q_dat/16))/2047;	% shift data and scale
  out_data = i_dat + j*q_dat;
  clear i_dat
  clear q_dat

  fprintf(1,['Calculating cavity #',num2str(cavity),' transfer function\n']);
  [Hsum,FF]=tfestimate(in_data,out_data,hanning(num_fft),[],num_fft,fs);
  Hsum=Hsum';
  % reorder the results to go from -freq to + freq
  Hsum = [Hsum(num_fft/2+2:num_fft) Hsum(1:num_fft/2+1)]; % reorder by frequency

  magnitude = 20*log10(abs(Hsum));	% filter the data
  phases = angle(Hsum);	% filter the data

  %figure(1)
  figure(figIndOne)
  clf
  subplot(211)
  plot(baseband_freq(chop:num_fft-chop)/1e3, ...
       magnitude(chop:num_fft-chop),'r.')
  junk=axis;
  axis([junk(1:2) -30 30])
  grid on 
  title(['Measured Transfer Function of Cavity #',num2str(cavity),' - ',station])
  xlabel('baseband frequency - kHz')
  ylabel('amplitude - dB')

  subplot(212)
  plot(baseband_freq(chop:num_fft-chop)/1e3, ...
       (180/pi)*phases(chop:num_fft-chop),'r.') 
  grid on
  xlabel('baseband frequency - kHz')
  ylabel('phase - degrees')
  %drawnow

  % Script to determine parameters from cavity resonance data
  % and adjust the feedback loop for correct phase margins
  % R. Tighe 12/17/96

  fprintf(1,['Fitting cavity #',num2str(cavity), ...
              ' system parameters to measured data\n']);

  % find the initial center freq to help the fitting function
  ordered_magnitude = magnitude(chop:num_fft-chop);
  [value,index] = max(filtfilt(B,A,ordered_magnitude));		% filter to get rid of any spikes
  initial_magnitude = 10^(ordered_magnitude(index+10)/20);	% units are volts/volt
								% offset by 10 to avoid carrier

  % determine the center frequency (Wc) and the loaded Q (Ql)
  w=2*pi*(476+baseband_freq(chop:num_fft-chop)/1e6);	% make w vector
  options(1) = 0; 	% show optimization progess
  options(3) = 1e-6; 	% increase termination requirement for error
  options(14) = 600*length(baseband_freq(chop:num_fft-chop));     % more iterations
  x0 = [476,6000,initial_magnitude,450,180]; % initial conditions
  % call the optimization routine to determine center freq, Ql, gain, delay and offset

  [x,options] = constr('cavity_fit',x0,options,[475.95,4000,.1,350,-10], ...
                        [476.05,8000,50,550,400],[],w,w_rf/1e6,Hsum(chop:num_fft-chop));

  Wc = x(1)*2*pi;
  Ql = x(2);
  k  = x(3);
  Td = x(4);
  phase_offset = x(5);
  fprintf(1,'Fitted cavity frequency is %7.4f MHz\n',Wc/(2*pi));
  fprintf(1,'Fitted loaded cavity Q is %4.0f\n',Ql);
  fprintf(1,'Fitted loop gain is %3.1f volts/volt\n',k);
  fprintf(1,'Fitted system delay is %3.0f ns\n',Td);
  fprintf(1,'Fitted phase shift is %4.1f degrees\n',phase_offset);

  % make a fitted magnitude vector and plot it on top of the measured data
  fitted_magnitude = 20*log10(abs(k*sqrt(w.^2*Wc^2./ ...
                    (Ql^2*w.^4 + w.^2*Wc.^2 - 2*Ql^2*w.^2*Wc.^2+Ql^2*Wc.^4))));

  % store the maximim gain (V/V) for the fitted cavity magnitude
  fitted_gain(cavity) = 10^(max(fitted_magnitude)/20);

  % make a fitted phase vector and plot it on top of the measured data
  fitted_phase =  (phase_offset*(pi/180)) - (w-w_rf/1e6)*Td/1000 + ...
                   atan((Ql.*(-w.^2 + Wc^2))./(w*Wc));

  % plot the fitted results
  %figure(1)
  figure(figIndOne)
  subplot(211)
  hold on
  plot(baseband_freq(chop:num_fft-chop)/1e3,fitted_magnitude,'b')
  subplot(212)
  hold on
  plot(baseband_freq(chop:num_fft-chop)/1e3, ...
      (180/pi)*angle(exp(j*fitted_phase)),'b')
  %drawnow

  % read the current setting for the cavity baseband modulator
  [status,answer] = caShell(['caget -t -n -w 20 ', rf_module,':CAV',num2str(cavity),'.A']);
  cavity_II = str2num(answer);
  if status ~=0
    fprintf(1,['Error - unable to read cavity #',num2str(cavity),' II coefficient\n']);
    return
  end
  [status,answer] = caShell(['caget -n -t -w 20 ', rf_module,':CAV',num2str(cavity),'.C']);
  cavity_IQ = str2num(answer);
  if status ~=0
    fprintf(1,['Error - unable to read cavity #',num2str(cavity),' IQ coefficient\n']);
    return
  end
  [status,answer] = caShell(['caget -t -n -w 20 ', rf_module,':CAV',num2str(cavity),'.E']);
  cavity_QI = str2num(answer);
  if status ~=0
    fprintf(1,['Error - unable to read cavity #',num2str(cavity),' QI coefficient\n']);
    return
  end
  [status,answer] = caShell(['caget -t -n -w 20 ', rf_module,':CAV',num2str(cavity),'.G']);
  cavity_QQ = str2num(answer);
  if status ~=0
    fprintf(1,['Error - unable to read cavity #',num2str(cavity),' QQ coefficient\n']);
    return
  end

  % calculate the phase and magnitude of the cavity coefficients
  old_phases(cavity)     = (180/pi)*atan2(mean([cavity_IQ, cavity_QI]), ...
                                 mean([cavity_II, cavity_QQ]));
  old_magnitude(cavity) = sqrt((mean([cavity_IQ, cavity_QI]))^2 + ...
                       (mean([cavity_II, cavity_QQ]))^2);

 % calculate the required phase adjustment
  phase_adjust = rem(x(5)+180,360);	% add 180 degrees - it helps fitting converge
  fprintf(1,['Changing cavity #',num2str(cavity), ...
             ' phase by %4.1f degrees\n'],phase_adjust);
  new_phases(cavity) = rem(old_phases(cavity) + phase_adjust,360);

  % calculate the new cavity coefficients
  cavity_II = old_magnitude(cavity) * cos((pi/180) * new_phases(cavity));
  cavity_QI = old_magnitude(cavity) * sin((pi/180) * new_phases(cavity));
  cavity_IQ = cavity_QI;	% later we may want to remove modulator errors here
  cavity_QQ = cavity_II;	% and here

  % write the new settings for the direct loop baseband modulator
  [status,answer] = caShell(['caput -t -w 20 ', rf_module,':CAV',num2str(cavity),'.A ', ...
                           num2str(cavity_II)]);
  if status ~=0
     fprintf(1,'Error - unable to write direct loop II coefficient\n');
     return
  end
  [status,answer] = caShell(['caput -t -w 20 ', rf_module,':CAV',num2str(cavity),'.C ', ...
                           num2str(cavity_IQ)]);
  if status ~=0
     fprintf(1,'Error - unable to write direct loop IQ coefficient\n');
     return
  end
  [status,answer] = caShell(['caput -t -w 20 ', rf_module,':CAV',num2str(cavity),'.E ', ...
                           num2str(cavity_QI)]);
  if status ~=0
     fprintf(1,'Error - unable to write direct loop QI coefficient\n');
     return
  end
  [status,answer] = caShell(['caput -t -w 20 ', rf_module,':CAV',num2str(cavity),'.G ', ...
                           num2str(cavity_QQ)]);
  if status ~=0
     fprintf(1,'Error - unable to write direct loop QQ coefficient\n');
     return
  end
  [status,answer] = caShell(['caput -w 20 ', rf_module,':MODU.LOD 1']);
  if status ~=0
     fprintf(1,'Error - unable to load RF module octal DAC coefficients\n');
     return
  end

  % calculate the required tuner phase offset adjustment
  freq_error = (Wc/(2*pi) - 476)*1e3;	% calculate the freq error from 476 (kHz)
  max_error = max([max_error,abs(freq_error)]);
  fprintf(1,['Tuning error for cavity #',num2str(cavity),' = ' ...
              num2str(freq_error),' kHz\n']);

  delta_offset_cavity = (-180/pi)*atan(2*Ql*freq_error/(f_rf/1e3));
  delta_offset_delay  = (180/pi)*angle(exp(-j*2*pi*freq_error*(Td/1e9)));
  delta_offset_phase  = delta_offset_cavity + delta_offset_delay;

  % get the present probe phase offset and calculate the new value
  [status,answer] = caShell(['caget -t -w 20 ', station,':CAV',num2str(cavity), ...
                          'PROBE:PHASE:OFFS']);
  present_phase = str2num(answer);
  if status ~=0
    fprintf(1,['Error - unable to read cavity #',num2str(cavity),' probe phase offset\n']);
    return
  end
  new_phase_offset = present_phase + delta_offset_phase;

  % update the probe phase offset
  fprintf(1,['Changing cavity #',num2str(cavity),' probe phase offset by ', ...
              num2str(delta_offset_phase),' degrees\n']);
  [status,answer] = caShell(['caput -w 20 ', station,':CAV',num2str(cavity),'PROBE:PHASE:OFFS ', ...
                           num2str(new_phase_offset)]);
  if status ~=0
     fprintf(1,['Error - unable to change cavity #',num2str(cavity),' probe phase offset\n']);
     return
  end
  freq_hist(pass,cavity)   = freq_error;	% save tuning history for diagnostic
 end	% end of the cavity 1 to num_cavities loop

 % plot the tuning freq_history - not on the first pass
 if pass > 1
   %figure(2)
   figure(figIndTwo)
   clf
   plot(freq_hist)
   hold on
   plot(freq_hist,'*')
   title(['Tuning History for All Cavities - ',station])
   xlabel('Iteration Number')
   ylabel('Tuning Error - kHz')
   grid on
 end

end	% end of the while loop - max = max_pass

if ((pass > max_pass) & (abs(max_error) > delta_f_fine_max))
  fprintf(1,['Error - failed to tune cavities in ',num2str(pass),' passes\n']);
  return
else
  fprintf(1,['\nCavities tuned to within ', num2str(max_error),' kHz in ',num2str(pass),' passes\n\n']);
end

% at this point initial cavity tuning loop is complete - set tuner home positions
[status,answer] = caShell(['caput -w 20 ', station,':CAVTUNR:LOOPON:HOME.PROC 1']);
if status ~=0
  fprintf(1,['Error - unable to write tuner home position\n']);
  return
end

% initialize the tuner task so calculated position matches actual position
for cavity = 1:num_cavities,
  fprintf(1,['Initializing cavity #',num2str(cavity),' stepper motor task\n']);
  [status,answer] = caShell(['caput -w 20 ', station,':CAV',num2str(cavity),'TUNR:STEP:STOP.PROC 1']);
  if status ~=0
     fprintf(1,['Error - unable to initialize cavity #',num2str(cavity),' stepper motor task\n']);
     return
  end
  pause(5); % let the task initialize
end

fprintf(1,'Restoring original station drive power\n');
% write the desired drive power
[status,answer] = caShell(['caput -w 20 ', station,':KLYSDRIVFRWD:POWER:ON ', ...
                         num2str(original_drive_power)]);
if status ~=0
   fprintf(1,'Error - can not restore original ON_CW drive power setpoint\n');
   return
end
pause(30);	% wait for things to settle

% here we adjust the cavity combining networks amplitudes to match the measured
% values from the database using IQ&A values and coupling/cable losses

% measure the gap voltage in each cavity
for cavity = 1:num_cavities,
  [status,answer] = caShell(['caget -t -w 20 ', station,':CAV',num2str(cavity), ...
                          'PROBE:AMPL']);
  cavity_voltage(cavity) = str2num(answer);
  if status ~=0
    fprintf(1,['Error - unable to read cavity #',num2str(cavity),' gap voltage\n']);
    return
  end
end

% scale each cavity voltage by total station gap voltage
cavity_voltage = cavity_voltage/sum(cavity_voltage);

% update each cavity combining network based on the saved value of max amplitude
% from previous measurement loop and the actual IQ & A measured voltage distribution

delta_coeffs = cavity_voltage/mean(cavity_voltage)./(fitted_gain/mean(fitted_gain));
new_magnitude = old_magnitude .* delta_coeffs;
% protect from saturating the DACs (max count = 2047 including ~150 counts for offset)
if max(new_magnitude) > (2047 - 150)
  new_magnitude = new_magnitude * ((2047 - 150)/(max(abs((new_magnitude)))));
  fprintf(1,'Possible saturation of DACs - scaling max cavity combiner coeffs to 1900\n');
end
for cavity = 1:num_cavities,
  cavity_II = new_magnitude(cavity) * cos((pi/180) * new_phases(cavity));
  cavity_QI = new_magnitude(cavity) * sin((pi/180) * new_phases(cavity));
  cavity_IQ = cavity_QI;	% later we may want to remove modulator errors here
  cavity_QQ = cavity_II;	% and here

  fprintf(1,['Updating cavity combiner network for cavity #', num2str(cavity),'\n']);

  % write the new settings for the direct loop baseband modulator
  [status,answer] = caShell(['caput -t -w 20 ', rf_module,':CAV',num2str(cavity),'.A ', ...
                           num2str(cavity_II)]);
  if status ~=0
     fprintf(1,'Error - unable to write direct loop II coefficient\n');
     return
  end
  [status,answer] = caShell(['caput -t -w 20 ', rf_module,':CAV',num2str(cavity),'.C ', ...
                           num2str(cavity_IQ)]);
  if status ~=0
     fprintf(1,'Error - unable to write direct loop IQ coefficient\n');
     return
  end
  [status,answer] = caShell(['caput -t -w 20 ', rf_module,':CAV',num2str(cavity),'.E ', ...
                           num2str(cavity_QI)]);
  if status ~=0
     fprintf(1,'Error - unable to write direct loop QI coefficient\n');
     return
  end
  [status,answer] = caShell(['caput -t -w 20 ', rf_module,':CAV',num2str(cavity),'.G ', ...
                           num2str(cavity_QQ)]);
  if status ~=0
     fprintf(1,'Error - unable to write direct loop QQ coefficient\n');
     return
  end
  [status,answer] = caShell(['caput -w 20 ', rf_module,':MODU.LOD 1']);
  if status ~=0
     fprintf(1,'Error - unable to load RF module octal DAC coefficients\n');
     return
  end

  % write the cavity strengths into the database
  [status,answer] = caShell(['caput -t -w 20 ', station,':CAV',num2str(cavity),':STRENGTH ', ...
                           num2str(100*cavity_voltage(cavity))]);
  if status ~=0
     fprintf(1,'Error - unable to write cavity strength\n');
     return
  end

end

% next we measure the tuner sensitivities (mm/degree) for each cavity
fprintf(1,'\n');
for cavity = 1:num_cavities,

  fprintf(1,['Calculating tuner sensitivity for cavity #',num2str(cavity),'\n']);

  % remember the current setting of the probe phase offset
  [status,answer] = caShell(['caget -t -w 20 ', station,':CAV',num2str(cavity), ...
                          'PROBE:PHASE:OFFS']);
  present_phase = str2num(answer);
  if status ~=0
    fprintf(1,['Error - unable to read cavity #',num2str(cavity),' probe phase offset\n']);
    return
  end

  % remember the current position of the tuner (mm)
  [status,answer] = caShell(['caget -t -w 20 ', station,':CAV',num2str(cavity), ...
                          'TUNR:STEP:MOTOR.RBV']);
  present_mm = str2num(answer);
  if status ~=0
    fprintf(1,['Error - unable to read cavity #',num2str(cavity),' tuner position\n']);
    return
  end

  % offset the probe phase by delta_degrees
  [status,answer] = caShell(['caput -w 20 ', station,':CAV',num2str(cavity),'PROBE:PHASE:OFFS ', ...
                           num2str(present_phase + delta_degrees)]);
  if status ~=0
     fprintf(1,['Error - unable to change cavity #',num2str(cavity),' probe phase offset\n']);
     return
  end

  % read the new position of the tuner (mm)
  pause(20);	% wait for the tuners to move
  [status,answer] = caShell(['caget -t -w 20 ', station,':CAV',num2str(cavity), ...
                          'TUNR:STEP:MOTOR.RBV']);
  new_mm = str2num(answer);
  if status ~=0
    fprintf(1,['Error - unable to read cavity #',num2str(cavity),' tuner position\n']);
    return
  end

  % calculate the new tuner sensitivity (mm/degree)
  mm_per_degree = abs((present_mm - new_mm)/delta_degrees);	% do we really want the ABS here?

  [status,answer] = caShell(['caput -w 20 ', station,':CAV',num2str(cavity), ...
                          'TUNR:POSN:DELTA.C ',num2str(mm_per_degree)]);
  if status ~=0
    fprintf(1,['Error - unable to write cavity #',num2str(cavity),' tuner sensitivity\n']);
    return
  end

  % remove the delta_degrees offset of the probe phase
  [status,answer] = caShell(['caput -w 20 ', station,':CAV',num2str(cavity),'PROBE:PHASE:OFFS ', ...
                           num2str(present_phase)]);
  if status ~=0
     fprintf(1,['Error - unable to change cavity #',num2str(cavity),' probe phase offset\n']);
     return
  end

end

% close the HVPS voltage loop
[status,answer] = caShell(['caput -w 20 ', station,':HVPS:LOOP:CTRL 2']);
if status ~=0
   fprintf(1,'Error - can not enable HVPS loop\n');
   return
end

fprintf(1,'*** Tuner/Directivity Configuration Sequence Complete ***\n');

