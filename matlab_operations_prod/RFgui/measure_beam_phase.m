% measure_beam_phase.m - measures the 2 spare wideband RFP channels in region
%                        4 dedicated to measuring the relative beam phase of
%                        both the HER and LER.  
%                        Use Matlab file "null_beam_phase.m" to set the
%                        proper nulling phase shift for each detector.  The
%                        calibration is run when both ring beam phases are
%                        matched.  The turn clock is connected to the spare
%                        data bit so both channels are synchronized in time.
%                        BPM impulses are filtered in a 4 MHz bandpass filter
%                        at 476 MHz so a bunch train of 50 bunches (every other
%                        bucket filled) is required to provide sufficient
%                        signal levels to make accurate phase detections.
%                                                             Paul 11/6/98
%
%
clear
format compact
help measure_beam_phase
global LER_mode_data HER_mode_data LER_current HER_current
fprintf(1,'\n*** Beginning Beam Phase Measurement ***\n');

% general parameters
file_length = '256';			% length of original data file - k
					% after synchronization data will be file_length/2 long
max_count   = 30;			% maximum number of tries to write data files
%freq_wide = 1e6;			% frequency range of wide FFT plot
%freq_zoom = 20e3;			% frequency range of narrow FFT plot
phase_span = 10;			% phase is plotted between -span and +span

station = 'LR44';			% beam phase cables are connected to this station
rf_data = getenv('RF_DATA');
rf_module= [station,':STN:RFP'];
label1 ='HER';
label2 ='LER';
offset =7;		% number of counts to offset data to allign bucket 0 to BIC data
HER_delay = 58 + offset;% number of samples to delay HER data to refer back to region 2
LER_delay = 14 + offset;% number of samples to delay LER data to refer back to region 2
% current/volt scale factor used if either DCCT is dead
HER_scale = 20.6;	% milliamps/volt
LER_scale = 20.6;	% milliamps/volt
min_voltage = 0.003;	% ignore bunches with detected signal smaller than this value (V)
min_bunch_ratio = 0.50;	% only count phases if current > this value * average current/sample

% read the DC beam currents from the DCCT for both rings
[status,answer] = caShell(['caget -t -w 10 HB60:DCCT:SUMY']);
if status ~=0
   fprintf(1,'Unable to read HER DCCT beam current - using internal current scale factor\n');
   answer = '0';
end
HER_current = str2num(answer);
[status,answer] = caShell(['caget -t -w 10 LB60:DCCT:SUMY']);
if status ~=0
   fprintf(1,'Unable to read LER DCCT beam current - using internal current scale factor\n');
   answer = '0';
end
LER_current = str2num(answer);

save_RFP_mux	% remember the state of the muxes for fast fault data

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
  fid2 = -1;
  while (fid1 == -1), fid1 = fopen([rf_data,'/',station,'/', ...
                                 eval(['label',num2str(ring)]),'_BEAM_I'],'r','ieee-be'); end;
  while (fid2 == -1), fid2 = fopen([rf_data,'/',station,'/', ...
                                 eval(['label',num2str(ring)]),'_BEAM_Q'],'r','ieee-be'); end;

  % read the measured data files
  [header,count] = fread(fid1,[1,16],'char');
  [i_dat,count] = fread(fid1,[1,inf],'short'); fclose(fid1);
  header = setstr (header);
  [header,count] = fread(fid2,[1,16],'char');
  [q_dat,count] = fread(fid2,[1,inf],'short'); fclose(fid2);
  header = setstr (header);

  % reread the I data file as unsigned integer to recover the turn clock
  fid1 = -1;
  while (fid1 == -1), fid1 = fopen([rf_data,'/',station,'/', ...
                                 eval(['label',num2str(ring)]),'_BEAM_I'],'r','ieee-be'); end;
  [header,count] = fread(fid1,[1,16],'char');
  [turn_dat,count] = fread(fid1,[1,73],'ushort'); fclose(fid1);

  fprintf(1,['Processing ',eval(['label',num2str(ring)]),' beam phase data\n']);
  % get the turn clock bit to synchronize the HER and LER data
  turn_clock_vector = (bitget(abs(turn_dat(1:73)),4));	% 73 samples per turn
  % find the rising edge of the turn clock and add the delay to region2 from BPM (region 4)
  for count = 1:length(turn_clock_vector)-1,
    if ((turn_clock_vector(count) == 0) & (turn_clock_vector(count+1) == 1))
      edge = rem(count+1+eval([eval(['label',num2str(ring)]),'_delay']),72);
      break;
    end
  end

  i_dat = (fix(i_dat/16))/2047;	% shift down 4 bits and scale
  q_dat = (fix(q_dat/16))/2047;
  raw_data = (i_dat + j*q_dat);
 
  % synchronize the data to the turn clock and make data length an integer number of turns
  raw_data = raw_data(edge:(72*(floor(length(i_dat)/72)-1))+(edge-1)); 
  clear i_dat;
  clear q_dat;

  % flip the data since we read the oldest data first
  raw_data = fliplr(raw_data);

  % limit the size of the data to allow FFTs (not DFTs) when doing Hilbert transforms
  % this should speed up the processing substantially
  raw_data = raw_data(1:72*2^11);	% each sample vector will be 2^11 long

  % ignore the data if current is too small
  too_small = find(abs(raw_data) < min_voltage);	% find samples with small detected voltage
  raw_data(too_small) = 0;				% ignore the small bunches

  % store the raw data for each ring
   eval([eval(['label',num2str(ring)]),'_data = (raw_data);'])

end % of ring(HER & LER) loop

fprintf(1,['\nRestoring RFP multiplexer settings for fast history buffering\n']);
restore_RFP_mux  % restore the mux setting for fast history buffers

fprintf(1,['\nPost processing HER and LER beam phase data\n'])
T_sample = 1/((476e6/3492)*72);
time = T_sample*[0:length(raw_data)-1];
num_turns = floor(length(time)/72);
clear raw_data;

% arrange each ring data to a matrix - 1 row/turn by num_turns
fprintf(1,['Reshaping data into matrix of 72 samples x number of turns\n']);
HER_data = [reshape(HER_data(1:72*num_turns),72,num_turns)];
LER_data = [reshape(LER_data(1:72*num_turns),72,num_turns)];

% scale the data to the DCCT of available, otherwise use fixed scale factor
if  HER_current > 0.1
  fprintf(1,['Scaling HER data to DCCT current\n']);
  HER_data = (HER_data / (sum(mean(abs(HER_data),2)))) * HER_current;
else
  HER_data = HER_data * HER_scale;
end
if  LER_current > 0.1
  fprintf(1,['Scaling LER data to DCCT current\n']);
  LER_data = (LER_data / (sum(mean(abs(LER_data),2)))) * LER_current;
else
  LER_data = LER_data * LER_scale;
end

% calculate the amplitudes and phases
fprintf(1,['Calculating amplitude and phase matrices\n']);
HER_ampl_data =  abs(HER_data);
LER_ampl_data =  abs(LER_data);
HER_phase_data = (180/pi)*angle(HER_data);
LER_phase_data = (180/pi)*angle(LER_data);

% calcuate the standard deviation of the data
fprintf(1,['Calculating amplitude and phase standard deviations\n']);
HER_ampl_std  = std(HER_ampl_data');
LER_ampl_std  = std(LER_ampl_data');
HER_phase_std = std(HER_phase_data');
LER_phase_std = std(LER_phase_data');

% calculate the 1 turn average data vectors
fprintf(1,['Calculating one turn averages of phase and ampitudes\n']);
HER_ampl_mean  = mean(HER_ampl_data');
LER_ampl_mean  = mean(LER_ampl_data');
HER_phase_mean = mean(HER_phase_data');
LER_phase_mean = mean(LER_phase_data');

% find the samples which have sufficient beam current - ignore filter transient
fprintf(1,['Finding buckets with sufficient current to measure phase\n']);
LER_counts = find(LER_ampl_mean > min_bunch_ratio*(max(LER_ampl_mean(6:end))));
HER_counts = find(HER_ampl_mean > min_bunch_ratio*(max(HER_ampl_mean(6:end))));

% throw away the first 5 counts to neglect filter overshoot
LER_counts = LER_counts(find(LER_counts > 5));
HER_counts = HER_counts(find(HER_counts > 5));

% find where HER and LER counts intersect
fprintf(1,['Finding overlapping filled buckets in HER and LER\n']);
overlap = intersect(HER_counts,LER_counts);

% make mode vectors - make phase of small bunches same as the mean
HER_small_counts = find(HER_ampl_mean < min_bunch_ratio*(max(HER_ampl_mean)));
LER_small_counts = find(LER_ampl_mean < min_bunch_ratio*(max(LER_ampl_mean)));

% find the buckets with sufficient current (not small)
HER_normal_counts = find(HER_ampl_mean >= min_bunch_ratio*(max(HER_ampl_mean)));
LER_normal_counts = find(LER_ampl_mean >= min_bunch_ratio*(max(LER_ampl_mean)));

% find the mean of each of the 72 samples/turn with sufficient signal
HER_mode_mean(HER_normal_counts,:)  = mean(HER_phase_data(HER_normal_counts,:),2);
LER_mode_mean(LER_normal_counts,:)  = mean(LER_phase_data(LER_normal_counts,:),2);

% set the mean of the 'dead' data to zero and the data to zero
if ~isempty(HER_small_counts)	% make sure there are some small ones
  HER_mode_mean(HER_small_counts,:) = 0;
  HER_phase_data(HER_small_counts,:) = 0;
end
if ~isempty(LER_small_counts)	% make sure there are some small ones
  LER_mode_mean(LER_small_counts,:) = 0;
  LER_phase_data(LER_small_counts,:) = 0;
end

% calculate the phase difference between HER and LER
phase_difference = HER_phase_mean - LER_phase_mean;

% calculate the mean of the HER and LER phases for plotting
HER_plot_mean = mean(HER_phase_mean(HER_counts));
LER_plot_mean = mean(LER_phase_mean(LER_counts));

figure(2)
clf
subplot(211)
plot(time(1:72)*1e6,HER_ampl_mean,'r-', ...
     time(1:72)*1e6,(HER_ampl_mean+HER_ampl_std),'r:', ...
     time(1:72)*1e6,(HER_ampl_mean-HER_ampl_std),'r:', ...
     time(HER_counts)*1e6,HER_ampl_mean(HER_counts),'r*', ...
     time(1:72)*1e6,LER_ampl_mean,'b-.', ...
     time(1:72)*1e6,(LER_ampl_mean+LER_ampl_std),'b:', ...
     time(1:72)*1e6,(LER_ampl_mean-LER_ampl_std),'b:', ...
     time(LER_counts)*1e6,LER_ampl_mean(LER_counts),'b*')
grid on
xlabel('time - us')
ylabel('beam current - mA/sample')
junk=axis;
text(3.1,0.15*(junk(4)-junk(3))+junk(3),['total HER current = ', ...
          num2str(sum(HER_ampl_mean),'%5.1f'),' mA (red)'])
text(3.1,0.07*(junk(4)-junk(3))+junk(3),['total LER current = ', ...
          num2str(sum(LER_ampl_mean),'%5.1f'),' mA (blue)'])
title(['Measured HER and LER Beam Current and Phase    ',datestr(now,0)])
subplot(212)
plot(time(1:72)*1e6,HER_phase_mean,'r-', ...
     time(1:72)*1e6,(HER_phase_mean+HER_phase_std),'r:', ...
     time(1:72)*1e6,(HER_phase_mean-HER_phase_std),'r:', ...
     time(HER_counts)*1e6,HER_phase_mean(HER_counts),'r*', ...
     time(1:72)*1e6,LER_phase_mean,'b-.', ...
     time(1:72)*1e6,(LER_phase_mean+LER_phase_std),'b:', ...
     time(1:72)*1e6,(LER_phase_mean-LER_phase_std),'b:', ...
     time(LER_counts)*1e6,LER_phase_mean(LER_counts),'b*')
grid on
xlabel('time - us')
ylabel('phase - degrees')
axis([0 8 min(HER_plot_mean,LER_plot_mean)-phase_span ...
          max(HER_plot_mean,LER_plot_mean)+phase_span])
text(3.1,0.9*phase_span,['mean HER phase = ', ...
          num2str(HER_plot_mean,'%4.1f'),' degrees'])
text(3.1,0.7*phase_span,['mean LER phase = ', ...
          num2str(LER_plot_mean,'%4.1f'),' degrees'])
drawnow

figure(3)
clf
plot(time(1:72)*1e6,phase_difference/2,'b-', ...
     time(overlap)*1e6,phase_difference(overlap)/2,'r*')
grid on
xlabel('time - us')
ylabel('collision point variation - degrees')
title(['Beam Phase Error (HER - LER)  ',datestr(now,0),...
			])
axis([0 8  ((HER_plot_mean-LER_plot_mean)-phase_span)/2 ...
           ((HER_plot_mean-LER_plot_mean)+phase_span)/2])
junk=axis;
if length(overlap) > 0
  text(3.1,0.25*(junk(4)-junk(3))+junk(3),['mean collision point error = ', ...
            num2str(mean(phase_difference(overlap)/2),'%4.1f'),' degrees'])
  text(3.1,0.2*(junk(4)-junk(3))+junk(3),['peak to peak collision point error = ', ...
       num2str((max(phase_difference(overlap))-min(phase_difference(overlap)))/2, ...
               '%4.1f'),' degrees'])
else
  text(4.1,0.2*(junk(4)-junk(3))+junk(3),'insufficient current to compare phases')
end
drawnow
fprintf(1,['\nBeam phase measurement complete\n']);

if 1
% discard old data variables
clear HER_ampl_mean;
clear HER_ampl_data;
clear LER_ampl_mean;
clear LER_ampl_data;
clear time;
end

% create mode-specific data for the mode calculating GUI ignoring DC phase
fprintf(1,['\nMaking mode data matrices for HER and LER\n']);
for count = 1:72,
  HER_mode_data(count,:) = HER_phase_data(count,:) - HER_mode_mean(count);
  LER_mode_data(count,:) = LER_phase_data(count,:) - LER_mode_mean(count);
end

% Using a Hilbert transform create a complex vector for each bunch phase
% Also lowpass filter the data by zeroing data in the frequency domain
cutoff = 10e3;	% lowpass cutoff frequency - hz
fft_length = length(LER_mode_data(1,:));
cutoff_index = round(cutoff/(1/(fft_length*(T_sample*72))))+2;
fprintf(1,['Pre processing HER modal data\n']);
HER_fft = fft(HER_mode_data,fft_length,2)/fft_length;	% give gain of 2 after FFT
HER_fft(:,[cutoff_index:fft_length]) = 0;		% zero high and neg freqs
HER_mode_data = 2*ifft(HER_fft,fft_length,2)*fft_length;% back to time domian X2
fprintf(1,['Pre processing LER modal data\n']);
LER_fft = fft(LER_mode_data,fft_length,2)/fft_length;	% give gain of 2 after FFT
LER_fft(:,[cutoff_index:fft_length]) = 0;		% zero high and neg freqs
LER_mode_data = 2*ifft(LER_fft,fft_length,2)*fft_length;% back to time domian X2
clear HER_fft	% save memory
clear LER_fft	% save memory

%call modesgui and extend timeout.

global orig_figs
orig_figs = max(get(0,'children')); % remember how many plots are open
fprintf(1,['Modal analysis GUI coming up\n']);
modesgui        % launch the mode gui tool
extend_timeout

