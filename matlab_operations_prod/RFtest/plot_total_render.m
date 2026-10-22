function plot_total_render(handles)
% Does same plotting as plot_total.m but load data file plotTotalData (No cagets)

disp(['Loading data...'])
load plotTotalData

% increment to the next figure
% retrieve figure data
figHandles = handles.figHandles;
figInd=length(figHandles);
figInd=figInd+1; figure(figInd); clf; figHandles(figInd) = figInd;
handles.figHandles = figHandles;
guidata(handles.output, handles); % update  handles data


% figure(2)
% clf
% only plot 64K of IQ data   7/11/03 plot fails at 2^11 on compiled mode.

plot(i_dat(1:2^10),q_dat(1:2^10),'r.', ...
     [-2 2],[0 0],'b-',[0 0],[-2 2],'b-', ...
     [-1 1 1 -1 -1],[1 1 -1 -1 1],'r-.')

%% This block is temporary to look at render problem. (7/8/03 william)

disp(['2^11 ...']); figure(11);
plot(i_dat(1:2^11),q_dat(1:2^11),'r.')
disp(['2^12 ...']); figure(12);
plot(i_dat(1:2^12),q_dat(1:2^12),'r.')
disp(['2^13 ...']); figure(13);
plot(i_dat(1:2^13),q_dat(1:2^13),'r.')
disp(['2^14 ...']); figure(14);
plot(i_dat(1:2^14),q_dat(1:2^14),'r.')
disp(['2^15 ...']); figure(15);
plot(i_dat(1:2^15),q_dat(1:2^15),'r.')
disp(['2^16 ...']); figure(16);
plot(i_dat(1:2^16),q_dat(1:2^16),'r.') 

%%

axis([-2 2 -2 2])
axis('square')
title(['IQ Plot of Station Gap TOTAL ',station,' ',datestr(now,0)])
xlabel('I voltage - volts')
ylabel('Q voltage - volts')
text(-1.5,-1.1,'Gap transients are visible')
text(-1.5,-1.75,'Magnitude of I or Q should not exceed 1.0 Volts')
grid on


% drawnow

% save some memory
clear i_dat;
clear q_dat;


% calcuate the lowpass time domain response
[B,A] = butter(f_order,f_low_pass*T_sample*2);	% make lowpass to view 0-mode freqs
low_ampl  = filtfilt(B,A,ampl); 	% do the filtering on ampl data
low_phase = filtfilt(B,A,phase);	% do the filtering on phase data

% increment to the next figure
% retrieve figure data
figHandles = handles.figHandles;
figInd=length(figHandles);
figInd=figInd+1; figure(figInd); clf; figHandles(figInd) = figInd;
handles.figHandles = figHandles;
guidata(handles.output, handles); % update  handles data
% figure(3)
% clf
subplot(211)
plot(time*1e3,low_ampl)
junk=axis;
axis([junk(1:2) mean(low_ampl)-5 mean(low_ampl)+5])
xlabel('time - ms')
ylabel('station voltage - kV')
grid on
title(['Station Gap Total ',station,' - 10kHz lowpass filtered  ',datestr(now,0)])
subplot(212)
plot(time*1e3,low_phase)
junk=axis;
axis([junk(1:2) mean(low_phase)-.2 mean(low_phase)+.2])
xlabel('time - ms')
ylabel('phase - degrees')
grid on
% drawnow

% save some memory
clear low_ampl;
clear low_phase;
ampl = ampl(1:504);
phase = phase(1:504);
time = time(1:504);

% increment to the next figure
% retrieve figure data
figHandles = handles.figHandles;
figInd=length(figHandles);
figInd=figInd+1; figure(figInd); clf; figHandles(figInd) = figInd;
handles.figHandles = figHandles;
guidata (handles.output, handles ) %Update handles structure
% figure(4)
% clf
subplot(211)
plot(time*1e6,ampl)
xlabel('time - us')
ylabel('station voltage - kV')
grid on
title(['Station Gap Total ',station,' ',datestr(now,0)])
subplot(212)
plot(time*1e6,phase)
xlabel('time - us')
ylabel('phase - degrees')
grid on
% drawnow

clear ampl;
clear phase;
clear time;

Hsum1 = fft(raw_data .* hanning(length(raw_data))');	% look at the amplitude spectrum
num_fft=length(Hsum1);
Hsum1 = [Hsum1(num_fft/2+2:num_fft) Hsum1(1:num_fft/2+1)]; % reorder by frequency
Hsum2 = fft(unwrap(angle(raw_data) .* hanning(length(raw_data))'));  % look at the phase spectrum
clear raw_data;
Hsum2(1) = num_fft;	% scale the DC phase term to produce results in dBc
Hsum2 = [Hsum2(num_fft/2+2:num_fft) Hsum2(1:num_fft/2+1)]; % reorder by frequency

magnitude1 = 20*log10(abs(Hsum1));
clear Hsum1;
magnitude2 = 20*log10(abs(Hsum2/(num_fft)));	% scale by num_fft for correct dBc calc
clear Hsum2;

magnitude1 = magnitude1 - max(magnitude1);	% scale the amplitude to dBc

delta_f= 1/(T_sample*(num_fft));
baseband_freq=delta_f*[((-1*(num_fft/2 -1)):-1) 0 (1:num_fft/2)];
[value,chop] = min(abs(baseband_freq+freq_wide));	% zoom into freq_wide

% increment to the next figure
% retrieve figure data
figHandles = handles.figHandles;
figInd=length(figHandles);
figInd=figInd+1; figure(figInd); clf; figHandles(figInd) = figInd;
handles.figHandles = figHandles;
guidata (handles.output, handles ) %Update handles structure
% figure(5)
% clf
subplot(211)
plot(baseband_freq(chop:num_fft-chop)/1e6, ...
 magnitude1(chop:num_fft-chop),'r')
junk=axis;
axis([junk(1:2) -120 10]);
grid on
title(['Station Total Amplitude Spectrum ',station,' ',datestr(now,0)])
xlabel('baseband frequency - MHz')
ylabel('amplitude - dBc')
subplot(212)
plot(baseband_freq(chop:num_fft-chop)/1e6, ...
 magnitude2(chop:num_fft-chop),'r') 
junk=axis;
axis([junk(1:2) -120 10]);
grid on
title(['Station Total Phase Spectrum ',station,' ',datestr(now,0)])
xlabel('baseband frequency - MHz')
ylabel('amplitude - dBc')
% drawnow

[value,chop] = min(abs(baseband_freq+freq_zoom));	% zoom into freq_zoom

% increment to the next figure
% retrieve figure data
figHandles = handles.figHandles;
figInd=length(figHandles);
figInd=figInd+1; figure(figInd); clf; figHandles(figInd) = figInd;
handles.figHandles = figHandles;
guidata (handles.output, handles ) %Update handles structure
% figure(6)
% clf
subplot(211)
plot(baseband_freq(chop:num_fft-chop)/1e3, ...
 magnitude1(chop:num_fft-chop),'r') 
junk=axis;
axis([junk(1:2) -140 10]);
grid on
title(['Station Total Amplitude Spectrum ',station,' ',datestr(now,0)])
xlabel('baseband frequency - kHz')
ylabel('amplitude - dBc')
subplot(212)
plot(baseband_freq(chop:num_fft-chop)/1e3, ...
 magnitude2(chop:num_fft-chop),'r') 
junk=axis;
axis([junk(1:2) -140 10]);
grid on
title(['Station Total Phase Spectrum ',station,' ',datestr(now,0)])
xlabel('baseband frequency - kHz')
ylabel('amplitude - dBc')

fprintf(1,['\n*** Measurement complete ***\n']);
