function measure_klystron_TF(hObject, eventdata, handles)
% hObject    handle to loadDataPb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% measure_direct_closed.m   plots the transfer function of all the station
%                           cavities measured through the RF module with
%                           or without the RF feedback loops on - Paul 12/26/97

% MOD:
%  2008-07-29  jjs
%  modify excitation noise files to be SMALL
% J. Sebek, 10/31/2006 - remove unused reference to DSP_file
% W. Colocho, 04/10/2005, Move NOISE_[IQ], NOISE_[IQ]_BL AND
% NOISE_[IQ]_BL_SMALL from /tbl to /dat directory. 

format compact 

fprintf(1,'\n*** Measuring Klystron Transfer Function ***\n');
% here are some configuration strings

station = handles.station;      % use handles structure
rf_data = handles.rfData;
tbl_dir = handles.tableDir;
gainFactor = get_RFP_noise_gain(station);%RFP module dependent gain
rf_module    = [station,':STN:RFP'];
handles.rfModule    = rf_module;
% update handles data
guidata(handles.output, handles);

noise_I_file = '/NOISE_I_BL_SMALL'; % file to load into I DAC
noise_Q_file = '/NOISE_Q_BL_SMALL'; % file to load into Q DAC
% previously measured noise files
measured_I_noise = '/NOISE_I_BL_SMALL.out';  
measured_Q_noise = '/NOISE_Q_BL_SMALL.out'; 
% define the measured loop response file names
v_header = '/dat'; % string for the augeas stuff
u_header = [rf_data,'/',station];   % string for the caShell stuff
measured_direct_I = '/DIRECT_I_CLOSED'; 
measured_direct_Q = '/DIRECT_Q_CLOSED';

% some config values
max_count = 20;			% maximum number of tries to write data files
fs = 72*476e6/3492;     % clock frequency
ts = 1/fs;			    % sampling interval
f_rf = 476e6;			% rf frequency - Hz
w_rf = f_rf*2*pi;		% rf frequency - radians/sec
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
   fprintf(1,'Error - RF must be on to measure klystron transfer function\n');
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

% set SIGNAL multiplexer to Klystron
[status,answer] = caShell(['caput -w 20 ', rf_module,':FBSIG 7']);
if status ~=0
   fprintf(1,'Error - can not set the feedback signal to Klystron\n');
   return
end

% set Noise selector to Noise 2 (1 is Noise 2)
[status,answer] = caShell(['caput -w 20 ', rf_module,':DINJ 1']);
if status ~=0
   fprintf(1,'Error - can not set the noise selector to Noise 2\n');
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
in_data = (i_dat + j*q_dat) / gainFactor;
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
out_data = i_dat + j*q_dat;
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
% figure(2)
% clf
subplot(211)
plot(baseband_freq(chop:num_fft-chop)/1e3, ...
     magnitude(chop:num_fft-chop),'r') 
junk = axis;
axis([junk(1:2) -20 20])
grid on
title(['Measured Klystron Transfer Function - ',...
        station,'  ',datestr(now,0)])
xlabel('baseband frequency - kHz')
ylabel('amplitude - dB')

subplot(212)
plot(baseband_freq(chop:num_fft-chop)/1e3, ...
     (180/pi)*(angle(exp(j*phases(chop:num_fft-chop)))),'r') 
grid on
xlabel('baseband frequency - kHz')
ylabel('phase - degrees')
zoom on
%drawnow

fprintf(1,'\n*** Measurement of Klystron TF ***\n');
