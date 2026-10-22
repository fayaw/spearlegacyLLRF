function plot_klys_out(hObject, eventdata, handles)
% hObject    handle to loadDataPb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% plot_klys_out.m - Plots the klystron output power using the diode
%                   detector in the IQA module.  Absolute power
%                   level is determined by amplitude scaling factors
%                   in the EPICS database.  Paul 9/14/99

% MOD: W. Colocho, 10/2/2003 - removed -1 from calls of the form:
% answer(1:length(answer)-1) as caShell() behaves different than caget()
% MOD: W. Colocho, 12/9/2002 - Made into a function(). It uses handles
% structure to pass data.

% clear
format compact
% help plot_klys_out

% general parameters
file_length = '64';	% length of data file - k
max_count   = 10;	% maximum number of attempts to read data file
%Tsample = 1/((72*476e6)/3492);  	% sampling interval
 Tsample = handles.Tsample;

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

% rf_data  = getenv('RF_DATA');		% get the data path
rf_data = handles.rfData;   % use handles structure

u_header = [rf_data,'/',station];   	% string for the caShell stuff

% set the length of the data file
[status,answer] = caShell(['caput -w 20 ', station,':STN:IQA1:MODU.AHSZ ', file_length]);
if status ~=0
   fprintf(1,'Error - can not set IQ&A history buffer file length\n');
   return
end

% read the data filename from the IQ&A driver
[status,answer] = caShell(['caget -t -w 20 ', station,':STN:IQA1:MODU.AHFS']);
if status ~=0
   fprintf(1,'Error - unable to read IQ&A history buffer file name\n');
   return
end
%history_file = answer(5:length(answer)-1);
history_file = answer(5:length(answer));      %Removed -1.

% read the current amplitude detector MUX setting
[status,answer] = caShell(['caget -t -w 20 ', station,':STN:IQA1:MODU.ASS']);
if status ~=0
   fprintf(1,'Error - can not read IQ&A module amplitude mux\n');
   return
end
original_mux_setting = answer;  % store original setting
% read current mode setting
originalModeSetting = lcaGet([station, ':STN:IQA1:AMPMODE'],0,'double');

% set the mode to single channel
lcaPut([station, ':STN:IQA1:AMPMODE'], 0);
% set the amplitude detector MUX to klystron output forward
[status,answer] = caShell(['caput -w 20 ', station,':STN:IQA1:MODU.ASS 1']);
if status ~=0
   fprintf(1,'Error - can not set IQ&A module amplitude mux\n');
   return
end

% take the data
fprintf(1,'Moving data from IQA module to file\n');
[status,answer] = caShell(['caput -w 20 ', station,':STN:IQA1:MODU.GAHS 1']);
if status ~=0
   fprintf(1,'Error - can not make IQ&A history buffer file\n');
   return
end
test = 0;	% force the first pass in the while loop
count = 0;	% count how many times we look at the status mesasage
pause(2);	% wait 2 seconds to allow things to start
while test ~= 1,
   [status,answer] = caShell(['caget -t -w 20 ', station,':STN:IQA1:MODU.ASTT']);
   count = count +1;
   test = strcmp(answer(1),'N');
   if count > max_count
      fprintf(1,'Error - can not create the IQA history file - timed out\n');
      return
   end
   if test ~= 1, pause(1), end;	% sleep for 1 second
end; % end of the while loop

% restore the amplitude detector MUX to original MUX setting
[status,answer] = caShell(['caput -w 20 ', station,':STN:IQA1:MODU.ASS ',original_mux_setting]);
if status ~=0
   fprintf(1,'Error - can not restore IQ&A module amplitude mux\n');
   return
end
% restore the mode setting
lcaPut([station, ':STN:IQA1:AMPMODE'], originalModeSetting);

% read the recorded data file
fprintf(1,'Reading data from file\n');
fid1 = -1;
while fid1 == -1; 
   fid1 = fopen([rf_data,'/', station, history_file],'r','ieee-be'); 
end

[header,count] = fread(fid1,[1,21],'char'); 
[data,  count] = fread(fid1,[1,inf],'uint16'); fclose(fid1);

% make the time vector
time = linspace(0,Tsample*count,count);	% time vector

% scale the data to volts at the ADC 
fprintf(1,['Processing data\n'])
% IQA module ampitudes use bits 15:4 of the 15:0 word
% we will divide down the data to ignore bits 3:0
data = (fix((data-32768)/16))/2048;	% ignore lower 4 bits & scale for full scale = 1
out_data = fliplr(data);		% arrange from old to new data

% save some memory
clear data

% read the database coupling loss scale factor
[status,answer] = caShell(['caget -t -w 20 ', station,':KLYSOUTFRWD:IQ:SCALE.A']);
if status ~=0
   fprintf(1,'Error - unable to read coupler ratio\n');
   return
end
coupling_dB = str2num(answer);

% read the database cable loss scale factor
[status,answer] = caShell(['caget -t -w 20 ', station,':KLYSOUTFRWD:IQ:SCALE.B']);
if status ~=0
   fprintf(1,'Error - unable to read cable loss\n');
   return
end
cable_loss_dB = str2num(answer);

% read the database fudge factor
[status,answer] = caShell(['caget -t -w 20 ', station,':KLYSOUTFRWD:IQ:SCALE.F']);
if status ~=0
  fprintf(1,'Error - unable to read fudge factor\n');
   return
end
fudge_factor_dB = str2num(answer);

% read the database amplitude conversion loss
[status,answer] = caShell(['caget -t -w 20 ', station,':KLYSOUTFRWD:A:SCALE.C']);
if status ~=0
  fprintf(1,'Error - unable to read amplitude conversion loss\n');
   return
end
ampl_conv_dB= str2num(answer);

% calcuate the total channel conversion loss in dB
total_dB = coupling_dB + cable_loss_dB + fudge_factor_dB + ampl_conv_dB;

% convert to voltage scale factor
voltage_scaling = 10^(total_dB/20);

% calculate the power in KW
out_data = ((abs(out_data)*voltage_scaling*2).^2)/(100*1e3);

fprintf(1,['Plotting ',station,' Klystron Output Power\n'])
% increment to the next figure
% retrieve figure data
figHandles = handles.figHandles;
figInd=length(figHandles);
figInd=figInd+1; figure(figInd); clf; figHandles(figInd) = figInd;
handles.figHandles = figHandles;
guidata(handles.output, handles); % update  handles data
% figure(2)
% clf
plot( time/1e-3,out_data,'b')
grid on
title(['Klystron Output Power - ',station,'  ',datestr(now,0)])
xlabel('time - ms')
ylabel('power - kW')

fprintf(1,['\n*** Measurement complete ***\n']);
