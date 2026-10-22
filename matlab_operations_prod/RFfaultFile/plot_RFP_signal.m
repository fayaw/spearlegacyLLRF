function plot_RFP_signal(hObject, eventdata, handles)
% plot_RFP_signal.m - File used to plot the fast history buffer fault files
%                     created by the PEP-II RF processing module. This file
%                     opens the SIGNAL_I and SIGNAL_Q fault files and
%                     determines the position of the mux when the data is
%                     plotted.  Both the amplitude and the phase of the
%                     signal are plotted vs time.  Paul 10/9/98

% hObject    handle to loadDataPb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%clear
format compact
%help plot_RFP_signal

fprintf(1,['\n*** Beginning Fast History Buffer Plotting for RFP Module SIGNAL ',...
          'Multiplexer *** \n\n']);

% some config values and strings
num_files = 30;		% maximum number of fault files which will be stored to disk
fault_file_string1 = '/FAULTRfpSI_';	% file name to append fault number to (I)
fault_file_string2 = '/FAULTRfpSQ_';	% file name to append fault number to (Q)


station = handles.station;
% rf_data = getenv('RF_DATA');
rf_data = handles.rfData;

u_header = [rf_data,'/',station];   	% string for the caShell stuff
%Tsample = 1/((72*476e6)/3492);  	    % sampling interval
Tsample = handles.Tsample;
phase_span = 10;			            % initial phase plot will be -span to +span


% define channel names for each mux setting
channel_1 = 'Station Gap Voltage Total';
channel_2 = 'RFP Comb Output';
channel_3 = 'Injected Waveform';
channel_4 = 'Baseband Klystron Drive';


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
   fprintf(1,'Error - can not open selected RFP module SIGNAL fault file\n')
   return
end

% read a fault file to find channel name
% first read 1 word to determine what channel the mux was set to
fprintf(1,'Reading RFP SIGNAL multiplexer setting from file\n');
[header1,count]  = fread(fid1,[1,16],'char');	% read the header string
[mux_data,count] = fread(fid1,[1],'uint16'); fclose(fid1); % read one word
mux_data = bitand(mux_data,3);	% zero the top 14 bits


%channel_name = eval(['channel_',num2str(mux_data+1)]);	% label the signal
%channel_name: eval is not supported by the compiler.

switch mux_data
    case 0
        channel_name = channel_1;
    case 1
        channel_name = channel_2;
    case 2   
        channel_name = channel_3;
    case 3
        channel_name = channel_4;
    otherwise
        fprintf(1,'Error in mux_data value, channel_name was not assigned\n');
end
fprintf(1,['Recorded Signal is %s\n'],channel_name);

% read the measured fault file
% get the file ID again
fid1 = -1;
fid1 = fopen([u_header,fault_file_string1,num2str(file_number)],'r','ieee-be');
if fid1 == -1
   fprintf(1,'Error - can not open selected RFP module SIGNAL fault file\n')
   return
end
fid2 = -1;
fid2 = fopen([u_header,fault_file_string2,num2str(file_number)],'r','ieee-be');
if fid2 == -1
   fprintf(1,'Error - can not open selected RFP module SIGNAL fault file\n')
   return
end

% read the data files
fprintf(1,'Reading %s\n',[u_header,fault_file_string1,num2str(file_number)]);
[header1,count]  = fread(fid1,[1,16],'char');	% read the header string
[i_dat,count1] = fread(fid1,[1,inf],'short'); fclose(fid1);
fprintf(1,'Reading %s\n',[u_header,fault_file_string2,num2str(file_number)]);
[header2,count] = fread(fid2,[1,16],'char');
[q_dat,count2] = fread(fid2,[1,inf],'short'); fclose(fid2);

% scale the data
% RFP module ampitudes use bits 15:4 of the 15:0 word
% we will divide down the data to ignore bits 3:0
i_dat = fix(i_dat/16)/2048;	% ignore lower 4 bits & scale for full scale = 1
q_dat = fix(q_dat/16)/2048;	% ignore lower 4 bits & scale for full scale = 1
out_data = i_dat + j*q_dat;	% make the complex vector
out_data = fliplr(out_data);	% arrange from old to new data

% save some memory
clear i_dat q_dat

% make the time vector
time = linspace(0,Tsample*count1,count1);	% time vector
phase_axis_mean = (180/pi)*mean(angle(out_data));

% plot the time domain response
fprintf(1,['Plotting RFP %s fast fault file #%1.0f\n'],channel_name,file_number)
% increment to the next figure
% retrieve figure data
figHandles = handles.figHandles;
figInd=length(figHandles);
figInd=figInd+1; figure(figInd); clf; figHandles(figInd) = figInd;
% figure(1)
% clf

subplot(211)
plot(time/1e-3,abs(out_data),'b')
junk=axis;
axis([time(1)/1e-3 time(end)/1e-3 junk(3:4)])
grid on
title(['RFP ',channel_name,' Fault File - ',station,' ',datetime])
xlabel('time - ms')
ylabel('amplitude - 1 = full scale')
subplot(212)
plot(time/1e-3,(180/pi)*angle(out_data),'b')
axis([time(1)/1e-3 time(end)/1e-3 phase_axis_mean-phase_span phase_axis_mean+phase_span])
grid on
xlabel('time - ms')
ylabel('angle - degrees')
handles.maxTime(figInd) = max(time);

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
    title(['FFT of RFP ',channel_name,' Fault File - ',station,' ',datetime] );      
end %if handles.fftFlag == 'yes'


% update system variables
%handles.tSample = Tsample;
handles.figHandles = figHandles;
handles.fftFigHandles = fftFigHandles;
handles.time = time;
handles.data = out_data;
% save system variables
guidata( handles.output, handles );

return


% %call zoomgui and extend timeout.
% 
% % this section determines who called this routine. To decide whether
% % to call zoomgui. 
% [ST,I] = dbstack;
% sst = size(ST);
% if sst(1)>1
%   caller = getfield(ST,{2,1},'name');
%   if sum(ismember('fault_file_handler.m',caller))~=20  % call zoomgui and also
%     zoomgui                     	                   % extend the timeout
%     extend_timeout                                     % if called by other than
%   end				                                   % 'fault_file_handler.m'
% else					                               	
%     zoomgui
%     extend_timeout
% end

