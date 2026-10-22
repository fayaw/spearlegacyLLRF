function plot_AIM(hObject, eventdata, handles)
 
% plot_AIM.m -  File used to plot the fast history buffer fault files
%               for PEP-II LLRF AIM detector modules in VXI slot #12.
%               This file opens the AIM amplitude fault file based
%               on the settings of the EPICS fault control and analysis
%               panel.  The amplitude of the channel selected on the
%               AIM module amplitude multiplexer control is plotted
%               as a function of time.  William Colocho, July 2004

% hObject    handle to loadDataPb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


format compact

fprintf(1,'\n*** Beginning Fast History Buffer Plotting for AIM Module in SLOT #12 ***\n\n');

% some config values and strings
num_files = 30;		% maximum number of fault files which will be stored to disk
fault_file_string1 = '/FAULTAim_';	% file name to append fault number to (I)

station = handles.station;
rf_data = handles.rfData;
u_header = [rf_data,'/',station];   	% string for the caShell stuff
Tsample = handles.Tsample;

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

% define channel names for each mux setting

			    
channelName = {'Arc 1'; 'Arc 2'; 'Arc 3'; 'Arc 4'; ...
	       'Arc 5'; 'Arc 6'; 'Arc 7'; 'Arc 8'; ...
               'Arc 9'; 'Arc 10'; 'Arc 11'; 'Arc 12'; ...
               'HVPS Voltage (slow)'; ...
	       'HVPS Current (slow)'; ...
	       'HVPS Current Transformer (fast)'; ...
               'HVPS Voltage ripple (slow)' };
channelUnits = {'Volts'; 'Volts'; 'Volts'; 'Volts' ; ...
		'Volts'; 'Volts'; 'Volts'; 'Volts' ; ...
		'Volts'; 'Volts'; 'Volts'; 'Volts' ; ...
		'K-Volts';'Amps'; 'Amps'; 'K-Volts'};

channelMultiplier = [ 1 1 1 1 1 1 1 1 1 1 1 1 10 5 1 1]; %Channels
                                                         %0-15
							
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

% remove the last characters from the string
%datetime = datetime(1:length(datetime)-1);
datetime = [datetime(1:10),' ' ,datetime(11:end)];

% read the fault file to find channel name
% first read 1 word to determine what channel the mux was set to
fprintf(1,'Reading AIM multiplexer setting from file\n');

% read the measured fault file
% get the file ID 
fid1 = -1;
fid1 = fopen([u_header,fault_file_string1,num2str(file_number)],'r','ieee-be');
if fid1 == -1
   fprintf(1,'Error - can not open selected AIM module #12 fault file\n')
   return
end
fprintf(1,'Reading %s\n',[u_header,fault_file_string1,num2str(file_number)]);

[header1,count]  = fread(fid1,[1,18],'char');	% read the header string
[data,count1] = fread(fid1,[1,inf],'int16'); 

%Need to read data as unsigned to get channel number right. 
frewind(fid1); 
[header1,count]  = fread(fid1,[1,18],'char');	% read the header string
[dataUnsigned,count1] = fread(fid1,[1,inf],'uint16'); fclose(fid1);

data = fliplr(data); %Flip data so time goes left to right.
dataUnsigned = fliplr(dataUnsigned);
% make the time vector in mili-seconds.
timeVector = linspace(0,Tsample*count1,count1) * 1e3;

% scale the data
% AIM module ampitudes use bits 15:4 of the 15:0 word
% 
%%data = (fix((data-32768)/16))/2048;	% ignore lower 4 bits & scale for full scale = 1
dataLength = length(data); 
firstCH = bitand(dataUnsigned(1),15) + 1;
if (firstCH >= 13), nCHs = 4; else nCHs = 16; end
data = bitshift(data,-4,'int16') ; %Drop lower 4 bits.
data = (1.09 * (data ) - 0.01) * (20/2^12) ; %Polynomial scale


samplingFrequency = 10/nCHs; %2.5 MHz for 4 channel mode. 625 kHz for
                             %16 channel mode
% Plot the data.
fprintf(1,['Plotting AIM module fast fault file #%1.0f\n\n'],file_number)

plotOrder = [ 1 2 1 2 1 2 1 2 1 2 1 2 1 2 2 1]; %Used by subplot() calls.
startIndex = 1;

for thisCH = firstCH:16; %Channels to plot. %%%replace firstCH with 13
   if (mod(startIndex,2)) % Two plots per figure.
      % increment to the next figure -  retrieve figure data
      figHandles = handles.figHandles;
      figInd=length(figHandles);
      figInd=figInd+1; figure(figInd); clf; figHandles(figInd) = figInd;
   end % if mod   
   figure(figInd);
   subplot(2,1,plotOrder(thisCH)) 

   time = timeVector(1,startIndex:nCHs:dataLength) * 1e-3;  
   dataCh = data(startIndex:nCHs:dataLength) * channelMultiplier(thisCH); 
 
   if (thisCH >= 13)
     fprintf('%s:  %.2f %s %.2f\n',char(channelName(thisCH)),mean(dataCh), ...
	     setstr(177), std(dataCh));
   end %if thisCH >= 13
   
   plot(time*1e3,dataCh);
   grid on
   title(['AIM Module Fault File - ',station,' ',char(channelName(thisCH)),' ',datetime])
   xlabel('time - ms')
   ylabel(char(channelUnits(thisCH))); 
   handles.maxTime(figInd) = max(time);
   % Plot FFT of data if fftFlag is set on faultFile gui.
  
   % retrieve figure data
   fftFigHandles = handles.fftFigHandles;
   if handles.fftFlag == 1
      if (mod(startIndex,2)) % Two plots per figure.	
         % increment to the next FFT figure 
         fftFigInd=length(fftFigHandles)+20;       %offset fftFigInd by 20 to separate FFT figs.
         fftFigInd=fftFigInd+1; figure(fftFigInd); clf; fftFigHandles(fftFigInd-20) = fftFigInd;
      end % if mod
      figure(fftFigInd);
      subplot(2,1,plotOrder(thisCH))
	 
      %Calculate FFT
      theData = dataCh - mean(dataCh); %subtract mean for fft.
      N = length(theData);          %Number of theData points
      df = samplingFrequency/N;                    %Resolution frequency
      f = [0:df:samplingFrequency - df];           %Analysis frequencies
      
      theData = theData - mean(theData); %subtract DC component.               
      theDATA = abs(fft(theData))/(N/2);                                            
      semilogy(f(1:N/2),theDATA(1:N/2));%Other half of FFT is mirror image.
      grid on					
      xlabel('Frequency (MHz)');
      ylabel('Amplitude');
      title(['FFT of IQA Module #2 Fault File - ',station,' ',char(channelName(thisCH)),' ',datetime] );      
   end %if handles.fftFlag == 'yes'
   
   %update loop varibles.
   handles.fftFigHandles = fftFigHandles;
   handles.figHandles = figHandles;
   
   startIndex = startIndex + 1;
end % for thisCH

guidata( handles.output, handles );
figure(figInd-1);
fprintf(1,'\n*** End of Fast History Buffer Plotting for AIM Module in SLOT #12 ***\n\n');


return

