function plot_drive(hObject, eventdata, handles)
% hObject    handle to loadDataPb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% plot_drive.m - Measures the baseband IQ drive signals in
%                the RF processing module and plots them
%                in Volts and Watts. This is a good way to
%                check the performance of the gap loop since
%                the amplitude of the drive over a 1-turn
%                interval should be constant.
%                                  Paul 8/31/99

% MOD: W. Colocho, 12/9/2002 - Made into a function(). It uses handles
% structure to pass data.

% clear
format compact
% help plot_drive

% general parameters
file_length = '256';			% length of data file - k
max_count   = 30;			% maximum number of tries to write data files
freq_wide = 1e6;			% frequency range of wide FFT plot
Tsample = handles.Tsample;		% sampling frequency

% load stnfile     % loads the station variable (escapes the clear)
station = handles.station; % use handles structure

% % this section determines who called this routine in order to set the station
% [ST,I] = dbstack;
% sst = size(ST);
% if sst(1)>1
%   caller = getfield(ST,{2,1},'name');
%   if sum(ismember('RF_handler.m',caller))~=12  % set the station using
%     station = getenv('STATION'); 	       % the environment variable
%   end				               % if called by other than
% else					       % 'RF_handler.m'	
%     station = getenv('STATION');
% end

% rf_data = getenv('RF_DATA');
rf_data = handles.rfData;   % use handles structure
rf_module = [station,':STN:RFP'];
handles.rfModule = rf_module;  % needed to pass to save_RFP_mux

fprintf(1,['\n*** Measuring ',station,' Baseband Drive Signal ***\n']);
% make sure the RF is on - remove carrige return
[status,answer] = caShell(['caget -t -w 20 ', rf_module,':RFENABLE']);
if status ~=0
   fprintf(1,'Error - unable to read RF on/off status\n');
   return
end
if strcmp(answer(1:2),'ON') ~= 1
   fprintf(1,'Error - RF must be on to measure baseband drive\n');
   return
end

% save_RFP_mux	% remember the state of the muxes for fast fault data
save_RFP_mux(hObject, eventdata, handles)
handles = guidata(handles.output);  % Updates handles structure

fprintf(1,'\nConfiguring RF system - please be patient\n');
% write the desired length of the data files to the RF module driver
[status,answer] = caShell(['caput -w 20 ', rf_module,':MODU.RMSZ ', ...
                         num2str(file_length)]);
if status ~=0
   fprintf(1,'Error - can not set the desired file length\n');
   return
end

% write the desired filename to the SIGNAL_I RAM location in RF module
[status,answer] = caShell(['caput -w 10 ', station,':STN:RFP:MODU.SIRF /dat/DRIVE_I']);
if status ~=0
   fprintf(1,'Error - can not write SIGNAL_I file name\n');
   return
end
% write the desired filename to the SIGNAL_Q RAM location in RF module
[status,answer] = caShell(['caput -w 10 ', station,':STN:RFP:MODU.SQRF /dat/DRIVE_Q']);
if status ~=0
   fprintf(1,'Error - can not write SIGNAL_Q file name\n');
   return
end

% disable the DACs
[status,answer] = caShell(['caput -w 20 ', rf_module,':DACS 0']);
if status ~=0
   fprintf(1,'Error - can not enable the DACs\n');
   return
end

% place the module in single shot mode
[status,answer] = caShell(['caput -w 20 ', rf_module,':SSCONT 0']);
if status ~=0
   fprintf(1,'Error - can not place the module in Single Shot mode\n');
   return
end

% set SIGNAL multiplexer to DRIVE
[status,answer] = caShell(['caput -w 20 ', rf_module,':FBSIG 3']);
if status ~=0
   fprintf(1,['Error - can not set the signal to TOTAL\n']);
   return
end

cyclerfstates( rf_module );

% get the data files
fprintf(1,'Moving I data to file\n');
% read the TOTAL_I file first
[status,answer] = caShell(['caput -w 20 ', rf_module,':MODU.GSIR 1']);
if status ~=0
   fprintf(1,'Error - can not activate the SIGNAL_I file read\n');
   return
end
test = 0;	% force the first pass in the while loop
count = 0;	% count how many times we look at the status mesasage
pause(2);	% wait 2 seconds to allow things to start
while test ~= 1,
   [status,answer] = caShell(['caget -t -w 20 ', rf_module,':MODU.SIST']);
   count = count +1;
   test = strcmp(answer(1),'N');
   if count > max_count
     fprintf(1,'Error - can not read the TOTAL_I file - timed out\n');
     return
   end
   if test ~= 1, pause(1), end;	% sleep for 1 seconds
end; % end of the while loop

% read the TOTAL_Q file now
fprintf(1,'Moving Q data to file\n');
[status,answer] = caShell(['caput -w 20 ', rf_module,':MODU.GSQR 1']);
if status ~=0
   fprintf(1,'Error - can not activate the SIGNAL_Q file read\n');
   return
end
test = 0;	% force the first pass in the while loop
count = 0;	% count how many times we look at the status mesasage
pause(2);	% wait 2 seconds to allow things to start
while test ~= 1,
   [status,answer] = caShell(['caget -t -w 20 ', rf_module,':MODU.SQST']);
   count = count +1;
   test = strcmp(answer(1),'N');
   if count > max_count
     fprintf(1,'Error - can not read the TOTAL_Q file - timed out\n');
     return
   end
   if test ~= 1, pause(1), end;	% sleep for 1 seconds
end; % end of the while loop

% restore_RFP_mux  % restore the mux setting for fast history buffers
restore_RFP_mux(hObject, eventdata, handles)
% reset data taking mode to continuous
try
    lcaPut([rf_module,':SSCONT'], 1);
catch
    fprintf(1,'Error - cannot reset data taking mode to continuous\n');
    return;
end % try
% reset, load, run
for ind = 0:2,
    lcaPut([rf_module, ':STATE'], ind);
    pause(0.1);
end % for ind = 0:2,

% read the ripple loop gain tracking parameter so we can plot the
% voltage before the ripple IQ modulator
[status,answer] = caShell(['caget -n -t -w 20 ', station,':STN:RFP:MODU.AMSP']);
if status ~=0
   fprintf(1,'Error - unable to read ripple loop gain tracking parameter\n');
   return
end
gain_scale = 2*str2num(answer);	% gain of the baseband modulator

% read the current drive power if not in the lab
if strcmp(station(1:3),'LAB') ~= 1,
  [status,answer] = caShell(['caget -t -w 20 ', station,':KLYSDRIVFRWD:POWER']);
  if status ~=0
     fprintf(1,'Error - unable to read klystron drive power - setting scale factor to 1\n');
     cavity_voltage = 1;
  else 
  drive_power = str2num(answer);
  end
else
  drive_power = 1;
end

fprintf(1,'Reading data files\n');
fid1 = -1;
fid2 = -1;
while (fid1 == -1), fid1 = fopen([rf_data,'/',station,'/DRIVE_I'],'r','ieee-be'); end;
while (fid2 == -1), fid2 = fopen([rf_data,'/',station,'/DRIVE_Q'],'r','ieee-be'); end;

% read the measured data files
[header,count] = fread(fid1,[1,16],'char');
[i_dat,count] = fread(fid1,[1,inf],'short'); fclose(fid1);
header = setstr (header);
[header,count] = fread(fid2,[1,16],'char');
[q_dat,count] = fread(fid2,[1,inf],'short'); fclose(fid2);
header = setstr (header);

fprintf(1,'Processing data\n');		% shift down 4 bits and scale
i_dat = (2*((fix(i_dat/16))/2047)/gain_scale);	% /2 in front of ADC & 1/modulator gain
q_dat = (2*((fix(q_dat/16))/2047)/gain_scale);	% /2 in front of ADC & 1/modulator gain

% calculate the maximum IQ voltage - want to keep below 1 volt
voltage_max = max(abs(i_dat +j*q_dat));
fprintf(1,['\nPresent maximum value of the baseband drive vector is %4.3f volts',...
          '\nShould not exceed 1.00 volts\n'],voltage_max);
% read the minimum value of the ripple DC gain setpoint
[status,answer] = caShell(['caget -n -t -w 20 ', station,':STNRIPPLE:LOOP:AMPL.LOPR']);
if status ~=0
   fprintf(1,'Error - unable to read ripple loop gain tracking lower limit\n');
   return
end
min_gain_scale = 2*str2num(answer);  % also include the *2 gain of the modulator
% calculate the maximum expected voltage when modulator gain is at minimum value
predicted_voltage_max = voltage_max*gain_scale/min_gain_scale;
fprintf(1,['\nPredicted maximum value of the baseband drive vector is %4.3f volts',...
           '\nShould not exceed 1.00 volts\n'],predicted_voltage_max);

time = Tsample*[0:length(i_dat)-1];
raw_data = fliplr((i_dat + j*q_dat));	% flip to display old to new data
ampl = abs(raw_data);	
% scale the power to the IQA measured drive power
power = drive_power * ((ampl.^2)/(mean(ampl)^2));
phase = (180/pi) * angle(raw_data);

% increment to the next figure
% retrieve figure data
figHandles = handles.figHandles;
figInd=length(figHandles);
figInd=figInd+1; figure(figInd); clf; figHandles(figInd) = figInd;
handles.figHandles = figHandles;
guidata(handles.output, handles); % update  handles data
% figure(2)
% clf
subplot(211)
plot(time/1e-6,power)
grid on
xlabel('time - us')
ylabel('power - Watts')
title(['Klystron Drive amplitude and power',station,' ',datestr(now,0)])
subplot(212)
plot(time/1e-6,phase)
grid on
xlabel('time - us')
ylabel('phase - degrees')

% increment to the next figure
% retrieve figure data
figHandles = handles.figHandles;
figInd=length(figHandles);
figInd=figInd+1; figure(figInd); clf; figHandles(figInd) = figInd;
handles.figHandles = figHandles;
guidata(handles.output, handles); % update  handles data
% figure(3)
% clf

plot(i_dat(1:2^16),q_dat(1:2^16),'r.', ...
     [-2 2],[0 0],'b-',[0 0],[-2 2],'b-', ...
     [-1 1 1 -1 -1],[1 1 -1 -1 1],'r-.')
%plot(i_dat,q_dat,'r.', ...
%     [-2 2],[0 0],'b-',[0 0],[-2 2],'b-', ...
%     [-1 1 1 -1 -1],[1 1 -1 -1 1],'r-.')
axis([-2 2 -2 2])
axis('square')
title(['IQ Plot of Klystron Drive ',station,' ',datestr(now,0)])
xlabel('I voltage - volts')
ylabel('Q voltage - volts')
text(-1.5,-1.1,'Should look like a blob')
text(-1.5,-1.25,'to cancel klystron ripple')
text(-1.5,-1.75,'Magnitude of I or Q should not exceed 1.0 Volts')
grid on
% drawnow

% save some memory
clear i_dat;
clear q_dat;
clear time;

% calculate the amplitude and phase spectrums
Hsum1 = fft((hanning(length(ampl))').*(ampl));	 
Hsum2 = fft((hanning(length(phase))').*(angle(raw_data)));	 
clear raw_data	% save memory
num_fft=length(Hsum1);
Hsum2(1) = num_fft;	% scale the DC phase term to produce results in dBc
Hsum1 = [Hsum1(num_fft/2+2:num_fft) Hsum1(1:num_fft/2+1)]; % reorder by frequency
Hsum2 = [Hsum2(num_fft/2+2:num_fft) Hsum2(1:num_fft/2+1)]; % reorder by frequency
magnitude1 = 20*log10(abs(Hsum1));
magnitude2 = 20*log10(abs(Hsum2/(num_fft)));	% scale by num_fft so phase dBc calc is correct
% calculate dBc for amplitude
magnitude1 = magnitude1 - magnitude1(num_fft/2);

delta_f= 1/(Tsample*(num_fft));
baseband_freq=delta_f*[((-1*(num_fft/2 -1)):-1) 0 (1:num_fft/2) ];
chop = 1;

% increment to the next figure
% retrieve figure data
figHandles = handles.figHandles;
figInd=length(figHandles);
figInd=figInd+1; figure(figInd); clf; figHandles(figInd) = figInd;
handles.figHandles = figHandles;
guidata(handles.output, handles); % update  handles data
% figure(4)
% clf
subplot(211)
plot(baseband_freq(chop:num_fft-chop)/1e6, ...
 magnitude1(chop:num_fft-chop),'r') 
axis([-3 3 -90 10])
grid on
title(['Measured Klystron Drive Amplitude & Phase Spectrum ',station,' ',datestr(now,0)])
xlabel('baseband frequency - MHz')
ylabel('amplitude - dBc')
subplot(212)
plot(baseband_freq(chop:num_fft-chop)/1e6, ...
 magnitude2(chop:num_fft-chop),'r') 
axis([-3 3 -90 10])
grid on
xlabel('baseband frequency - MHz')
ylabel('phase - dBc')

% reshape the data by turns and calculate power and the means
num_turns = floor(length(ampl)/72);
power = mean([reshape(power(1:72*num_turns),72,num_turns)],2);
phase = mean([reshape(phase(1:72*num_turns),72,num_turns)],2);

% increment to the next figure
% retrieve figure data
figHandles = handles.figHandles;
figInd=length(figHandles);
figInd=figInd+1; figure(figInd); clf; figHandles(figInd) = figInd;
handles.figHandles = figHandles;
guidata(handles.output, handles); % update  handles data
% figure(5)
% clf
subplot(211)
plot([1:72],power)
junk=axis;
axis([1 72 junk(3:4)])
xlabel('sample number')
ylabel('power - Watts')
grid on
title(['RF Module Data - Mean Baseband Drive Over 1 Turn ',station,' ',datestr(now,0)])
subplot(212)
plot([1:72],phase)
junk=axis;
axis([1 72 junk(3:4)])
xlabel('sample number')
ylabel('phase - degrees')
grid on
% drawnow

fprintf(1,['\n*** Measurement of Drive complete ***\n']);
