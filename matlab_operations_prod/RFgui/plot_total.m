function plot_total(hObject, eventdata, handles)
% hObject    handle to loadDataPb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% plot_total.m - Measures the sum of the cavity probe signals and the 
%                direct loop modulator using the 10MHz bandwidth analog IQ
%                detection hardware in the RF processing VXI module.
%                Absolute voltage level is determined with the IQ&A
%                module channel using all system calibrations.  Paul 10/7/97
 
% MOD: W. Colocho, 12/9/2002 - Made into a function(). It uses handles
% structure to pass data.

% clear
format compact
% help plot_total

% general parameters
FFT_file_length = '256';		% length of data file for FFT's - k
max_count   = 30;			% maximum number of tries to write data files
freq_wide = 5e6;			% frequency range of wide FFT plot
freq_zoom = 10e3;			% frequency range of narrow FFT plot
Tsample = handles.Tsample;		% sampling frequency
f_low_pass = 10e3;			% -3dB frequency of lowpass filtered data
f_order = 3;				% order of Butterworth lowpass filter

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

% rf_data   = getenv('RF_DATA');
rf_data = handles.rfData;   % use handles structure
rf_module = [station,':STN:RFP'];
handles.rfModule = rf_module; % Needed to pass to save_RFP_mux.m

fprintf(1,['\n*** Measuring ',station,' Total RF Vector Sum ***\n']);

% read the current station gap voltage if not in the lab
if strcmp(station(1:3),'LAB') ~= 1,
  [status,answer] = caShell(['caget -t -w 10 ', station,':STN:VOLT']);
  if status ~=0
     fprintf(1,'Error - unable to read station gap voltage\n');
     return
  end
  station_voltage = str2num(answer);
else
  station_voltage = 1;
end

% save_RFP_mux	% remember the state of the muxes for fast fault data
save_RFP_mux(hObject, eventdata, handles)
handles = guidata(handles.output);  % Updates handles structure

fprintf(1,'\nConfiguring RF system - please be patient\n');
% write the desired length of the data files to the RF module driver
[status,answer] = caShell(['caput -w 20 ', rf_module,':MODU.RMSZ ', num2str(512)]);
if status ~=0
   fprintf(1,'Error - can not set the desired file length\n');
   return
end

% write the desired filename to the SIGNAL_I RAM location in RF module
[status,answer] = caShell(['caput -w 10 ', station,':STN:RFP:MODU.SIRF /dat/TOTAL_I']);
if status ~=0
   fprintf(1,'Error - can not write SIGNAL_I file name\n');
   return
end
% write the desired filename to the SIGNAL_Q RAM location in RF module
[status,answer] = caShell(['caput -w 10 ', station,':STN:RFP:MODU.SQRF /dat/TOTAL_Q']);
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

% set SIGNAL multiplexer to TOTAL
[status,answer] = caShell(['caput -w 20 ', rf_module,':FBSIG 0']);
if status ~=0
   fprintf(1,['Error - can not set the signal to TOTAL\n']);
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

fprintf(1,'Reading data files\n');
fid1 = -1;
fid2 = -1;
while (fid1 == -1), fid1 = fopen([rf_data,'/',station,'/TOTAL_I'],'r','ieee-be'); end;
while (fid2 == -1), fid2 = fopen([rf_data,'/',station,'/TOTAL_Q'],'r','ieee-be'); end;

% read the measured data files
[header,count] = fread(fid1,[1,16],'char');
[i_dat,count] = fread(fid1,[1,inf],'short'); fclose(fid1);
header = setstr (header);
[header,count] = fread(fid2,[1,16],'char');
[q_dat,count] = fread(fid2,[1,inf],'short'); fclose(fid2);
header = setstr (header);

fprintf(1,'Processing data\n'); % shift down 4 bits and scale
i_dat = 2*(fix(i_dat/16))/2047;	% also scale for /2 in front of ADC
q_dat = 2*(fix(q_dat/16))/2047;

time = Tsample*[0:length(i_dat)-1];
raw_data = fliplr((i_dat + j*q_dat));	% flip to display old to new data
if strcmp(station(1:3),'LAB') ~= 1,
  ampl = (abs(raw_data)/mean(abs(raw_data)))*station_voltage;
else
  ampl = abs(raw_data);
end
phase = (180/pi) * angle(raw_data);

% limit the size of the FFT data
raw_data = raw_data(1:str2num(FFT_file_length)*1024);

% increment to the next figure
% retrieve figure data
figHandles = handles.figHandles;
figInd=length(figHandles);
figInd=figInd+1; figure(figInd); clf; figHandles(figInd) = figInd;
handles.figHandles = figHandles;
guidata(handles.output, handles); % update  handles data


% figure(2)
% clf
% only plot 64K of IQ data
plot(i_dat(1:2^16),q_dat(1:2^16),'r.', ...
     [-2 2],[0 0],'b-',[0 0],[-2 2],'b-', ...
     [-1 1 1 -1 -1],[1 1 -1 -1 1],'r-.')


axis([-2 2 -2 2])
axis('square')
title(['IQ Plot of Station Gap TOTAL ',station,' ',datestr(now,0)])
xlabel('I voltage - volts')
ylabel('Q voltage - volts')
text(-1.5,-1.1,'Gap transients are visible')
text(-1.5,-1.75,'Magnitude of I or Q should not exceed 1.0 Volts')
grid on


% drawnow

% save some memory
clear i_dat;
clear q_dat;


% calcuate the lowpass time domain response
[B,A] = butter(f_order,f_low_pass*Tsample*2);	% make lowpass to view 0-mode freqs
low_ampl  = filtfilt(B,A,ampl); 	% do the filtering on ampl data
low_phase = filtfilt(B,A,phase);	% do the filtering on phase data

% increment to the next figure
% retrieve figure data
figHandles = handles.figHandles;
figInd=length(figHandles);
figInd=figInd+1; figure(figInd); clf; figHandles(figInd) = figInd;
handles.figHandles = figHandles;
guidata(handles.output, handles); % update  handles data
% figure(3)
% clf
subplot(211)
plot(time*1e3,low_ampl)
junk=axis;
axis([junk(1:2) mean(low_ampl)-5 mean(low_ampl)+5])
xlabel('time - ms')
ylabel('station voltage - kV')
grid on
title(['Station Gap Total ',station,' - 10kHz lowpass filtered  ',datestr(now,0)])
subplot(212)
plot(time*1e3,low_phase)
junk=axis;
axis([junk(1:2) mean(low_phase)-.2 mean(low_phase)+.2])
xlabel('time - ms')
ylabel('phase - degrees')
grid on
% drawnow

% save some memory
clear low_ampl;
clear low_phase;
ampl = ampl(1:504);
phase = phase(1:504);
time = time(1:504);

% increment to the next figure
% retrieve figure data
figHandles = handles.figHandles;
figInd=length(figHandles);
figInd=figInd+1; figure(figInd); clf; figHandles(figInd) = figInd;
handles.figHandles = figHandles;
guidata (handles.output, handles ) %Update handles structure
% figure(4)
% clf
subplot(211)
plot(time*1e6,ampl)
xlabel('time - us')
ylabel('station voltage - kV')
grid on
title(['Station Gap Total ',station,' ',datestr(now,0)])
subplot(212)
plot(time*1e6,phase)
xlabel('time - us')
ylabel('phase - degrees')
grid on
% drawnow

clear ampl;
clear phase;
clear time;

Hsum1 = fft(raw_data .* hanning(length(raw_data))');	% look at the amplitude spectrum
num_fft=length(Hsum1);
Hsum1 = [Hsum1(num_fft/2+2:num_fft) Hsum1(1:num_fft/2+1)]; % reorder by frequency
Hsum2 = fft(unwrap(angle(raw_data) .* hanning(length(raw_data))'));  % look at the phase spectrum
clear raw_data;
Hsum2(1) = num_fft;	% scale the DC phase term to produce results in dBc
Hsum2 = [Hsum2(num_fft/2+2:num_fft) Hsum2(1:num_fft/2+1)]; % reorder by frequency

magnitude1 = 20*log10(abs(Hsum1));
clear Hsum1;
magnitude2 = 20*log10(abs(Hsum2/(num_fft)));	% scale by num_fft for correct dBc calc
clear Hsum2;

magnitude1 = magnitude1 - max(magnitude1);	% scale the amplitude to dBc

delta_f= 1/(Tsample*(num_fft));
baseband_freq=delta_f*[((-1*(num_fft/2 -1)):-1) 0 (1:num_fft/2)];
[value,chop] = min(abs(baseband_freq+freq_wide));	% zoom into freq_wide

% increment to the next figure
% retrieve figure data
figHandles = handles.figHandles;
figInd=length(figHandles);
figInd=figInd+1; figure(figInd); clf; figHandles(figInd) = figInd;
handles.figHandles = figHandles;
guidata (handles.output, handles ) %Update handles structure
% figure(5)
% clf
subplot(211)
plot(baseband_freq(chop:num_fft-chop)/1e6, ...
 magnitude1(chop:num_fft-chop),'r')
junk=axis;
axis([junk(1:2) -120 10]);
grid on
title(['Station Total Amplitude Spectrum ',station,' ',datestr(now,0)])
xlabel('baseband frequency - MHz')
ylabel('amplitude - dBc')
subplot(212)
plot(baseband_freq(chop:num_fft-chop)/1e6, ...
 magnitude2(chop:num_fft-chop),'r') 
junk=axis;
axis([junk(1:2) -120 10]);
grid on
title(['Station Total Phase Spectrum ',station,' ',datestr(now,0)])
xlabel('baseband frequency - MHz')
ylabel('amplitude - dBc')
% drawnow

[value,chop] = min(abs(baseband_freq+freq_zoom));	% zoom into freq_zoom

% increment to the next figure
% retrieve figure data
figHandles = handles.figHandles;
figInd=length(figHandles);
figInd=figInd+1; figure(figInd); clf; figHandles(figInd) = figInd;
handles.figHandles = figHandles;
guidata (handles.output, handles ) %Update handles structure
% figure(6)
% clf
subplot(211)
plot(baseband_freq(chop:num_fft-chop)/1e3, ...
 magnitude1(chop:num_fft-chop),'r') 
junk=axis;
axis([junk(1:2) -140 10]);
grid on
title(['Station Total Amplitude Spectrum ',station,' ',datestr(now,0)])
xlabel('baseband frequency - kHz')
ylabel('amplitude - dBc')
subplot(212)
plot(baseband_freq(chop:num_fft-chop)/1e3, ...
 magnitude2(chop:num_fft-chop),'r') 
junk=axis;
axis([junk(1:2) -140 10]);
grid on
title(['Station Total Phase Spectrum ',station,' ',datestr(now,0)])
xlabel('baseband frequency - kHz')
ylabel('amplitude - dBc')

fprintf(1,['\n*** Measurement complete ***\n']);
