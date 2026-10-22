function plot_aim(hObject, eventdata, handles)
% hObject    handle to loadDataPb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% plot_aim.m - One shots the Arc Interlock Module history and plots 
%              HVPS waveforms.   William Colocho, September 2004

% 

% general parameters
max_count   = 30;	
Tsample = handles.Tsample;		% sampling frequency
station = handles.station; % use handles structure
rf_data = handles.rfData;   % use handles structure
rf_module = [station,':STN:AIM'];

% define channel names for each mux setting
% Note to change sampling frequency in FFT if more channels are used.
 samplingFrequency = 2.5; %MHz for 4 channel mode. 625 kHz for
                            %16 channel mode
			    
channelName = {'Not used'; 'Not used'; 'Not used'; 'Not used'; ...
	       'Not used'; 'Not used'; 'Not used'; 'Not used'; ...
               'Not used'; 'Not used'; 'Not used'; 'Not used'; ...
               'HVPS Voltage (slow)'; ...
	       'HVPS Current (slow)'; ...
	       'HVPS Current Transformer (fast)'; ...
               'HVPS Voltage ripple (slow)' };

channelUnits = {'none'; 'none'; 'none'; 'none' ; ...
		'none'; 'none'; 'none'; 'none' ; ...
		'none'; 'none'; 'none'; 'none' ; ...
		'K-Volts';'Amps'; 'Amps'; 'K-Volts'};
channelMultiplier = [ 1 1 1 1 1 1 1 1 1 1 1 1 10 5 1 1]; %Channels
                                                         %0-15

fprintf(1,['\n*** Measuring ',station,' Arc Interlock Module Output ***\n']);
fprintf(1,'\nConfiguring RF system - please be patient\n');

% write the desired length of the data files to the RF module driver
[status,answer] = caShell(['caput -w 20 ', rf_module,':MODU.HBSZ ', num2str(512)]);
if status ~=0
   fprintf(1,'Error - can not set the desired file length\n');
   return
end

% write the desired filename to the AIM module history buffer control
[status,answer] = caShell(['caput -w 10 ', station,':STN:AIM:MODU.HBFN /dat/aimHist.dat']);
if status ~=0
   fprintf(1,'Error - can not write AIM module file name\n');
   return
end

% place the module in single shot mode (disable History Buffer Control)
[status,answer] = caShell(['caput -w 20 ', rf_module,':HCTL 1']);
if status ~=0
   fprintf(1,'Error - can not disable AIM History Buffer Control\n');
   return
end

%  take a single shot of data
fprintf(1,'\nTaking a single shot of data\n');
[status,answer] = caShell(['caput -w 20 ', rf_module,':MODU.HGET 1']);
if status ~=0
   fprintf(1,'Error - can not take a single shot of data\n');
   return
end


% get the data files
fprintf(1,'Moving AIM data to file\n');

test = 0;	% force the first pass in the while loop
count = 0;	% count how many times we look at the status mesasage
pause(2);	% wait 2 seconds to allow things to start
while test ~= 1,
   [status,answer] = caShell(['caget -t -w 20 ', rf_module,':MODU']);
   count = count +1;
   test = strcmp(answer(1),'S');
   if count > max_count
     fprintf(1,'Error - can not read the AIM file - timed out\n');
     return
   end
   if test ~= 1, pause(1), end;	% sleep for 1 seconds
end; % end of the while loop

% set the module for fault file saving. (enable History Buffer Control)
[status,answer] = caShell(['caput -w 20 ', rf_module,':HCTL 0']);
if status ~=0
   fprintf(1,'Error - can not enable AIM History Buffer Control\n');
   return
end

fprintf(1,'Reading data files\n');
fid1 = -1;
fid1 = fopen([rf_data,'/',station,'/aimHist.dat'],'r','ieee-be'); 
if fid1 == -1
   fprintf(1,'Error - can not open selected AIM module aimHist.dat file\n')
   return
end

fprintf(1,'Reading %s\n',[rf_data,'/',station,'/aimHist.dat']);
[header1,count]  = fread(fid1,[1,18],'*char');	% read the header string
[data,count1] = fread(fid1,[1,inf],'int16'); fclose(fid1);
data = fliplr(data); %Flip data so time goes left to right.

% make the time vector in mili-seconds.
timeVector = linspace(0,Tsample*count1,count1) * 1e3;

% scale the data
% AIM module ampitudes use bits 15:4 of the 15:0 word

dataLength = length(data);
firstCH = bitand(data(1),15) + 1;
data = bitshift(data,-4) ; %Drop lower 4 bits.
data = (1.09 * (data ) - 0.01) * (20/2^12) ; %Polynomial scale

% Plot the data.
fprintf(1,['Plotting AIM module file\n\n'])

plotOrder = [ 0 0 0 0 0 0 0 0 0 0 0 0 2 1 1 2]; %Used by subplot() calls.
startIndex = 1;
thisCH = firstCH;
for thisCH = 13:16; %Four channels to plot.
   if (mod(thisCH,2)) % Two plots per figure.
      % increment to the next figure -  retrieve figure data
      figHandles = handles.figHandles;
      figInd=length(figHandles);
      figInd=figInd+1; figure(figInd); clf; figHandles(figInd) = figInd;
   end % if mod   
   figure(figInd);
   subplot(2,1,plotOrder(thisCH)) 

   time = timeVector(1,startIndex:4:dataLength);  % Ch1-12 not used.
   dataCh = data(startIndex:4:dataLength) * channelMultiplier(thisCH);  % Ch1-12 not used.
 
   fprintf('%s:  %.2f %s %.2f\n',char(channelName(thisCH)),mean(dataCh), ...
	   setstr(177), std(dataCh));
   
   plot(time,dataCh);
   grid on
   title(['AIM Module  - ',station,' ',char(channelName(thisCH))])
   xlabel('time - ms')
   ylabel(char(channelUnits(thisCH))); 
   
   
   %update loop varibles.
   handles.figHandles = figHandles;
   startIndex = startIndex + 1;
end % for thisCH
%save 
guidata( handles.output, handles );

fprintf(1,'\n*** End of Fast History Buffer Plotting for AIM Module in SLOT #12 ***\n\n');

return


