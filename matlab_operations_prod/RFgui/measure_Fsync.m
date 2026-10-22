function measure_Fsync(hObject, eventdata, handles)
% hObject    handle to loadDataPb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% measure_Fsync.m - Uses BPM buttons in station LR44 to measure the synchrotron
%                   frequency by taking a long FFT of the phase of the beam
%                   induced impulse compared to the region 4 RF reference.
%
%                   Warning - Woofer can alter the synchrotron frequency.
%                             Recommend turning it off during measurment.
%
%                                                           Paul 3/9/2000

% MOD: W. Colocho, 12/9/2002 - Made into a function(). It uses handles
% structure to pass data.

% clear
format compact
% help measure_Fsync
global LER_mode_data HER_mode_data LER_current HER_current
fprintf(1,'\n*** Beginning Synchrotron Frequency Measurement ***\n');

% general parameters
file_length = '512';		% length of original data file - k
decimation_ratio = 200;		% decimation factor to reduce data length
max_count   = 30;		% maximum number of tries to write data files
freq_min = 2e3;			% frequency range of narrow FFT plot - Hz
freq_max = 8e3;			% frequency range of narrow FFT plot - Hz
station = 'LR44';		% beam phase cables are connected to this station
% rf_data = getenv('RF_DATA');
rf_data = handles.rfData;   % use handles structure
rf_module= [station,':STN:RFP'];
label1 ='HER';
label2 ='LER';

% save_RFP_mux	% remember the state of the muxes for fast fault data
save_RFP_mux(hObject, eventdata, handles)
handles = guidata(handles.output);  % Updates handles structure

% write the desired length of the data files to the RF module driver
[status,answer] = caShell(['caput -w 20 ', rf_module,':MODU.RMSZ ', num2str(file_length)]);
if status ~=0
   fprintf(1,'Error - can not set the desired file length\n');
   return
end

% place the module in Reset mode
[status,answer] = caShell(['caput -w 20 ', rf_module,':STATE 0']);
if status ~=0
   fprintf(1,'Error - can not place RF module in Reset state\n');
   return
end

% place the module in single shot mode
[status,answer] = caShell(['caput -w 20 ', rf_module,':SSCONT 0']);
if status ~=0
   fprintf(1,'Error - can not place the module in Single Shot mode\n');
   return
end

% here is the loop which first measures the HER and then the LER
for ring = 1:2,
  
  fprintf(1,['\nMeasuring ',eval(['label',num2str(ring)]),' beam phase\n']);

  % write the desired filename to the CAVITY_I RAM location in RF module
  [status,answer] = caShell(['caput -w 10 ', station, ...
                          ':STN:RFP:MODU.CIRF /dat/',eval(['label',num2str(ring)]),'_BEAM_I']);
  if status ~=0
     fprintf(1,'Error - can not write CAVITY_I file name\n');
     return
  end
  % write the desired filename to the CAVITY_Q RAM location in RF module
  [status,answer] = caShell(['caput -w 10 ', station, ...
                          ':STN:RFP:MODU.CQRF /dat/',eval(['label',num2str(ring)]),'_BEAM_Q']);
  if status ~=0
     fprintf(1,'Error - can not write CAVITY_Q file name\n');
     return
  end

  % disable the DACs
  [status,answer] = caShell(['caput -w 20 ', rf_module,':DACS 0']);
  if status ~=0
     fprintf(1,'Error - can not enable the DACs\n');
     return
  end

  % set CAVITY multiplexer 
  [status,answer] = caShell(['caput -w 20 ', rf_module,':CAVSEL ', num2str(ring+1)]);
  if status ~=0
     fprintf(1,['Error - can not set the cavity multiplexer to ',num2str(ring+1),'\n']);
     return
  end

  % place the module in Reset mode
  [status,answer] = caShell(['caput -w 20 ', rf_module,':STATE 0']);
  if status ~=0
     fprintf(1,'Error - can not place RF module in Reset state\n');
     return
  end

  % place the module in Load mode
  [status,answer] = caShell(['caput -w 20 ', rf_module,':STATE 1']);
  if status ~=0
     fprintf(1,'Error - can not place RF module in Load state\n');
     return
  end

  %  take a single shot of data - go to run mode
  fprintf(1,'Taking a single shot of data\n');
  [status,answer] = caShell(['caput -w 20 ', rf_module,':STATE 2']);
  if status ~=0
     fprintf(1,'Error - can not place RF module in Run state\n');
     return
  end

  % place the module in Load mode
  [status,answer] = caShell(['caput -w 20 ', rf_module,':STATE 1']);
  if status ~=0
     fprintf(1,'Error - can not place RF module in Load state\n');
     return
  end

  pause(1);	% wait for the data

  % get the data files
  fprintf(1,'Moving I data to file\n');
  % read the CAVITY_I file first
  [status,answer] = caShell(['caput -w 20 ', rf_module,':MODU.GCIR 1']);
  if status ~=0
     fprintf(1,'Error - can not activate the CAVITY_I file read\n');
     return
  end
  test = 0;	% force the first pass in the while loop
  count = 0;	% count how many times we look at the status mesasage
  pause(2);	% wait 2 seconds to allow things to start
  while test ~= 1,
     [status,answer] = caShell(['caget -t -w 20 ', rf_module,':MODU.CIST']);
     count = count +1;
     test = strcmp(answer(1),'N');
     if count > max_count
       fprintf(1,'Error - can not read the CAVITY_I file - timed out\n');
       return
     end
     if test ~= 1, pause(1), end;	% sleep for 1 seconds
  end; % end of the while loop

  % read the CAVITY_Q file now
  fprintf(1,'Moving Q data to file\n');
  [status,answer] = caShell(['caput -w 20 ', rf_module,':MODU.GCQR 1']);
  if status ~=0
     fprintf(1,'Error - can not activate the CAVITY_Q file read\n');
     return
  end
  test = 0;	% force the first pass in the while loop
  count = 0;	% count how many times we look at the status mesasage
  pause(2);	% wait 2 seconds to allow things to start
  while test ~= 1,
     [status,answer] = caShell(['caget -t -w 20 ', rf_module,':MODU.CQST']);
     count = count +1;
     test = strcmp(answer(1),'N');
     if count > max_count
       fprintf(1,'Error - can not read the CAVITY_Q file - timed out\n');
       return
     end
     if test ~= 1, pause(1), end;	% sleep for 1 seconds
  end; % end of the while loop

  fprintf(1,['Reading ',eval(['label',num2str(ring)]),' beam phase data files\n']);
  fid1 = -1;
  count = 0;
%  while (fid1 == -1), fid1 = fopen([rf_data,'/',station,'/', ...
%                                 eval(['label',num2str(ring)]),'_BEAM_I'],'r','ieee-be'); end;
%  while (fid2 == -1), fid2 = fopen([rf_data,'/',station,'/', ...
%                                 eval(['label',num2str(ring)]),'_BEAM_Q'],'r','ieee-be'); end;
  while (fid1 == -1)
     count = count + 1;
     fid1 = fopen([rf_data,'/',station,'/', ...
                   eval(['label',num2str(ring)]),'_BEAM_I'],'r','ieee-be');
     if count > max_count
        fprintf(1,['Error - can not read',rf_data,'/',station,'/',...
	          eval(['label',num2str(ring)]),'_BEAM_I - time out\n'])
        return
     end % if(count)
     pause(1), end;     %sleep for 1 seconds
     
  end;%while(fid==-1)

 fid2 = -1;
 count = 0;
 while (fid2 == -1)
     count = count + 1;
     fid1 = fopen([rf_data,'/',station,'/', ...
                   eval(['label',num2str(ring)]),'_BEAM_Q'],'r','ieee-be');
     if count > max_count
        fprintf(1,['Error - can not read',rf_data,'/',station,'/',...
	          eval(['label',num2str(ring)]),'_BEAM_Q - time out\n'])
        return
     end % if(count)
     pause(1), end;     %sleep for 1 seconds     
  end;%while(fid2==-1)

  % read the measured data files
  [header,count] = fread(fid1,[1,16],'char');
  [i_dat,count] = fread(fid1,[1,inf],'short'); fclose(fid1);
  header = setstr (header);
  [header,count] = fread(fid2,[1,16],'char');
  [q_dat,count] = fread(fid2,[1,inf],'short'); fclose(fid2);
  header = setstr (header);

  fprintf(1,['Processing ',eval(['label',num2str(ring)]),' beam phase data\n']);

  i_dat = (fix(i_dat/16))/2047;	% shift down 4 bits and scale
  q_dat = (fix(q_dat/16))/2047;
  raw_data = (i_dat + j*q_dat);
 
  % store the raw data for each ring
   eval([eval(['label',num2str(ring)]),'_data = (raw_data);'])

end % of ring(HER & LER) loop

fprintf(1,['\nRestoring RFP multiplexer settings for fast history buffering\n']);
% restore_RFP_mux  % restore the mux setting for fast history buffers
restore_RFP_mux(hObject, eventdata, handles)

fprintf(1,['Post processing HER and LER beam phase data\n'])
T_sample = 1/((476e6/3492)*72);
clear raw_data i_dat q_dat;

% calculate the amplitudes and phases
HER_phase_data = (180/pi)*angle(HER_data);
LER_phase_data = (180/pi)*angle(LER_data);
clear HER_data LER_data 	% save memory

% decimate the data to reduce length of vectors
fprintf(1,['Decimating phase vectors\n'])
HER_phase_data = decimate(HER_phase_data,decimation_ratio);
LER_phase_data = decimate(LER_phase_data,decimation_ratio);

% take the FFT of the phase data to measure the synchrotron frequency
fprintf(1,['Performing FFTs\n'])
HER_fft = 20*log10(abs(fft(HER_phase_data)));
LER_fft = 20*log10(abs(fft(LER_phase_data)));
clear HER_phase_data LER_phase_data 	% save memory
% strip off the negative frequencies
num_fft = length(HER_fft);
HER_fft = HER_fft(1:num_fft/2);
LER_fft = LER_fft(1:num_fft/2);

% make the frequency vector for plotting
baseband_freq = (1/(T_sample*decimation_ratio*num_fft))*[0:(num_fft/2)-1];
% find the min & max index based on the cutoff frequency
[value,min_index] = min(abs(baseband_freq-freq_min));
[value,max_index] = min(abs(baseband_freq-freq_max));

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
plot(baseband_freq(min_index:max_index)/1e3,HER_fft(min_index:max_index))
junk=axis;
axis([freq_min/1e3 freq_max/1e3 junk(3:4)]);
grid on
title(['Measured Synchotron Resonance for HER    ',datestr(now,0)])
ylabel('HER phase response - dB')
subplot(212)
plot(baseband_freq(min_index:max_index)/1e3,LER_fft(min_index:max_index))
junk=axis;
axis([freq_min/1e3 freq_max/1e3 junk(3:4)]);
grid on
title('Measured Synchotron Resonance for LER')
xlabel('frequency - kHz')
ylabel('LER phase response - dB')
% drawnow
zoom on

fprintf(1,'\n*** Synchrotron Frequency Measurement Complete ***\n');







