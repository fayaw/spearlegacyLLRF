function plot_GPIB_scope(hObject, eventdata, handles)
% plot_GPIB_scope.m - File used to plot the fast history buffer fault files
%                     generated from the GPIB scope which can be moved to
%                     anywhere in PEP-II where an ethernet port is available.
%                     This file plots the data from both channels.  Paul 9/20/00
% hObject    handle to loadDataPb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% clear
 format compact
% help plot_GPIB_scope

fprintf(1,'\n*** Beginning Fast History Buffer Plotting for GPIB Scope ***\n\n');

% some config values and strings
num_files = 30;		% maximum number of fault files which will be stored to disk
fault_file_string1 = '/FAULTOsc1CH1_';	% channel 1 file name to append fault number to
fault_file_string2 = '/FAULTOsc1CH2_';	% channel 2 file name to append fault number to

% replace with handles.station
station = handles.station;
% station = getenv('STATION');

rf_data = handles.rfData;
% rf_data = getenv('RF_DATA');

u_header = [rf_data,'/',station];   	% string for the caShell stuff
Tsample = 1/((72*476e6)/3492);  	% sampling interval

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

% get the file ID for scope channel 1
fid1 = -1;
fid1 = fopen([u_header,fault_file_string1,num2str(file_number)],'r','ieee-be');
if fid1 == -1
   fprintf(1,'Error - can not open selected GPIB scope channel #1 fault file - exiting\n')
   pause(20)
   exit
end

% get the file ID for scope channel 2
fid2 = -1;
fid2 = fopen([u_header,fault_file_string2,num2str(file_number)],'r','ieee-be');
if fid2 == -1
   fprintf(1,'Error - can not open selected GPIB scope channel #2 fault file\n')
   return
end

% read the channel 1 fault file header
fprintf(1,'Reading GPIB scope channel 1 file\n');
[header1,count1]    = fread(fid1,[1,300],'char');  % read the header string
[timestamp1,count1] = fread(fid1,[1,32],'char');   % read the timestamp
[channel1,count1]   = fread(fid1,[1,inf],'float64'); % read the channel 1 data
fclose(fid1); 

% read the channel 2 fault file header
fprintf(1,'Reading GPIB scope channel 2 file\n');
[header2,count2]    = fread(fid2,[1,300],'char');% read the header string
[timestamp2,count2] = fread(fid2,[1,32],'char'); % read the timestamp
[channel2,count2]   = fread(fid2,[1,inf],'float64'); % read the channel 2 data
fclose(fid2);

% parse the channel 1 header just to get the number of data points and Tsample
% for now I'll asssume that channel 2 is thew same # points and Tsample as channel 1
[t,r] = strtok(header1,';');	% up to first semicolon - throw away WFID
[t,r] = strtok(r,' ');		% up to next space - throw away
[t,r] = strtok(r,';');		% up to next semicolon - prepare to read NR_PT
[num_points,junk]=sscanf(char(t),'%d');	% get the number of data points
[t,r] = strtok(r,';');		% up to next semicolon - throw away PT_FMT
[t,r] = strtok(r,';');		% up to next semicolon - throw away XUNIT
[t,r] = strtok(r,' ');		% up to next space - throw away
[t,r] = strtok(r,';');		% up to next semicolon - prepare to read XINCR
[Tsample,junk]=sscanf(char(t),'%f');	% get the XINCR in seconds

% make the time vector
time = linspace(0,Tsample*(count1-1),count1);	% time vector

% plot the data
fprintf(1,['Plotting GPIB scope fast fault file #%1.0f\n'],file_number)
% increment to the next figure
% retrieve figure data
figHandles = handles.figHandles;
figInd=length(figHandles);
figInd=figInd+1; figure(figInd); clf; figHandles(figInd) = figInd;
% figure(1)
% clf
subplot(211)
plot(time/1e-3,channel1,'b')
grid on
xlabel('time - ms')
ylabel('Channel 1 - volts')
title(['GPIB Scope Fault File - ',station,'  ',datetime])
subplot(212)
plot(time/1e-3,channel2,'b')
grid on
xlabel('time - ms')
ylabel('Channel 2 - volts')


% Plot FFT of channell and channel2 if fftFlag is set on faultFile gui.
% retrieve figure data
fftFigHandles = handles.fftFigHandles;
if handles.fftFlag == 1
    
    % increment to the next FFT figure 
    fftFigInd=length(fftFigHandles)+20;       %offset fftFigInd by 20 to separate FFT figs.
    fftFigInd=fftFigInd+1; figure(fftFigInd); clf; fftFigHandles(fftFigInd-20) = fftFigInd;
    
    %Calculate FFTs
    theData = channel1;
    N = length(theData);          %Number of theData points
    df = handles.samplingFrequency/N;                    %Resolution frequency
    f = [0:df:handles.samplingFrequency - df];           %Analysis frequencies

    theData = theData - mean(theData); %subtract DC component.               
    theDATA = abs(fft(theData))/(N/2);
    subplot(211)
    semilogy(f(1:N/2),theDATA(1:N/2));  %Other half of FFT is mirror image.  
    xlabel('Frequency (MHz)');
    ylabel('Amplitude');
    title(['FFT of GPIB Scope Fault File CH1 - ',station,' ',datetime] ); 
    
    theData = channel2;
    N = length(theData);          %Number of theData points
    df = handles.samplingFrequency/N;                    %Resolution frequency
    f = [0:df:handles.samplingFrequency - df];           %Analysis frequencies

    theData = theData - mean(theData); %subtract DC component.               
    theDATA = abs(fft(theData))/(N/2);
    subplot(212)
    semilogy(f(1:N/2),theDATA(1:N/2));  %Other half of FFT is mirror image.  
    xlabel('Frequency (MHz)');
    ylabel('Amplitude');
    title(['FFT of GPIB Scope Fault File CH2 - ',station,' ',datetime] ); 
    
end %if handles.fftFlag == 'yes'


% update system variables
handles.tSample = Tsample;
handles.figHandles = figHandles;
handles.time = time;
% handles.data = out_data;
% save system variables
guidata( handles.output, handles );

return


% %call zoomgui and extend timeout.
% 
% zoomgui
% extend_timeout
