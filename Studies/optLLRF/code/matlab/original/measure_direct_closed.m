function measure_direct_closed(hObject, eventdata, handles)
% hObject    handle to loadDataPb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% measure_direct_closed.m   plots the transfer function of all the station
%                           cavities measured through the RF module with
%                           or without the RF feedback loops on - Paul 12/26/97

% MOD:
% J. Sebek  11/24/2010 - modify plotting routine to scale plot to maximum
%                        amplitude and frequency span
% J. Sebek  03/09/2009 - remove some commented out code
%                        block out some data near the main rf frequency
%                        smooth the phase angle data plot
% J. Sebek, 07/14/2008 - change noise files from NOISE_I_BL_SMALL to
%                        NOISE_I_BL, etc., because now using standard RFP
%                        analog gain of noise signal (x10 less than
%                        previous)
%                        change fs to replace hard-wired PEP frequencies
%                        with machine independent frequency for SPEAR
% J. Sebek, 10/31/2006 - remove unused reference to DSP_file
% W. Colocho, 04/10/2005, Move NOISE_[IQ], NOISE_[IQ]_BL AND
% NOISE_[IQ]_BL_SMALL from /tbl to /dat directory. 
% W. Colocho, 01/12/2004 - For NOISE_I_BL_SMALL.out (and Q) use RF_DATA/<station>
%     (u_header) instead of RFTBL.
% W. Colocho, 10/2/2003 - removed -1 from many calls of the form:
% answer(1:length(answer)-1) as caShell() behaves different than caget()
% W. Colocho, 7/3/2003 back to reading tbl file for noise files(production system.)
%                  also added ieee-be to fopen.
% W. Colocho, 5/1/2003 - use u_header/measured_direct_I/Q files 
%      instead of tbl_dir ones.
% W. Colocho, 12/9/2002 - Made into a function(). It uses handles
% structure to pass data.

format compact

fprintf(1,'\n*** Measuring Closed Loop Response of RF Cavities ***\n');

station = handles.station;      % use handels structure

% here are some configuration strings
 
rf_data = handles.rfData;
tbl_dir = handles.tableDir;
gainFactor = get_RFP_noise_gain(station);%RFP module dependent gain
rf_module    = [station,':STN:RFP'];
handles.rfModule    = rf_module;
% update handles data
guidata(handles.output, handles);

noise_I_file = '/NOISE_I_BL'; % file to load into I DAC
noise_Q_file = '/NOISE_Q_BL'; % file to load into Q DAC
% previously measured noise files
measured_I_noise = '/NOISE_I_BL.out';  
measured_Q_noise = '/NOISE_Q_BL.out'; 
% define the measured loop response file names
v_header = '/dat'; % string for the augeas stuff
u_header = [rf_data,'/',station];   % string for the caShell stuff
measured_direct_I = '/DIRECT_I_CLOSED'; 
measured_direct_Q = '/DIRECT_Q_CLOSED';
% some config values
max_count = 20;			% maximum number of tries to write data files
fs = (handles.samplesPerRev)*(handles.rfFrequency)/(handles.h);     % clock frequency
num_data = 2^18;		% set the desired length of the data files
num_fft  = 2^12;		% set the desired length of FFTs
freq_span = 800e3;		% view data over 476MHz +/- freq_span

% make sure the RF is on - remove carrige return
fprintf(1,'\nConfiguring RF system - please be patient\n');
[status,answer] = caShell(['caget -t -w 20 ', rf_module,':RFENABLE']);
if status ~=0
   fprintf(1,'Error - unable to read RF on/off status\n');
   return
end
if strcmp(answer(1:2),'ON') ~= 1
   fprintf(1,'Error - RF must be on to configure direct loop\n');
   return
end

%save_RFP_mux	% remember the state of the muxes for fast fault data
save_RFP_mux(hObject, eventdata, handles)
handles = guidata(handles.output);  % Updates handles structure

% make sure the direct loop is on - remove carrige return
[status,answer] = caShell(['caget -t -w 20 ', station,':STNDIRECT:LOOP:CTRL']);
if status ~=0
   fprintf(1,'Error - unable to read direct loop on/off status\n');
   return
end
if strcmp(answer(1:2),'ON') ~= 1
   fprintf(1,'Error - Direct loop must be closed for this measurement\n');
   return
end

% write the desired length of the data files to the RF module driver
[status,answer] = caShell(['caput -w 20 ', rf_module,':MODU.RMSZ ', num2str(num_data/1024)]);
if status ~=0
   fprintf(1,'Error - can not set the desired file length\n');
   return
end

% place module in operate mode
[status,answer] = caShell(['caput -w 20 ', rf_module,':RUNMODE 1']);
if status ~=0
   fprintf(1,'Error - can not place RF module into operate mode\n');
   return
end

loadrfstates( rf_module );

% see what files are in the DACs - load correct files if necessary
% first do the I DACs
[status,answer] = caShell(['caget -t -w 20 ', rf_module,':MODU.DIRF']);
if status ~=0
   fprintf(1,'Error - unable to read DAC_I filename\n');
   return
end

if strcmp(answer(1:length(answer)),['/dat',noise_I_file]) ~= 1
   fprintf(1,'loading correct DAC_I file to module RAM\n');
   [status,answer] = caShell(['caput -w 20 ', rf_module,':MODU.DIRF ','/dat',noise_I_file]);
   if status ~=0
      fprintf(1,'Error - can not write the DAC_I filename\n');
      return
   end
   [status,answer] = caShell(['caput -w 20 ', rf_module,':MODU.LDIR 1']);
   if status ~=0
      fprintf(1,'Error - can not load the DAC_I file\n');
      return
   end
   test = 0;	% force the first pass in the while loop
   count = 0;	% count how many times we look at the status mesasage
   pause(2);	% wait 2 seconds to allow things to start
   while test ~= 1,
      [status,answer] = caShell(['caget -t -w 20 ', rf_module,':MODU.DIST']);
      count = count +1;
      test = strcmp(answer(1),'N');
      if count > max_count
         fprintf(1,'Error - can not load the DAC_I file - timed out\n');
         return
      end
      if test ~= 1, pause(1), end;	% sleep for 1 seconds
   end; % end of the while loop
end

% next do the Q DACs
[status,answer] = caShell(['caget -t -w 20 ', rf_module,':MODU.DQRF']);
if status ~=0
   fprintf(1,'Error - unable to read DAC_Q filename\n');
   return
end

if strcmp(answer(1:length(answer)),['/dat',noise_Q_file]) ~= 1   %Removed -1
   fprintf(1,'loading correct DAC_Q file to module RAM\n') ;
   [status,answer] = caShell(['caput -w 20 ', rf_module,':MODU.DQRF ','/dat',noise_Q_file]);
   if status ~=0
      fprintf(1,'Error - can not write the DAC_Q filename\n');
      return
   end
   [status,answer] = caShell(['caput -w 20 ', rf_module,':MODU.LDQR 1']);
   if status ~=0
      fprintf(1,'Error - can not load the DAC_Q file\n') ;
      return
   end
   test = 0;	% force the first pass in the while loop
   count = 0;	% count how many times we look at the status mesasage
   pause(2);	% wait 2 seconds to allow things to start
   while test ~= 1,
      [status,answer] = caShell(['caget -t -w 20 ', rf_module,':MODU.DQST']);
      count = count +1;
      test = strcmp(answer(1),'N');
      if count > max_count
         fprintf(1,'Error - can not load the DAC_Q file - timed out\n') ;
         return
      end
      if test ~= 1, pause(1), end;	% sleep for 1 seconds
   end; % end of the while loop
end

% write the corrrect file names to save data
[status,answer] = caShell(['caput -t -w 20 ', rf_module,':MODU.SIRF ', ...
                         v_header,measured_direct_I]);
if status ~=0
   fprintf(1,'Error - unable to write SIG_I filename\n');
   return
end
[status,answer] = caShell(['caput -t -w 20 ', rf_module,':MODU.SQRF ', ...
                         v_header,measured_direct_Q]);
if status ~=0
   fprintf(1,'Error - unable to write SIG_Q filename\n');
   return
end

% place the module in single shot mode
[status,answer] = caShell(['caput -w 20 ', rf_module,':SSCONT 0']);
if status ~=0
   fprintf(1,'Error - can not place the module in Single Shot mode\n');
   return
end

% enable the DACs
[status,answer] = caShell(['caput -w 20 ', rf_module,':DACS 1']);
if status ~=0
   fprintf(1,'Error - can not enable the DACs\n');
   return
end

% set SIGNAL multiplexer to TOTAL
[status,answer] = caShell(['caput -w 20 ', rf_module,':FBSIG 0']);
if status ~=0
   fprintf(1,'Error - can not set the feedback signal to TOTAL\n');
   return
end

cyclerfstates( rf_module );

% get the data files
% read the SIGNAL_I file first
[status,answer] = caShell(['caput -w 20 ', rf_module,':MODU.GSIR 1']);
if status ~=0
   fprintf(1,'Error - can not activate the SIGNAL_I file read\n');
   return
end
fprintf(1,'Moving data from I channel to file\n');
test = 0;	% force the first pass in the while loop
count = 0;	% count how many times we look at the status mesasage
pause(2);	% wait 2 seconds to allow things to start
while test ~= 1,
   [status,answer] = caShell(['caget -t -w 20 ', rf_module,':MODU.SIST']);
   count = count +1;
   test = strcmp(answer(1),'N');
   if count > max_count
      fprintf(1,'Error - can not read the SIGNAL_I file - timed out\n');
      return
   end
   if test ~= 1, pause(1), end;	% sleep for 1 second
end; % end of the while loop

% read the SIGNAL_Q file now
[status,answer] = caShell(['caput -w 20 ', rf_module,':MODU.GSQR 1']);
if status ~=0
   fprintf(1,'Error - can not activate the SIGNAL_Q file read\n');
   return
end
fprintf(1,'Moving data from Q channel to file\n');
test = 0;	% force the first pass in the while loop
count = 0;	% count how many times we look at the status mesasage
pause(2);	% wait 2 seconds to allow things to start
while test ~= 1,
   [status,answer] = caShell(['caget -t -w 20 ', rf_module,':MODU.SQST']);
   count = count +1;
   test = strcmp(answer(1),'N');
   if count > max_count
      fprintf(1,'Error - can not read the SIGNAL_Q file - timed out\n');
      return
   end
   if test ~= 1, pause(1), end;	% sleep for 1 second
end; % end of the while loop

%restore_RFP_mux  % restore the mux setting for fast history buffers
restore_RFP_mux(hObject, eventdata, handles)
% reset data taking mode to continuous
try
    lcaPut([rf_module,':SSCONT'], 1);
catch
    fprintf(1,'Error - cannot reset data taking mode to continuous\n');
    return;
end % try
% reset, load, run
for ind = 0:2,
    lcaPut([rf_module, ':STATE'], ind);
    pause(0.1);
end % for ind = 0:2,

% make the file ID's
fid1 = -1;
fid2 = -1;
while (fid1 == -1), fid1 = fopen([u_header,measured_direct_I],'r','ieee-be'); end;
while (fid2 == -1), fid2 = fopen([u_header,measured_direct_Q],'r','ieee-be'); end;
fid3 = -1;
fid4 = -1;
%while (fid3 == -1), fid3 = fopen([tbl_dir,measured_I_noise],'r','ieee-be'); end;
%while (fid4 == -1), fid4 = fopen([tbl_dir,measured_Q_noise],'r','ieee-be'); end;
while (fid3 == -1), fid3 = fopen([u_header,measured_I_noise],'r','ieee-be'); end;
while (fid4 == -1), fid4 = fopen([u_header,measured_Q_noise],'r','ieee-be'); end;


% read the recorded noise files
fprintf(1,'Reading data files\n');
[header,count] = fread(fid3,[1,16],'char');
%fprintf(1,'Reading %s%s\n',tbl_dir,measured_I_noise);
fprintf(1,'Reading %s%s\n',u_header,measured_I_noise);
[i_dat,count] = fread(fid3,[1,num_data],'short'); fclose(fid3);
header          = setstr (header);
if count ~= (num_data)
   ['length of file in ',header,' is incorrect. Length = ',num2str(count)]
   return
end
[header,count] = fread(fid4,[1,16],'char');
%fprintf(1,'Reading %s%s\n',tbl_dir,measured_Q_noise);
fprintf(1,'Reading %s%s\n',u_header,measured_Q_noise);
[q_dat,count] = fread(fid4,[1,num_data],'short'); fclose(fid4);
header          = setstr (header);
if count ~= (num_data)
   ['length of file in ',header,' is incorrect. Length = ',num2str(count)]
   return
end

i_dat = (((i_dat/16)*2.0) + 1.0)/4095;
q_dat = (((q_dat/16)*2.0) + 1.0)/4095;
in_data = (i_dat + 1i*q_dat) / gainFactor;
clear i_dat
clear q_dat

% read the measured data files
[header,count] = fread(fid1,[1,16],'char');
fprintf(1,'Reading %s%s\n',u_header,measured_direct_I);
[i_dat,count] = fread(fid1,[1,inf],'short'); fclose(fid1);
header = setstr (header);
if count ~= (num_data)
   ['length of file in ',header,' is incorrect. Length = ',num2str(count)]
   return
end
[header,count] = fread(fid2,[1,16],'char');
fprintf(1,'Reading %s%s\n',u_header,measured_direct_Q);
[q_dat,count] = fread(fid2,[1,inf],'short'); fclose(fid2);
header = setstr (header);
if count ~= (num_data)
   ['length of file in ',header,' is incorrect. Length = ',num2str(count)]
   return
end

i_dat = (((i_dat/16)*2.0) + 1.0)/4095;
q_dat = (((q_dat/16)*2.0) + 1.0)/4095;
out_data = i_dat + 1i*q_dat;
out_data = out_data - mean(out_data);	% ignore the DC term
clear i_dat
clear q_dat

fprintf(1,'Calculating closed loop transfer function\n');
[Hsum,FF]=tfestimate(in_data,out_data,hanning(num_fft),[],num_fft,fs);
Hsum(1) = Hsum(2);		% ignore the DC term - usually has large errors
Hsum=Hsum';
% reorder the results to go from -freq to + freq
Hsum = [Hsum(num_fft/2+2:num_fft) Hsum(1:num_fft/2+1)]; % reorder by frequency

magnitude = 20*log10(abs(Hsum));
phases = angle(Hsum);

delta_f=fs/(num_fft);
baseband_freq=delta_f*[((-1*(num_fft/2 -1)):-1) 0 (1:num_fft/2) ];
[value,chop] = min(abs(baseband_freq+freq_span));	% zoom into freq_span

% increment to the next figure
% retrieve figure data
figHandles = handles.figHandles;
figInd=length(figHandles);
figInd=figInd+1; figure(figInd); clf; figHandles(figInd) = figInd;
handles.figHandles = figHandles;
guidata(handles.output, handles); % update  handles data

% clf
% blank out some middle data points
blankHalfSize = 6;
plotIndFull = chop:(num_fft-chop);
midInd = (1+length(plotIndFull))/2;
plotIndLow =  plotIndFull(1):plotIndFull(round(midInd-blankHalfSize));
plotIndHigh = plotIndFull(round(midInd+blankHalfSize)):plotIndFull(end);
plotIndMid = [plotIndLow(end) plotIndHigh(1)];
subplot(211)
plot(baseband_freq(plotIndLow)/1e3, magnitude(plotIndLow),'r', ...
    baseband_freq([plotIndLow(end) plotIndHigh(1)])/1e3, ...
    magnitude([plotIndLow(end) plotIndHigh(1)]), 'm--', ...
    baseband_freq(plotIndHigh)/1e3, magnitude(plotIndHigh), 'r');
% find maximum amplitude and use that to scale 40dB of relevant gain
gridRes = 10;
delY = 40;
maxAmp = max(magnitude([plotIndLow plotIndHigh]));
yMax = gridRes*ceil(maxAmp/gridRes);
% junk = axis;
axis([baseband_freq([plotIndLow(1) plotIndHigh(end)])/1e3 yMax-delY yMax]);
grid on
title(['Measured Closed Loop Cavity Response - ',...
        station,'  ',datestr(now,0)])
xlabel('baseband frequency - kHz')
ylabel('amplitude - dB')

subplot(212)
phi = (180/pi)*unwrap(angle(exp(1i*phases)));
phiAve = (phi(plotIndFull(1)) + phi(plotIndFull(end)))/2;
phiShift = 360*round(phiAve/360);
plot(baseband_freq(plotIndLow)/1e3, ...
    phi(plotIndLow)-phiShift,'r', ...
    baseband_freq(plotIndMid)/1e3, ...
    phi(plotIndMid)-phiShift,'m--', ...
    baseband_freq(plotIndHigh)/1e3, ...
    phi(plotIndHigh)-phiShift,'r');
v = axis;
axis([baseband_freq([plotIndLow(1) plotIndHigh(end)])/1e3 v(3:4)]);
grid on
xlabel('baseband frequency - kHz')
ylabel('phase - degrees')
zoom on

fprintf(1,'\n*** Measurement of Closed Loop Response Complete ***\n');
