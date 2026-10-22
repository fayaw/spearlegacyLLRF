function plot_GAP(hObject, eventdata, handles)
% hObject    handle to loadDataPb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% plot_GAP.m - File used to plot the fast history buffer fault files
%              for PEP-II LLRF gap voltage feed-forward module.  This
%              file opens the gap madule fault file based on the
%              settings of the EPICS fault control and analysis panel.
%              The baseband kick signal from the longitudinal feedback
%              system is plotted as a function of time.  Paul 10/9/98

%clear
format compact
%help plot_GAP

fprintf(1,'\n*** Beginning Fast History Buffer Plotting for Woofer Kick Signal ***\n\n');

% some config values and strings
num_files = 30;		% maximum number of fault files which will be stored to disk
fault_file_string1 = '/FAULTGvf_';	% file name to append fault number to

% replace with handles.station
% % this section determines who called this routine in order to set the station
% load stnfile     % loads the station variable (escapes the clear)
% [ST,I] = dbstack;
% sst = size(ST);
% if sst(1)>1
%   caller = getfield(ST,{2,1},'name');
%   if sum(ismember('fault_file_handler.m',caller))~=20  % set the station using
%     station = getenv('STATION'); 	                   % the environment variable
%   else                                                 % if called by other than 
%       global time Tsample                              % 'fault_file_handler.m'	
%   end				                                   
% else					                               %If called by 'fault_file_handler.m'
%     station = getenv('STATION');                       %time and Tsample are needed to set 
% end                                                    %number of turns.

station = handles.station;
%rf_data = getenv('RF_DATA');
rf_data = handles.rfData;

u_header = [rf_data,'/',station];   	% string for the caShell stuff
%Tsample = 1/((72*476e6)/3492);  	% sampling interval
Tsample = handles.Tsample;

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

% get the file ID's
fid1 = -1;
fid1 = fopen([u_header,fault_file_string1,num2str(file_number)],'r','ieee-be');
if fid1 == -1
   fprintf(1,'Error - can not open selected Gap module fault file\n')
   return
end

% read the measured fault files
fprintf(1,'Reading %s\n',[u_header,fault_file_string1,num2str(file_number)]);
[header1,count] = fread(fid1,[1,17],'char');	% read the header string
[data,count1] = fread(fid1,[1,inf],'short'); fclose(fid1);

% scale the data
% gap module use bits 15:6 of the 15:0 word
% bits 5:4 are fiber link status bits
% we will divide down the data to ignore bits 5:0
data = fix(data/64);	% ignore lower 6 bits & scale for full scale = 512
out_data = fliplr(data);	% arrange from old to new data

% save some memory
clear data

% make the time vector
time = linspace(0,Tsample*count1,count1);	% time vector

% plot the time domain response
fprintf(1,['Plotting gap module woofer fast fault file #%1.0f\n'],file_number)

% increment to the next figure
% retrieve figure data
figHandles = handles.figHandles;
figInd=length(figHandles);
figInd=figInd+1; figure(figInd); clf; figHandles(figInd) = figInd;
% figure(1)
% clf

plot(time/1e-3,out_data,'b')
grid on
title(['Gap Module Woofer Signal Fault File - ',station,' ',datetime])
xlabel('time - ms')
ylabel('amplitude - counts (512 max)')

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
    title(['FFT of Gap Module Woofer Signal Fault File - ',station,' ',datetime] );      
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

