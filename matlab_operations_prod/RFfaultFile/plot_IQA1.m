function plot_IQA1(hObject, eventdata, handles)
% plot_IQA1.m - File used to plot the fast history buffer fault files
%               for PEP-II LLRF IQA detector modules in VXI slot #7.
%               This file opens the IQA amplitude fault file based
%               on the settings of the EPICS fault control and analysis
%               panel.  The amplitude of the channel selected on the
%               IQA module amplitude multiplexer control is plotted
%               as a function of time.  Paul 10/8/98

% hObject    handle to loadDataPb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 

%clear
format compact
%help plot_IQA1

fprintf(1,'\n*** Beginning Fast History Buffer Plotting for IQA Module in SLOT #7 ***\n\n');

% some config values and strings
num_files = 30;		% maximum number of fault files which will be stored to disk
fault_file_string1 = '/FAULTIqa1Amp_';	% file name to append fault number to (I)

station = handles.station;

% rf_data = getenv('RF_DATA');
rf_data = handles.rfData;
u_header = [rf_data,'/',station];   	% string for the caShell stuff
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
datetime = datetime(1:length(datetime)-1);

% get the file ID
fid1 = -1;
fid1 = fopen([u_header,fault_file_string1,num2str(file_number)],'r','ieee-be');
if fid1 == -1
   fprintf(1,'Error - can not open selected IQA module #1 fault file\n')
   return
end

% read the fault file to find channel name
% first read 1 word to determine what channel the mux was set to
fprintf(1,'Reading IQA multiplexer setting from file\n');
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
   eightChFlag = 1;
   mux_data = 1;
end %if str2num(IQA1vern)

while (mux_data <= 8) %valid values for mux_data are 1-8

   if (eightChFlag)
     out_data = data(1,(mux_data):8:dataLength);
     time = timeVector(1,(mux_data):8:dataLength);
   else
     out_data = data;
     time = timeVector;
   end % if (eightChFlag)

   switch mux_data
       case 1
           channel_name = channel_1;
           muxString = string_1;
       case 2
           channel_name = channel_2;
           muxString = string_2;
       case 3   
           channel_name = channel_3;
           muxString = string_3;
       case 4
           channel_name = channel_4;
           muxString = string_4;
       case 5
           channel_name = channel_5;
           muxString = string_5;
       case 6
           channel_name = channel_6;
           muxString = string_6;
       case 7   
           channel_name = channel_7;
           muxString = string_7;
       case 8
           channel_name = channel_8;
           muxString = string_8;
       otherwise
           fprintf(1,'Error in mux_data value, channel_name was not assigned\n');
           return;
   end %switch mux_data
   fprintf(1,['Recorded Signal is %s\n'],channel_name);


   %In the following caShell calls, eval() will not compile so it was replaced by muxString 

   % read the database coupling loss scale factor
   [status,answer] = caShell(['caget -t -w 20 ', station, ...
                              muxString,'IQ:SCALE.A']);    
   %                         eval(['string_',num2str(mux_data)]),'IQ:SCALE.A']);
   if status ~=0
      fprintf(1,'Error - unable to read coupler ratio\n');
      return
   end
   coupling_dB = str2num(answer);

   % read the database cable loss scale factor
   [status,answer] = caShell(['caget -t -w 20 ', station, ...
                              muxString,'IQ:SCALE.B']);  
   %                         eval(['string_',num2str(mux_data)]),'IQ:SCALE.B']);
   if status ~=0
      fprintf(1,'Error - unable to read cable loss\n');
      return
   end
   cable_loss_dB = str2num(answer);

   % read the database fudge factor
   [status,answer] = caShell(['caget -t -w 20 ', station, ...
                               muxString,'IQ:SCALE.F']);
   %                         eval(['string_',num2str(mux_data)]),'IQ:SCALE.F']);
   if status ~=0
     fprintf(1,'Error - unable to read fudge factor\n');
     return
   end
   fudge_factor_dB = str2num(answer);

   % read the database amplitude conversion loss
   [status,answer] = caShell(['caget -t -w 20 ', station, ...
                              muxString,'A:SCALE.C']);     
   %                         eval(['string_',num2str(mux_data)]),'A:SCALE.C']);
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
   if mux_data ~=6
     % calculate the power in KW
     out_data = ((abs(out_data)*voltage_scaling*2).^2)/(100*1e3);
     fprintf(1,['Plotting %s fast fault file #%1.0f\n'],channel_name,file_number)
     % increment to the next figure
     % retrieve figure data
     figHandles = handles.figHandles;
     figInd=length(figHandles);
     figInd=figInd+1; figure(figInd); clf; figHandles(figInd) = figInd;
     %figure(1)
     %clf
     plot( time/1e-3,out_data,'b')
     grid on
     title(['IQA Module #1 Fault File - ',station,' ',channel_name,' ',datetime])
     xlabel('time - ms')
     ylabel('power - kW')
     handles.maxTime(figInd) = max(time);
   else
     % plot the time domain response
     % calculate the power in mW
     out_data = ((abs(out_data)*voltage_scaling*2).^2)/(100*1e-3);
     fprintf(1,['Plotting %s fast fault file #%1.0f\n'],channel_name,file_number)
     % increment to the next figure
     % retrieve figure data
     figHandles = handles.figHandles;
     figInd=length(figHandles);
     figInd=figInd+1; figure(figInd); clf; figHandles(figInd) = figInd;
     %figure(1)
     %clf
     plot( time/1e-3,out_data,'b')
     grid on
     title(['IQA Module #1 Fault File - ',station,' ',channel_name,' ',datetime])
     xlabel('time - ms')
     ylabel('power - mW')
     handles.maxTime(figInd) = max(time);
   end

   % Plot FFT of out_data if fftFlag is set on faultFile gui.
   % retrieve figure data
   fftFigHandles = handles.fftFigHandles;
   if handles.fftFlag == 1
    
       % increment to the next FFT figure 
       fftFigInd=length(fftFigHandles)+20;       %offset fftFigInd by 20 to separate FFT figs.
       fftFigInd=fftFigInd+1; figure(fftFigInd); clf; fftFigHandles(fftFigInd-20) = fftFigInd;
    
       %Calculate FFT
       theData = out_data;
       N = length(theData);          %Number of theData points
       df = handles.samplingFrequency/N;                    %Resolution frequency
       f = [0:df:handles.samplingFrequency - df];           %Analysis frequencies

       theData = theData - mean(theData); %subtract DC component.               
       theDATA = abs(fft(theData))/(N/2);                                            
       semilogy(f(1:N/2),theDATA(1:N/2));  %Other half of FFT is mirror image.  
       xlabel('Frequency (MHz)');
       ylabel('Amplitude');
       title(['FFT of IQA Module #1 Fault File - ',station,' ',channel_name,' ',datetime] );      
   end %if handles.fftFlag == 'yes'
 
   if (eightChFlag)
      mux_data = mux_data + 1;      %If 8 channel mode, increment to next mux_data.
   else
      mux_data = 9; % sets mux_data to 9 in single channel mode to exit loop.
   end
 
   handles.figHandles = figHandles;
   handles.fftFigHandles = fftFigHandles; 
end %while(mux_data < =8 )

% update system variables
%handles.tSample = Tsample;
handles.time = time;
handles.data = out_data;
handles
% save system variables
guidata( handles.output, handles );

return
