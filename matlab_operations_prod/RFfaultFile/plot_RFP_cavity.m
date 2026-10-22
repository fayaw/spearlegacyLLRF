function plot_RFP_cavity(hObject, eventdata, handles)
% plot_RFP_cavity.m - File used to plot the fast history buffer fault files
%                     created by the PEP-II RF processing module. This file
%                     opens the CAVITY_I and CAVITY_Q fault files and
%                     determines the position of the mux when the data is
%                     plotted.  Both the amplitude and the phase of the
%                     signal are plotted vs time.  Paul 10/9/98

% hObject    handle to loadDataPb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%MOD: 17-Oct-2003, W.Colocho, For RFP version 4, The two low order bits of the data
%field that provide the address of the cavity channel are reversed in hardware.
%This file will check RFP version number and reverse channels B and C.

% clear
format compact
% help plot_RFP_cavity

fprintf(1,['\n*** Beginning Fast History Buffer Plotting for RFP Module cavity ',...
          'Multiplexer ***\n\n']);

% some config values and strings
num_files = 30;		% maximum number of fault files which will be stored to disk
fault_file_string1 = '/FAULTRfpCI_';	% file name to append fault number to (I)
fault_file_string2 = '/FAULTRfpCQ_';	% file name to append fault number to (Q)

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

u_header = [rf_data,'/',station];   	% string for the caShell stuff
%Tsample = 1/((72*476e6)/3492);  	% sampling interval
Tsample = handles.Tsample;
phase_span = 10;				% initial phase plot will be -span to +span

% determine if the station is 4 cavities or 2 cavities
[status,answer] = caShell(['caget -t -w 20 ', station,':STN:NCV:PLC']);
if status ~=0
   fprintf(1,'Error - unable to read number of cavities\n');
   return
end
if strcmp (answer(1:3),'4CV' ) == 1
   num_cavities = 4;
elseif strcmp (answer(1:3),'2CV' ) == 1
   num_cavities = 2;
else
   fprintf(1,'Error - incorrect number of cavities - not 4CV or 2CV\n');
   return
end
%**************************************

if num_cavities == 4
  % define channel names for each mux setting
  channel_1 = 'Cavity A';
  channel_2 = 'Cavity B';
  channel_3 = 'Cavity C';
  channel_4 = 'Cavity D';
elseif strcmp(station(1:2),'LR') == 1
  channel_1 = 'Cavity A';
  channel_2 = 'Cavity B';
  channel_3 = 'HER Beam Signal';
  channel_4 = 'LER Beam Signal';
else
  channel_1 = 'Cavity A';
  channel_2 = 'Cavity B';
  channel_3 = 'Spare Channel (3)';
  channel_4 = 'Spare Channel (4)';
end

  
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
%datetime = datetime(1:length(datetime)-1); % removed -1

% get the file ID
fid1 = -1;
fid1 = fopen([u_header,fault_file_string1,num2str(file_number)],'r','ieee-be');
if fid1 == -1
   fprintf(1,'Error - can not open selected RFP module CAVITY fault file\n')
   return
end

% read a fault file to find channel name
% first read 1 word to determine what channel the mux was set to
fprintf(1,'Reading RFP CAVITY multiplexer setting from file\n');
[header1,count]  = fread(fid1,[1,16],'char');	% read the header string
[mux_data,count] = fread(fid1,[1],'uint16'); fclose(fid1); % read one word
mux_data = bitand(mux_data,3);	% zero the top 14 bits

% determine RFP module version. If version 4, mux_data channels B and C are reversed.

% get RFP version number
[status,RFPvern] = caShell(['caget -t -w 20 ', station,':STN:RFP:MODU.VERN']);
if status ~=0
   fprintf(1,'Error - unable to read RFP version number\n');
   return
end

if ((str2num(RFPvern) == 4372) & (~xor(bitcmp(mux_data,2),mux_data))) %only true when mux_data = 1,2
        mux_data = bitcmp(mux_data,2); %flip the bits.
end 

%channel_name: eval is not supported by the compiler.
%channel_name = eval(strcat('channel_',num2str(mux_data+1)))	% label the signal

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

fprintf(1,['Recorded Cavity is %s\n'],channel_name);

% read the measured fault file
% get the file ID again
fid1 = -1;
fid1 = fopen([u_header,fault_file_string1,num2str(file_number)],'r','ieee-be');
if fid1 == -1
   fprintf(1,'Error - can not open selected RFP module CAVITY fault file\n')
   return
end
fid2 = -1;
fid2 = fopen([u_header,fault_file_string2,num2str(file_number)],'r','ieee-be');
if fid2 == -1
   fprintf(1,'Error - can not open selected RFP module CAVITY fault file\n')
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

% calculate a mean phase value used for plotting
phase_axis_mean = (180/pi)*mean(angle(out_data));

% plot the time domain response
fprintf(1,['Plotting RFP %s fast fault file #%1.0f\n'],channel_name,file_number)
% increment to the next figure
% retrieve figure data
figHandles = handles.figHandles;
figInd=length(figHandles);
figInd=figInd+1; figure(figInd); clf; figHandles(figInd) = figInd;
% save figHandles variable
handles.figHandles = figHandles;
guidata( handles.output, handles );
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

% do an extra plot if we are looking at a beam phase file from station LR44
if (strcmp('LR',station(1:2)) & strcmp('Beam Signal',channel_name(5:end)))
num_turns = floor(length(time)/72);
out_phase = (180/pi)*angle([reshape(out_data(1:72*num_turns),72,num_turns)]);
out_amplitude = abs([reshape(out_data(1:72*num_turns),72,num_turns)]);
no_amplitude = find(out_amplitude < (0.5 * max(max(out_amplitude))));
out_phase(no_amplitude) = phase_axis_mean;	% set the gap phase to the mean phase
too_big = find(out_phase > phase_axis_mean+phase_span);
out_phase(too_big) = phase_axis_mean+phase_span;
too_small = find(out_phase < phase_axis_mean-phase_span);
out_phase(too_small) = phase_axis_mean-phase_span;

% increment to the next figure
% retrieve figure data
figHandles = handles.figHandles;
figInd=length(figHandles);
figInd=figInd+1; figure(figInd); clf; figHandles(figInd) = figInd;
% save figHandles variable
handles.figHandles = figHandles;
guidata( handles.output, handles );

%figure(3)
%clf
mesh(out_phase) 
zlabel('phase -degrees')
xlabel('turn number')
ylabel('sample number')
junk=axis;
axis([junk(1:2) 1 72 junk(5:6)]);
view(280,30)
drawnow
title(['RFP ',channel_name,' Fault File Beam Phase Waterfall Plot - ',station,' ',datetime])
set(gcf,'renderer','zbuffer');	% make plotting simpler

% plot the turn-by-turn beam phase

% increment to the next figure
% retrieve figure data
figHandles = handles.figHandles;
figInd=length(figHandles);
figInd=figInd+1; figure(figInd); clf; figHandles(figInd) = figInd;
%figure(4)
%clf
% save figHandles variable
handles.figHandles = figHandles;
guidata( handles.output, handles );

plot([1:72],out_phase)
grid on
junk=axis;
axis([1 72 junk(3:4)])
xlabel('sample number')
ylabel('phase - degrees')
title('Turn-by-Turn Beam Phase Plot')
end % of beam phase plots IF loop

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
% % this section determines who called this routine. 
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
