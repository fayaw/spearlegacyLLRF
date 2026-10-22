function plot_ring_KlysFrwd(hObject, eventdata, handles)
% plot_IQA1.m - File used to plot the fast history buffer fault files
%               for PEP-II LLRF IQA detector modules in VXI slot #7.
%               The amplitude of klystorn output forward power from
%               IQA module amplitude multiplexer is plotted if availabel
%               for the given ring and time stamp.

% hObject    handle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
format compact



fprintf(1,'\n*** Beginning Fast History Buffer Plotting for IQA Module  ***\n\n');

% some config values and strings
num_files = 30;		% maximum number of fault files which will be stored to disk
fault_file_string1 = '/FAULTIqa1Amp_';	% file name to append fault number to (I)

station = handles.station;
rf_data = handles.rfData;
u_header = [rf_data,'/',station];   	% string for the caShell 
%Tsample = 1/((72*476e6)/3492);  	% sampling interval
Tsample = handles.Tsample;

% define channel names for each mux setting
channel_1 = 'Klystron Output Forward';
channel_2 = 'Klystron Output Reflected';
channel_3 = 'Circulator Load Forward';
channel_4 = 'Circulator Load Reflected';
channel_5 = 'Klystron Drive';
channel_6 = 'Station RF Reference';
channel_7 = 'Waveguide 1 Load Forward';
channel_8 = 'Waveguide 1 Load Reflected';

% define the database strings for each mux setting
string_1 = ':KLYSOUTFRWD:';
string_2 = ':KLYSOUTREFL:';
string_3 = ':CIRCLDFRWD:';
string_4 = ':CIRCLDREFL:';
string_5 = ':KLYSDRIVFRWD:';
string_6 = ':STNREF:';
string_7 = ':WG01LDFRWD:';
string_8 = ':WG01LDREFL:';

if (handles.faultNumber == 0)
   % read the desired fault file number from the panel
   [status,fltNum] = caShell(['caget -t -w 20 ', station,':STN:FAULT:ANUM']);
   if status ~=0
      fprintf(1,'Error - unable to read selected fault file number\n');
      return
   end % if status
else
   fltNum = handles.faultNumber;
end %if handles.faultNumber == 0

% check if the fault file number is valid (between 1 and num_files)
file_number = str2num(fltNum);
if file_number <= 0 | file_number >= (num_files+1)
   fprintf(1,['Error - selected fault file error number out of range file# = %1.0f \n'], ...
               file_number);
  return
end

% read the date and time stamp for the file from the EPICS panel
[status,datetime] = caShell(['caget -t -w 20 ', station,':STN:FAULT:TIME', ...
                           num2str(file_number)]);
if status ~=0
   fprintf(1,'Error - unable to read selected fault file date/time stamp\n');
   return
end
% remove the last character from the string
datetime = datetime(1:length(datetime));

%Get list of fault files to plot (one per station)

[theStations, faultNumbers, faultTimes] = getFaultNumber(station,datetime);
stnI = 0;
for i = 1:length(theStations)
  station = theStations(i,:);
  file_number = faultNumbers(i);
  u_header = [rf_data,'/',station];   	% string for caShell calls 

% get the file ID
fid1 = -1;
fid1 = fopen([u_header,fault_file_string1,num2str(file_number)],'r','ieee-be');
if fid1 == -1
   fprintf(1,'Error - can not open selected IQA module #1 fault file\n')
   return
end

% read the fault file to find channel name
% first read 1 word to determine what channel the mux was set to
%fprintf(1,'Reading IQA multiplexer setting from file\n');
[header1,count]  = fread(fid1,[1,21],'char');	% read the header string
[mux_data_compare,count] = fread(fid1,[1],'uint16'); %Used to see if its 8 ch. mode.
[mux_data,count] = fread(fid1,[1],'uint16'); fclose(fid1); % read one word
mux_data_compare = bitand(mux_data_compare,7) + 1;
mux_data = bitand(mux_data,7) + 1;	% zero the top 13 bits and add one

% read the measured fault file
% get the file ID again
fid1 = -1;
fid1 = fopen([u_header,fault_file_string1,num2str(file_number)],'r','ieee-be');
if fid1 == -1
   fprintf(1,'Error - can not open selected IQA module #1 fault file\n')
   return
end
fprintf(1,'Reading %s\n',[u_header,fault_file_string1,num2str(file_number)]);
[header1,count]  = fread(fid1,[1,21],'char');	% read the header string
[data,count1] = fread(fid1,[1,inf],'uint16'); fclose(fid1);

% make the time vector
timeVector = linspace(0,Tsample*count1,count1);	% time vector

% scale the data to volts at the ADC 
% IQA module ampitudes use bits 15:4 of the 15:0 word
% we will divide down the data to ignore bits 3:0
data = (fix((data-32768)/16))/2048;	% ignore lower 4 bits & scale for full scale = 1
data = fliplr(data);		% arrange from old to new data
dataLength = length(data);

% save some memory
% clear data %Need to keep data variable in 8 channel mode.

%channel_name = eval(['channel_',num2str(mux_data+1)]);	% label the signal
%channel_name: eval is not supported by the compiler.
% Determine IQA1 version number.
[status,IQA1vern] = caShell(['caget -t -w 20 ', station,':STN:IQA1:MODU.VERN']);
if status ~=0
   fprintf(1,'Error - unable to read IQA version number\n');
   return
end
 
% if IQA1vern (version number) is 4371 and mux_data for two consecutive
% data points are different then loop through mux_data.

eightChFlag = 0;
if ( (str2num(IQA1vern) == 4371) & (mux_data ~= mux_data_compare) )
   fprintf(1,'Fault file data for station %s saved in 8 channel mode\n',station);
   fprintf(1,'Will not plot data for this station\n\n');
   continue
   eightChFlag = 1;
   mux_data = 1;
end %if str2num(IQA1vern)

%Check if channel saved was channel 1
if ~(mux_data == 1),
  fprintf(1,'Channel saved for station %s not equal to 1\n');
  fprintf(1,'Will not plot data for this station\n\n');
end
   
%check that length of data is 523264 
if ~(length(data) == 523264 )
  fprintf(1,'\nWarning: data file not of standard length for %s\n', station);
  fprintf(1,'Ploting of non-standard file lengths not implemented\n\n');
  continue
end
   
%Since channel is 1 and data is good, will plot this station
stnI = stnI + 1;
stationLegend(stnI) = {theStations(i,:)};
channel_name = channel_1;
muxString = string_1;

   % read the database coupling loss scale factor
   [status,answer] = caShell(['caget -t -w 20 ', station, muxString,'IQ:SCALE.A']);    
   if status ~=0
      fprintf(1,'Error - unable to read coupler ratio\n');
      return
   end
   coupling_dB = str2num(answer);

   % read the database cable loss scale factor
   [status,answer] = caShell(['caget -t -w 20 ', station, muxString,'IQ:SCALE.B']);  
   if status ~=0
      fprintf(1,'Error - unable to read cable loss\n');
      return
   end
   cable_loss_dB = str2num(answer);

   % read the database fudge factor
   [status,answer] = caShell(['caget -t -w 20 ', station, muxString,'IQ:SCALE.F']);
   if status ~=0
     fprintf(1,'Error - unable to read fudge factor\n');
     return
   end
   fudge_factor_dB = str2num(answer);

   % read the database amplitude conversion loss
   [status,answer] = caShell(['caget -t -w 20 ', station,  muxString,'A:SCALE.C']);     
   if status ~=0
     fprintf(1,'Error - unable to read amplitude conversion loss\n');
     return
   end
   ampl_conv_dB= str2num(answer);

   % calcuate the total channel conversion loss in dB
   total_dB = coupling_dB + cable_loss_dB + fudge_factor_dB + ampl_conv_dB;

   % convert to voltage scale factor
   voltage_scaling = 10^(total_dB/20);

   % plot the data - special case for reference power channel

     % calculate the power in KW
     out_data = ((abs(data)*voltage_scaling*2).^2)/(100*1e3);
     outData(stnI,:) = out_data;
     fprintf(1,['Done processing %s fast fault file #%1.0f %s\n'],...
	     channel_name,file_number,datestr(faultTimes(stnI)));

   % Plot FFT of out_data if fftFlag is set on faultFile gui.
   % retrieve figure data
   fftFigHandles = handles.fftFigHandles;
   if handles.fftFlag == 1
     fprintf(1,'Sorry, FFT not implemented for this function\n');
%       % increment to the next FFT figure 
%       fftFigInd=length(fftFigHandles)+20;       %offset fftFigInd by 20 to separate FFT figs.
%       fftFigInd=fftFigInd+1; figure(fftFigInd); clf; fftFigHandles(fftFigInd-20) = fftFigInd;
%    
%       %Calculate FFT
%       theData = out_data;
%       N = length(theData);          %Number of theData points
%       df = handles.samplingFrequency/N;                    %Resolution frequency
%       f = [0:df:handles.samplingFrequency - df];           %Analysis frequencies
%
%       theData = theData - mean(theData); %subtract DC component.               
%       theDATA = abs(fft(theData))/(N/2);                                            
%       semilogy(f(1:N/2),theDATA(1:N/2));  %Other half of FFT is mirror image.  
%       xlabel('Frequency (MHz)');  
%       ylabel('Amplitude');
%       title(['FFT of IQA Module #1 Fault File - ',station,' ',channel_name,' ',datetime] );      
   end %if handles.fftFlag == 'yes'
 
end %for i
     
fprintf(1,'Plotting...\n')
% increment to the next figure
% retrieve figure data
figHandles = handles.figHandles;
figInd=length(figHandles);
figInd=figInd+1; figure(figInd); clf; figHandles(figInd) = figInd;

numberOfPlots = length(stationLegend);
maxPlots = min(5,numberOfPlots);

if (numberOfPlots > 5), subplot(211),end
plot( timeVector/1e-3,outData(1:maxPlots,:) )
grid on
title([' Klystron Output Forward Fault Files -  ',datestr(faultTimes(1))])
xlabel('time - ms')
ylabel('power - kW')
legend(stationLegend(1:maxPlots),0);

if (numberOfPlots > 5 ) 
  subplot(212)
  plot( timeVector/1e-3,outData(maxPlots+1:end,:) )
  grid on
  title([' Klystron Output Forward Fault Files -  ',datestr(faultTimes(1))])
  xlabel('time - ms')
  ylabel('power - kW')
  legend(stationLegend(maxPlots+1:end),0);
end
handles.maxTime(figInd) = max(timeVector);     
handles.figHandles = figHandles;
handles.fftFigHandles = fftFigHandles; 

% update system variables
%handles.tSample = Tsample;
handles.time = timeVector;
handles.data = out_data;
% save system variables
guidata( handles.output, handles );

return
