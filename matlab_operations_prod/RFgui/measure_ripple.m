function measure_ripple(hObject, eventdata, handles)
% hObject    handle to loadDataPb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% measure_ripple.m - Loads the IQ&A detector channel which looks at the
%                    klystron output with the wideband (10 KHZ) filter
%                    file (if not already loaded).  Measures klystron 
%                    output into IQ&A history buffer.  Makes data file
%                    and plots time and frequency domain.  Paul 6/27/97

% MOD: W. Colocho, 12/9/2002 - Made into a function(). It uses handles
% structure to pass data.
% MOD: W. Colocho, 10/2/2003 - removed -1 from many calls of the form:
% answer(1:length(answer)-1) as caShell() behaves different than caget()


% clear
format compact
% help measure_ripple

fprintf(1,'\n*** Measuring Klystron Ripple ***\n\n');

% general parameters
file_length	= '512';			% length of data file - k
DDF_file1 	= '/tbl/iqaDdf_23KHz.rpt';	% DDF filter file #1 23KHz output rate
max_count 	= 10;	% maximum number of attempts to read data file


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
% station = getenv('STATION'); Now set by above sequence.

% rf_data = getenv('RF_DATA');
rf_data = handles.rfData;   % use handles structure

% read the current klystron output power
[status,answer] = caShell(['caget -t -w 20 ', station,':KLYSOUTFRWD:POWER']);
if status ~=0
   fprintf(1,'Error - unable to read klystron output power\n');
   return
end
klystron_power = str2num(answer);

% read the data filename from the IQ&A driver
[status,answer] = caShell(['caget -t -w 20 ', station,':STN:IQA1:MODU.IQHF']);
if status ~=0
   fprintf(1,'Error - unable to read IQ&A history buffer file name\n');
   return
end
%history_file = answer(5:length(answer)-1);
history_file = answer(5:length(answer)); %10/2/03 removed -1

% set the length of the data file to maximum (512k)
[status,answer] = caShell(['caput -w 20 ', station,':STN:IQA1:MODU.IQHS ', file_length]);
if status ~=0
   fprintf(1,'Error - can not set IQ&A history buffer file length\n');
   return
end

% read the DDF filter file
[status,answer] = caShell(['caget -t -w 20 ', station,':STN:IQA1:MODU.DCF0']);
if status ~=0
   fprintf(1,'Error - unable to read IQ&A DDF channel 1 file name\n');
   return
end
%original_DDF_file = answer(1:length(answer)-1);   %Removed -1
original_DDF_file = answer(1:length(answer)); 
if     strcmp(original_DDF_file,DDF_file1) == 1,
  Tsample = 1/(755e3/32);
else
  fprintf(1,'Error - unrecognized DDF filter file name for IQ&A module\n');
end

% take the data
fprintf(1,'Moving data from IQA module to file\n');
[status,answer] = caShell(['caput -w 20 ', station,':STN:IQA1:MODU.GIQH 1']);
if status ~=0
   fprintf(1,'Error - can not make IQ&A history buffer file\n');
   return
end
test = 0;	% force the first pass in the while loop
count = 0;	% count how many times we look at the status mesasage
pause(2);	% wait 2 seconds to allow things to start
while test ~= 1,
   [status,answer] = caShell(['caget -t -w 20 ', station,':STN:IQA1:MODU.IQST']);
   count = count +1;
   test = strcmp(answer(1),'N');
   if count > max_count
      fprintf(1,'Error - can not create the IQA history file - timed out\n');
      return
   end
   if test ~= 1, pause(1), end;	% sleep for 1 second
end; % end of the while loop

% read the recorded data file
fprintf(1,'Reading data from file\n');
fid1 = -1;
while fid1 == -1; fid1 = fopen([rf_data,'/',station, history_file],'r','ieee-be'); end;

[header,count] = fread(fid1,[1,15],'char');
[data,  count] = fread(fid1,[1,inf],'short'); fclose(fid1);

% massage the data
fprintf(1,'Processing data\n');
data = reshape(data,16,32768);
time = [0:Tsample:Tsample*(length(data(1,:))-1)];
i1 = data(16,:);	% select the channel 1 (klystron output) data
q1 = data(15,:);
raw_data = data(16,:) + j*data(15,:);	% from the complex vector
clear data;

raw_power = abs(raw_data).^2;
klys_power = klystron_power*(raw_power/mean(abs(raw_power)));
klys_phase = 180/pi * atan2(q1,i1);

% increment to the next figure
% retrieve figure data
figHandles = handles.figHandles;
figInd=length(figHandles);
figInd=figInd+1; figure(figInd); clf; figHandles(figInd) = figInd;
handles.figHandles = figHandles;
% figure(2)
% clf
subplot(211)
plot(time(1:1000)*1e3, (klys_power(1:1000)))
title(['Measured Klystron Ripple ',station,' ',date])
xlabel('time - ms')
ylabel('power - kW')
grid on
subplot(212)
plot(time(1:1000)*1e3,klys_phase(1:1000))
xlabel('time - ms')
ylabel('phase - degrees')
grid on
zoom on

Hsum1 = fft(abs(raw_data));		% look at the amplitude spectrum
Hsum2 = fft(unwrap(angle(raw_data)));	% look at the phase spectrum
clear raw_data;				% save some memory
num_fft=length(Hsum1);
Hsum2(1) = num_fft;	% scale the DC phase term to produce results in dBc
Hsum1 = [Hsum1(num_fft/2+2:num_fft) Hsum1(1:num_fft/2+1)]; % reorder by frequency
Hsum2 = [Hsum2(num_fft/2+2:num_fft) Hsum2(1:num_fft/2+1)]; % reorder by frequency

magnitude1 = 20*log10(abs(Hsum1));
magnitude1 = magnitude1 - max(magnitude1);	% calcultate dBc for amplitude
magnitude2 = 20*log10(abs(Hsum2/(num_fft)));	% scale by num_fft so phase dBc calc is correct

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
% figure(3)
% clf
subplot(211)
plot(baseband_freq(chop:num_fft-chop)/1e3, ...
     magnitude1(chop:num_fft-chop),'r')
junk = axis;
axis([junk(1:2) -120 10])
grid on
title(['Measured Klystron Output Amplitude Spectrum ',station,' ',date])
xlabel('baseband frequency - kHz')
ylabel('amplitude - dBc')
subplot(212)
plot(baseband_freq(chop:num_fft-chop)/1e3, ...
     magnitude2(chop:num_fft-chop),'r') 
junk = axis;
axis([junk(1:2) -120 10])
grid on
title('Measured Klystron Output Phase Spectrum')
xlabel('baseband frequency - kHz')
ylabel('amplitude - dBc')
zoom on

fprintf(1,'\n*** Measurement of Ripple Complete ***\n');
