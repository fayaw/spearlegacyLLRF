function plot_COMBS(hObject, eventdata, handles)
% hObject    handle to loadDataPb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% plot_COMBS.m - File used to plot the fast history buffer fault files
%                for PEP-II LLRF comb filter modules.  This file opens
%                the comb filter fault file based on the settings of
%                the EPICS fault control and analysis panel.  The 
%                amplitude and phase of the comb outputs are plotted
%                as a function of time.  Paul 10/8/98

% clear
format compact
% help plot_COMBS

fprintf(1,'\n*** Beginning Fast History Buffer Plotting for Comb Filters ***\n\n');

% some config values and strings
num_files = 30;		% maximum number of fault files which will be stored to disk
fault_file_string1 = '/FAULTCmbI_';	% file name to append fault number to (I)
fault_file_string2 = '/FAULTCmbQ_';	% file name to append fault number to (Q)

% replace with handles.station
% load stnfile     % loads the station variable (escapes the clear)
% % this section determines who called this routine in order to set the station
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

% rf_data = getenv('RF_DATA');
rf_data = handles.rfData;

u_header = [rf_data,'/',station];   	% string for the unix stuff

%Tsample = 1/((72*476e6)/3492);  	% sampling interval
Tsample = handles.Tsample;

if (handles.faultNumber == 0)
   % read the desired fault file number from the panel
   [status,fltNum] = caShell(['caget -t -w 20 ', station,':STN:FAULT:ANUM']);
   if status ~=0
      fprintf(1,'Error - unable to read selected fault file number\n');
      return
   end  % if status
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
   fprintf(1,'Error - can not open selected Comb I fault file\n')
   return
end
fid2 = -1;
fid2 = fopen([u_header,fault_file_string2,num2str(file_number)],'r','ieee-be');
if fid2 == -1
   fprintf(1,'Error - can not open selected Comb Q fault file\n')
   return
end

% read the measured fault files
fprintf(1,'Reading %s\n',[u_header,fault_file_string1,num2str(file_number)]);
[header1,count] = fread(fid1,[1,11],'char');	% read the header string
[i_dat,count1] = fread(fid1,[1,inf],'short'); fclose(fid1);
fprintf(1,'Reading %s\n',[u_header,fault_file_string2,num2str(file_number)]);
[header2,count] = fread(fid2,[1,11],'char');
[q_dat,count2] = fread(fid2,[1,inf],'short'); fclose(fid2);

% make sure the files are the same length
if count1 ~= count2
   fprintf(1,'Error - Comb I and Comb Q files are of different length\n')
   fprintf(1,['Comb I = %f6.0 samples\n'],count1)
   fprintf(1,['Comb Q = %f6.0 samples\n'],count2)
   return
end

% scale the data
% comb filters use bits 14:3 of the 15:0 word
% we will use all the 15 bits of data and assume
% no overflow has occured
i_dat = i_dat/16384;	% scale for full scale = 1
q_dat = q_dat/16384;	% scale for full scale = 1
out_data = i_dat + j*q_dat;	% make the complex vector
out_data = fliplr(out_data);	% arrange from old to new data

% save some memory
clear i_dat q_dat

% make the time vector
time = linspace(0,Tsample*count1,count1);	% time vector

% plot the time domain response
fprintf(1,['Plotting comb filter fast fault file #%1.0f\n'],file_number)

% increment to the next figure
% retrieve figure data
figHandles = handles.figHandles;
figInd=length(figHandles);
figInd=figInd+1; figure(figInd); clf; figHandles(figInd) = figInd;
% figure(1)
% clf
subplot(211)
plot(time/1e-3,abs(out_data),'b')
grid on
title(['Comb Filter Fault File - ',station,' ',datetime])
xlabel('time - ms')
ylabel('amplitude - 1 = full scale')
subplot(212)
plot(time/1e-3,(180/pi)*angle(out_data),'b')
grid on
xlabel('time - ms')
ylabel('angle - degrees')

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
    title(['FFT of Comb Filter Fault File - ',station,' ',datetime] );      
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
