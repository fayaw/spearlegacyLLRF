
function configure_direct(hObject, eventdata, handles)
% hObject    handle to loadDataPb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
% configure_direct.m - measures the open loop transfer function of the direct
%                      RF feedback loop and adjusts the loop for the specified
%                      phase margins - Paul 9/13/97

% J. Sebek 12/02/2014
%    tried to get system to ramp to configure direct desired setpoints with
%    direct loop on.  Tried to keep DAC level limited by then raising HVPS,
%    stopping this increase when the collector power exceeded its maximum
%    value.  This did not work.  Next time I will try to save desired loop
%    gain and phase settings from configure direct, turn on system to ramp
%    loop to old values.  If that works, I will then try to increment gain
%    and phase PVs from that initial condition.  The code that I modified
%    now starts on line 574
% J. Sebek 11/24/2010  - allow program to read final values of gain and
%                        phase as pvs rather than hard code them in
% J. Sebek 03/09/2009  - combine the repeated file reads into a function
% J. Sebek 02/02/2009  - replace all cashells with lcaGet/lcaPut
% J. Sebek 10/31/2006  - restore original DSP file name if desired one
% cannot be loaded
% MOD: 01-14-2004 W. Colocho, For NOISE_I_BL_SMALL.out (and Q) use RF_DATA/<station>
%     (u_header) instead of RFTBL.
% MOD: W. Colocho, 06/1/2003 - Made into a function(). It uses handles
% structure to pass data. Called by RFguiInvasive.m

fcns = localfunctions;
display(fcns)

format compact

fprintf(1,'\n*** Beginning Direct RF Loop Configuration Sequence ***\n');

% here are some configuration strings

%Use handles structure
station = handles.station;
rf_data = handles.rfData;	
gainFactor = get_RFP_noise_gain(station);%RFP module dependent gain
rf_module    = [station,':STN:RFP'];
handles.rfModule = rf_module; % Needed to pass rf_module to save_RFP_mux
noise_I_file = '/dat/NOISE_I_BL_SMALL'; % file to load into I DAC
noise_Q_file = '/dat/NOISE_Q_BL_SMALL'; % file to load into Q DAC
% previously measured noise files
measured_I_noise = '/NOISE_I_BL_SMALL.out';  
measured_Q_noise = '/NOISE_Q_BL_SMALL.out'; 
% define the measured loop response file names
v_header = '/dat'; % string for the augeas stuff
u_header = [rf_data,'/',station];   % string for the unix stuff
measured_direct_I = '/DIRECT_I_OPEN'; 
measured_direct_Q = '/DIRECT_Q_OPEN';
DSP_file = handles.dspFile; % define DSP files = /dsp/rippleRfp normally

% some config values
max_count = 10;			% maximum number of tries to write data files
Tsample = handles.Tsample;      % sampling interval from handles
fs = 1/Tsample;  		% clock frequency
ts = Tsample;			% sampling interval name used here
f_rf = handles.rfFrequency;	% rf frequency - Hz
F_rf_MHz = handles.rfFrequencyMHz; % rf frequency - MHz
w_rf = f_rf*2*pi;		% rf frequency - radians/sec
num_data = 2^17;		% set the desired leplotFullngth of the data files
num_fft  = 2^13;		% set the desired length of FFTs
t  = linspace(0,ts*num_data,num_data);	% time vector
desired_margin = 66;		% desired phase margin of the direct loop
% chop=3500;			% how much of the data is chopped off
chop=3750;			% how much of the data is chopped off
maxDACCounts = 1900;
max_pass = 10;			% maximum number of iterations to configure direct loop
max_gain_error = 0.25;		% allowed error in loop gain - dB
max_phase_error = 2.0;		% allowed error in loop phase - degrees

% make sure the RF is on - remove carrige return
fprintf(1,'\nConfiguring RF system - please be patient\n');
answer = lcaGet([rf_module, ':RFENABLE']);
if strcmp(answer,'ON') ~=1
    fprintf(1,'Error - RF must be on to configure direct loop\n');
    return
end

%save_RFP_mux	% remember the state of the muxes for fast fault data
save_RFP_mux(hObject, eventdata, handles)
handles = guidata(handles.output);  % Updates handles with mux info

% turn tuner loop to "ON" mode - enable loop
fprintf(1,'Activating tuner loop\n');
lcaPut([station, ':CAVTUNR:LOOP:CTRL'], 'ON');

% write the desired length of the data files to the RF module driver
lcaPut([rf_module,':MODU.RMSZ'], round(num_data/1024));

% enable the drive power loop for ON_CW mode
lcaPut([station,':STN:ON:CTRL'],'ON');

% need to insure that HVPS:LOOP:CTRL is on (2) and station gap voltage is
%  up to desired value
% open the HVPS voltage loop
lcaPut([station,':HVPS:LOOP:CTRL'], 'OFF');

% make sure the ripple loop is closed - remove carrige return
answer = lcaGet([rf_module,':RIPPLELOOP']);
if strcmp(answer,'On') ~= 1
    fprintf(1,'Activating Ripple loop\n');
    lcaPut([rf_module,':RIPPLELOOP'], 'On');
end

% open the gain tracking loop
fprintf(1,'Opening the klystron gain tracking loop\n');
lcaPut([station,':STNRIPPLE:LOOP:TRACK'], 'OFF');

% set the gain tracking actuator to maximum DC value
% first read the maximum setting
max_ripple = lcaGet([station,':STNRIPPLE:LOOP:AMPL.HOPR']);
% write the maximum DC value to the ripple modulator to properly configure direct loop
lcaPut([station,':STNRIPPLE:LOOP:AMPL'], max_ripple);

% unable to open direct loop when station is in CW and running
% open the direct loop
lcaPut([rf_module,':DIRECTLOOP'], 'Off');
% place module in operate mode
lcaPut([rf_module,':RUNMODE'], 'Operate');

loadrfstates( rf_module );

% read the current direct loop conversion factor from the database
conversion = lcaGet([station, ':STNDIRECT:LOOP:COUNTS.E']);
if conversion == 0
    conversion = 100;
    lcaPut([station, ':STNDIRECT:LOOP:COUNTS.E'], conversion);
end

 
% set the direct loop gain offset to zero
lcaPut([station, ':STNDIRECT:LOOP:COUNTS.B'], 0);
% set the direct loop phase offset to zero
lcaPut([station, ':STNDIRECT:LOOP:PHASE.D'], 0);

% see what files are in the DACs - load correct files if necessary
% first do the I DACs
answer = lcaGet([rf_module,':MODU.DIRF']);
if strcmp(answer,noise_I_file) ~= 1
    fprintf(1,'loading correct DAC_I file to module RAM\n');
    lcaPut([rf_module,':MODU.DIRF'], noise_I_file);
    lcaPut([rf_module,':MODU.LDIR'], 1);
    test = 0;	% force the first pass in the while loop
    count = 0;	% count how many times we look at the status mesasage
    pause(2);	% wait 2 seconds to allow things to start
    while test ~= 1,
        answer = lcaGet([rf_module,':MODU.DIST']);
        count = count + 1;
        test = strcmp(answer,'NO_ALARM');
        if count > max_count
            fprintf(1,'Error - can not load the DAC_I file - timed out\n');
            return
        end
        if test ~= 1, pause(1), end;	% sleep for 1 seconds
    end; % end of the while loop
end

% next do the Q DACs
answer = lcaGet([rf_module,':MODU.DQRF']);
if strcmp(answer,noise_Q_file) ~= 1
    fprintf(1,'loading correct DAC_Q file to module RAM\n');
    lcaPut([rf_module,':MODU.DQRF'], noise_Q_file);
    lcaPut([rf_module,':MODU.LDQR'], 1);
    test = 0;	% force the first pass in the while loop
    count = 0;	% count how many times we look at the status mesasage
    pause(2);	% wait 2 seconds to allow things to start
    while test ~= 1,
        answer = lcaGet([rf_module,':MODU.DQST']);
        count = count +1;
        test = strcmp(answer,'NO_ALARM');
        if count > max_count
            fprintf(1,'Error - can not load the DAC_Q file - timed out\n') ;
            return
        end
        if test ~= 1, pause(1), end;	% sleep for 1 seconds
    end; % end of the while loop
end

% write the correct file names to save data
lcaPut([rf_module, ':MODU.SIRF'], [v_header measured_direct_I]);
lcaPut([rf_module, ':MODU.SQRF'], [v_header measured_direct_Q]);

% write the correct file for the DSP and reload it
answer = lcaGet([rf_module,':MODU.DSPE']);
if strcmp(answer,DSP_file) ~= 1
    origFileName = answer;
    fprintf(1,'replacing DSP file %s with %s\n', origFileName, DSP_file );
    lcaPut([rf_module,':MODU.DSPE'], DSP_file);
    lcaPut([rf_module,':MODU.LDSP'], 1);
   test = 0;	% force the first pass in the while loop
   count = 0;	% count how many times we look at the status mesasage
   pause(2);	% wait 2 seconds to allow things to start
   while test ~= 1,
        answer = lcaGet([rf_module,':MODU.DSTT']);
      count = count +1;
      test = strcmp(answer,'NO_ALARM');
      if count > max_count
         fprintf(1,'Error - can not load the DSP file - timed out\n');
         fprintf(1,'  restoring original DSP file name %s\n', origFileName);
         lcaPut([rf_module,':MODU.DSPE'], origFileName);
         lcaPut([rf_module,':MODU.LDSP'], 1);
         return
      end
      if test ~= 1, pause(1), end;	% sleep for 1 seconds
   end; % end of the while loop
end

% place the module in single shot mode
lcaPut([rf_module, ':SSCONT'], 'Single Shot');

% enable the DACs
lcaPut([rf_module, ':DACS'], 'On');

% set SIGNAL multiplexer to TOTAL
lcaPut([rf_module, ':FBSIG'], 'Total');

% turn on the lead compensation
lcaPut([station, ':STNDIRECT:LEADCOMP:CTRL'], 'ON');

% turn off the integral compensation
lcaPut([rf_module,':INTCOMP'], 'Off');

gain_change_db = 999;	% configure these to allow 1st pass thfough while loop
phase_adjust = 999;
pass = 0;

% initialize figure number for plot
figHandles = handles.figHandles; % retrieve figure data
figInd=length(figHandles);
figInd=figInd+1; figHandles(figInd) = figInd;
handles.figHandles = figHandles;
guidata(handles.output, handles); % update  handles data

while (((abs(gain_change_db) > max_gain_error) || (abs(phase_adjust) > max_phase_error)) && ...
        (pass < max_pass)),
 pass = pass + 1;
 
 % read in reference data to in_data
  if pass == 1
    fid3 = -1;
    fid4 = -1;
    while (fid3 == -1), fid3 = fopen([u_header,measured_I_noise],'r','ieee-be'); end;
    while (fid4 == -1), fid4 = fopen([u_header,measured_Q_noise],'r','ieee-be'); end;
    % read the recorded noise files
    [header,count] = fread(fid3,[1,16],'char');
    fprintf(1,'Reading %s%s\n',u_header,measured_I_noise);
    [i_dat,count] = fread(fid3,[1,num_data],'short'); fclose(fid3);
    header          = char(header);
    if count ~= (num_data)
       fprintf(1,'length of file in %s is incorrect. Length = %d\n', ...
           header, count);
       return
    end
    [header,count] = fread(fid4,[1,16],'char');
    fprintf(1,'Reading %s%s\n',u_header,measured_Q_noise);
    [q_dat,count] = fread(fid4,[1,num_data],'short'); fclose(fid4);
    header          = char(header);
    if count ~= (num_data)
       fprintf(1,'length of file in %s is incorrect. Length = %d\n', ...
           header, count);
       return
    end

    i_dat = (((i_dat/16)*2.0) + 1.0)/4095;
    q_dat = (((q_dat/16)*2.0) + 1.0)/4095;
    in_data = (i_dat + 1i*q_dat) / gainFactor;
    clear i_dat
    clear q_dat
  end % if pass == 1
    
  [ out_data ] = configdirectdataacq( max_count, num_data, rf_module, ...
      u_header, measured_direct_I, measured_direct_Q );

  fprintf(1,'Calculating open loop transfer function\n');
  [Hsum,FF]=tfestimate(in_data,out_data,hanning(num_fft),[],num_fft,fs);
  Hsum(1) = Hsum(2);		% ignore the DC term - usually has large errors
  Hsum=Hsum';
  % reorder the results to go from -freq to + freq
  Hsum = [Hsum(num_fft/2+2:num_fft) Hsum(1:num_fft/2+1)]; % reorder by frequency

  magnitude = 20*log10(abs(Hsum));
  phases = angle(Hsum);

  delta_f=fs/(num_fft);
  baseband_freq=delta_f*[((-1*(num_fft/2 -1)):-1) 0 (1:num_fft/2) ];
  
  % set up indices to use for removing fRf peak in plots
  blankHalfSize = 2;
  plotIndFull = chop:(num_fft-chop);
  midInd = (1+length(plotIndFull))/2;
  plotIndLow =  plotIndFull(1):plotIndFull(round(midInd-blankHalfSize));
  plotIndHigh = plotIndFull(round(midInd+blankHalfSize)):plotIndFull(end);
  plotIndMid = [plotIndLow(end) plotIndHigh(1)];


% figHandles = handles.figHandles; % retrieve figure data
% figInd=length(figHandles);
% figInd=figInd+1; figure(figInd); clf; figHandles(figInd) = figInd;
% handles.figHandles = figHandles;
% guidata(handles.output, handles); % update  handles data
  figure(figInd); clf; 
  subplot(211)
%   plot(baseband_freq(chop:num_fft-chop)/1e3, ...
%        magnitude(chop:num_fft-chop),'r') 
  plot(baseband_freq(plotIndLow)/1e3, magnitude(plotIndLow),'r', ...
    baseband_freq(plotIndMid)/1e3, magnitude(plotIndMid), 'r--', ...
    baseband_freq(plotIndHigh)/1e3, magnitude(plotIndHigh), 'r');
  grid on
  title(['Measured Transfer Function of Direct RF Feedback Loop - ',station])
  xlabel('baseband frequency - kHz')
  ylabel('amplitude - dB')

  subplot(212)
%   plot(baseband_freq(chop:num_fft-chop)/1e3, ...
%        (180/pi)*(angle(exp(1i*phases(chop:num_fft-chop)))),'r') 
%   plot(baseband_freq(chop:num_fft-chop)/1e3, ...
%        (180/pi)*(unwrap(angle(exp(1i*phases(chop:num_fft-chop))))),'r') 
  phi = (180/pi)*unwrap(angle(exp(1i*phases)));
  phiAve = (phi(plotIndFull(1)) + phi(plotIndFull(end)))/2;
  phiShift = 360*round(phiAve/360);
  plot(baseband_freq(plotIndLow)/1e3, ...
      phi(plotIndLow)-phiShift,'r', ...
      baseband_freq(plotIndMid)/1e3, ...
      phi(plotIndMid)-phiShift,'r--', ...
      baseband_freq(plotIndHigh)/1e3, ...
      phi(plotIndHigh)-phiShift,'r');
  grid on
  xlabel('baseband frequency - kHz')
  ylabel('phase - degrees')

  % read the current settings of the loop gain and phase shift
  old_magnitude_db = lcaGet([station,':STNDIRECT:LOOP:COUNTS.A']);
  old_phase = lcaGet([station,':STNDIRECT:LOOP:PHASE.C']);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % modified cavity fit section
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    w=2*pi*(F_rf_MHz+baseband_freq(plotIndFull)/1e6);	% make w vector

    % custom fitting routine
    [xTot, fitData] = cavityfit( w, Hsum(plotIndFull), w_rf/1e6 );

    % include these lines to be compatible with older versions in which
    %  x returned the values of the fit
    x = xTot;
    x(1) = x(1)/(2*pi);
    x(5) = x(5)*(180/pi);

    Wc = xTot(1);
    Ql = xTot(2);
    k  = xTot(3);
    Td = xTot(4);
    phase_offset = xTot(5)*(180/pi);
    fprintf(1,'Fitted cavity frequency is %7.4f MHz\n',Wc/(2*pi));
    fprintf(1,'Fitted loaded cavity Q is %4.0f\n',Ql);
    fprintf(1,'Fitted loop gain is %3.1f volts/volt\n',k);
    fprintf(1,'Fitted system delay is %3.0f ns\n',Td);
    fprintf(1,'Fitted phase shift is %3.0f degrees\n',phase_offset);

    % make a fitted magnitude vector and plot it on top of the measured data
    fitted_magnitude = 20*log10(abs(fitData));
    % make a fitted phase vector and plot it on top of the measured data
    fitted_phase = angle(fitData);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % end of modified cavity fit section
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % plot the fitted results
  figure(figInd)
  subplot(211)
  hold on
  plot(baseband_freq(plotIndFull)/1e3,fitted_magnitude,'b')
  subplot(212)
  hold on
  phiFit = (180/pi)*unwrap(angle(exp(1i*fitted_phase)));
  phiFitAve = (phiFit(1) + phiFit(end))/2;
  phiFitShift = 360*round(phiFitAve/360);
  plot(baseband_freq(plotIndFull)/1e3, ...
      phiFit-phiFitShift,'b');
%   plot(baseband_freq(plotIndFull)/1e3, ...
%       (180/pi)*(angle(exp(1i*fitted_phase))),'b')
%   plot(baseband_freq(chop:num_fft-chop)/1e3, ...
%       (180/pi)*(unwrap(angle(exp(1i*fitted_phase)))),'b')
  plot( (Wc/2/pi-F_rf_MHz)*1e3,-180,'+y') % show the desired phase at max gain point 

  % write the fitted delay value to the database
  lcaPut([station,':STNDIRECT:LOOP:PHASE.B'], Td)
  fprintf(1,' Wrote %6.1f ns group delay to :LOOP:PHASE.B\n', Td );

  % calculate the required phase adjustment for 180 loop phase shift
  phase_adjust = phase_offset + 180;
  fprintf(1,'Changing direct loop phase by %6.2f degrees\n',phase_adjust);
  new_phase = mod(old_phase + phase_adjust + 180,360) - 180;
  fprintf(1,' from %6.2f degrees to %6.2f degrees\n', old_phase, new_phase);

  % update the phase
%   lcaPut([station,':STNDIRECT:LOOP:PHASE.C'], new_phase);

  % solve for the available gain to give the desired phase margin
  [freq_margin] = fsolve(@ph_margin,F_rf_MHz - 2,optimset('fsolve'),Ql,Wc,Td,desired_margin);
  % Determine the gain to add to reach the desired margin
  gain_change_db = -20*log10(cavabsfun(2*pi*freq_margin,Ql,Wc,k));
  fprintf(1,'Changing direct loop gain by a factor of %4.2f dB\n',gain_change_db);

  % update the gain setting
  newMagnitudedB = gain_change_db + 20*log10(k);
%   lcaPut([station,':STNDIRECT:LOOP:COUNTS.A'], newMagnitudedB);

  % update the conversion factor for the direct loop gain setting
  conversion = lcaGet([station, ':STNDIRECT:LOOP:COUNTS.E']);  
  fprintf(1,' Current loop gain = %6.2f; conversion factor = %6.2f\n', ...
      old_magnitude_db, conversion );
  fprintf(1,'  give a DAC setting of %4d\n', ...
      round((10^(old_magnitude_db/20))*conversion));
  
  conversion_change = (10^((old_magnitude_db)/20))/k;
  maxConversion = maxDACCounts/(10^(newMagnitudedB/20));
  conversion = min(conversion_change*conversion, ...
      maxConversion);
  lcaPut([station, ':STNDIRECT:LOOP:COUNTS.E'], conversion);  


  fprintf(1,' Pass %d: new loop gain = %6.2f; conversion factor = %6.2f\n', ...
      pass, newMagnitudedB, conversion );
  fprintf(1,'  give a DAC setting of %4d\n', ...
      round((10^(newMagnitudedB/20))*conversion));

  dirloopramp(station, newMagnitudedB, new_phase);
  
  % break loop if DAC is max'd out
  if (conversion == maxConversion),
      fprintf(1,'Exiting loop since conversion DAC is at maximum level\n');
      break;
  end

end % main direct loop adjustment procedure ends here


% now we measure 1 more time before closing loop
[ out_data ] = configdirectdataacq( max_count, num_data, rf_module, ...
    u_header, measured_direct_I, measured_direct_Q );

fprintf(1,'Calculating open loop transfer function\n');
[Hsum,FF]=tfestimate(in_data,out_data,hanning(num_fft),[],num_fft,fs);
Hsum(1) = Hsum(2);		% ignore the DC term - usually has large errors
Hsum=Hsum';
Hsum = [Hsum(num_fft/2+2:num_fft) Hsum(1:num_fft/2+1)]; % reorder by frequency

magnitude = 20*log10(abs(Hsum));
phases    = angle(Hsum);

figure(figInd)
subplot(211)
hold on
% plot(baseband_freq(plotIndFull)/1e3, ...
%      magnitude(plotIndFull),'m')
plot(baseband_freq(plotIndLow)/1e3, magnitude(plotIndLow),'m', ...
    baseband_freq(plotIndMid)/1e3, magnitude(plotIndMid), 'm--', ...
    baseband_freq(plotIndHigh)/1e3, magnitude(plotIndHigh), 'm');
subplot(212)
hold on
% plot(baseband_freq(plotIndFull)/1e3, ...
%      (180/pi)*(angle(exp(1i*phases(plotIndFull)))),'m')
% plot(baseband_freq(chop:num_fft-chop)/1e3, ...
%      (180/pi)*(unwrap(angle(exp(1i*phases(chop:num_fft-chop))))),'m')
phi = (180/pi)*unwrap(angle(exp(1i*phases)));
phiAve = (phi(plotIndFull(1)) + phi(plotIndFull(end)))/2;
phiShift = 360*round(phiAve/360);
plot(baseband_freq(plotIndLow)/1e3, ...
    phi(plotIndLow)-phiShift,'m', ...
    baseband_freq(plotIndMid)/1e3, ...
    phi(plotIndMid)-phiShift,'m--', ...
    baseband_freq(plotIndHigh)/1e3, ...
    phi(plotIndHigh)-phiShift,'m');

fprintf(1,'Fitting system parameters to measured data\n');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % modified cavity fit section
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    w=2*pi*(F_rf_MHz+baseband_freq(plotIndFull)/1e6);	% make w vector

    % custom fitting routine
    [xTot, fitData] = cavityfit( w, Hsum(plotIndFull), w_rf/1e6 );

    % include these lines to be compatible with older versions in which
    %  x returned the values of the fit
    x = xTot;
    x(1) = x(1)/(2*pi);
    x(5) = x(5)*(180/pi);

    Wc = xTot(1);
    Ql = xTot(2);
    k  = xTot(3);
    Td = xTot(4);
    phase_offset = xTot(5)*(180/pi);
    fprintf(1,'Fitted cavity frequency is %7.4f MHz\n',Wc/(2*pi));
    fprintf(1,'Fitted loaded cavity Q is %4.0f\n',Ql);
    fprintf(1,'Fitted loop gain is %3.1f volts/volt\n',k);
    fprintf(1,'Fitted system delay is %3.0f ns\n',Td);
    fprintf(1,'Fitted phase shift is %3.0f degrees\n',phase_offset);

    % make a fitted magnitude vector and plot it on top of the measured data
    fitted_magnitude = 20*log10(abs(fitData));
    % make a fitted phase vector and plot it on top of the measured data
    fitted_phase = angle(fitData);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % end of modified cavity fit section
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% plot the fitted results
figure(figInd)
subplot(211)
hold on
plot(baseband_freq(plotIndFull)/1e3,fitted_magnitude,'b')
subplot(212)
hold on
% plot(baseband_freq(plotIndFull)/1e3, ...
%     (180/pi)*(angle(exp(1i*fitted_phase))),'b')
% plot(baseband_freq(chop:num_fft-chop)/1e3, ...
%     (180/pi)*(unwrap(angle(exp(1i*fitted_phase)))),'b')
phiFit = (180/pi)*unwrap(angle(exp(1i*fitted_phase)));
phiFitAve = (phiFit(1) + phiFit(end))/2;
phiFitShift = 360*round(phiFitAve/360);
plot(baseband_freq(plotIndFull)/1e3, ...
    phiFit-phiFitShift,'b');
plot( (Wc/2/pi-F_rf_MHz)*1e3,-180,'+k') % show the desired phase at max gain point 

% write the fitted delay value to the database
lcaPut([station,':STNDIRECT:LOOP:PHASE.B'], Td);

% check the phase margins of the direct loop
posMagInd = find(fitted_magnitude > 0);
lower_direct_phase_margin = ...
    -(180/pi)*angle(exp(1i*fitted_phase(posMagInd(1))));
upper_direct_phase_margin = ...
    (180/pi)*angle(exp(1i*fitted_phase(posMagInd(length(posMagInd)))));
fprintf(1,'Final direct loop lower phase margin is %6.2f degrees\n', ...
    lower_direct_phase_margin);
fprintf(1,'Final direct loop upper phase margin is %6.2f degrees\n', ...
    upper_direct_phase_margin);

% measure the gain of the direct loop
old_gain_direct = 10^(max(fitted_magnitude)/20);
fprintf(1,'Final maximum open loop gain is %4.2f volts/volt\n',old_gain_direct);

% prepare to measure the closed loop response of the direct loop

% close the HVPS voltage loop
fprintf(1,'\nClosing the HVPS loop\n');
lcaPut([station,':HVPS:LOOP:CTRL'], 'ON');

% configure the klystron gain tracking (AGC) loop
fprintf(1,'Configuring klystron gain tracking loop\n');
% measure the current klystron gain
measured_klystron_gain = lcaGet([station,':KLYS:GAIN']);
% write the measured gain into the AGC setpoint
lcaPut([station,':KLYS:GAIN:CTRL'], measured_klystron_gain);

% close the gain tracking loop
fprintf(1,'Closing the klystron gain tracking loop\n');
lcaPut([station,':STNRIPPLE:LOOP:TRACK'], 'ON');

% close the direct loop
fprintf(1,'\nClosing the direct RF feedback loop\n');
lcaPut([station,':STNDIRECT:LOOP:CTRL'], 'ON');

%restore_RFP_mux  % restore the mux setting for fast history buffers
restore_RFP_mux(hObject, eventdata, handles)

% loop until station is at operating point
pvVFinal = [station, ':STN:VOLT:CTRL'];
pvV = [station, ':STN:VOLT'];
pvStat = {
    [station, ':HVPS:LOOP:STATUS']
    [station, ':STNDAC:LOOP:STATUS']
    };
pvConvFactor = [station, ':STNDIRECT:LOOP:COUNTS.E'];
pvGapDACCount = [station, ':STN:ON:IQ.A'];
pvHvpsCtrl = [station, ':HVPS:VOLT:CTRL.VAL'];
pvHvpsLoop = [station, ':HVPS:LOOP:CTRL']; % 0='OFF", 1='PROC', 2='ON'
pvHvpsMax = [station, ':HVPS:VOLT:ULIM']; 
pvCollMax = [station, ':KLYSCOLL:POWER.HOPR'];
pvCollPwr = [station, ':KLYSCOLL:POWER '];
maxDacCount = 2047;
hvpsDel = 0.2;
hvpsMax = lcaGet(pvHvpsMax);
vFinal = lcaGet(pvVFinal);
collPwrMax = lcaGet(pvCollMax);

% wait until maxDacCount stabilizes
dacCountOld = lcaGet(pvGapDACCount);
pause(5);
dacCount = lcaGet(pvGapDACCount);
fprintf(1, 'waiting for DAC Counts to stabilize\n')
while(abs(dacCount-dacCountOld) > 5),
    fprintf(1, 'DAC Counts = %f\n', abs(dacCount-dacCountOld));
    dacCountOld = dacCount;
    dacCount = lcaGet(pvGapDACCount);
    pause(5);
end % while(abs(dacCount-dacCountOld) > 5),
    
% decrease conversion factor until DacCount below 0.9*maxDacCount
delFact = 5;
minConvFactor = 200;
convFactorDesired = lcaGet(pvConvFactor);
fprintf('decreasing Conv Factor until DAC Counts not saturated\n');
dacCount = lcaGet(pvGapDACCount);
% set initial value of convFactor
convFactor = convFactorDesired;
for ind=convFactorDesired:(-delFact):minConvFactor,
    if (dacCount < 0.9*maxDacCount),
        break;
    else
        lcaPut(pvConvFactor, ind);
        convFactor = ind;
        pause(5);
        dacCount = lcaGet(pvGapDACCount);
        fprintf(1, 'Conv Factor = %f, DAC Count = %f\n', ...
            convFactor, dacCount);
    end % if (dacCount < 0.9*maxDacCount),
end % for ind=convFactorDesired:(-delFact):minConvFactor,
if (convFactor == minConvFactor),
    fprintf('unable to take DAC Counts out of saturation\n');
end % if (convFactor == minConvFactor),

nWait = 120;
fprintf(1,'Waiting up to %d seconds for sequence to close direct loop\n', ...
    nWait);
vDel = 10;
for i1 = 1:nWait,
    status = lcaGet(pvStat);
    vCurrent = lcaGet(pvV);
    hvpsCtrl = lcaGet(pvHvpsCtrl);
    gapDacCount = lcaGet(pvGapDACCount);
    collPwr = lcaGet(pvCollPwr);
    fprintf(1, 'gap voltage DAC = %7.2f;  hvps control = %5.2f\n', ...
        gapDacCount, hvpsCtrl);
    if (gapDacCount > 0.95*maxDacCount),
        % turn off HVPS feedback loop
        lcaPut(pvHvpsLoop, 'OFF');
        % keep dac count at 90% of max
        lcaPut(pvGapDACCount, 0.95*maxDacCount);
        % if collector power is below limit increment hvps voltage
        if (collPwr < collPwrMax),
            lcaPut(pvHvpsCtrl, min(hvpsCtrl + hvpsDel, hvpsMax - 10));
        else
            lcaPut(pvHvpsCtrl, hvpsCtrl - hvpsDel);
        end % if (collPwr < collPwrMax),
    else
        % turn on HVPS feedback loop
        lcaPut(pvHvpsLoop, 'ON');
    end % if (gapDacCount > 0.95*maxDacCount),
%     if (gapDacCount > (maxDacCount - 10)),
%         fprintf(1, 'gap voltage control DAC = %d  end loop\n', ...
%             gapDacCount);
%         break;
%     end
    if ((all(strcmp(status,'GOOD')) || all(strcmp(status,'STN_OFF'))) ...
            && (abs(vFinal - vCurrent) <= vDel))
        break;
    end
    pause(1);
end %  for i1 = 1:nWait,
fprintf(1,'looped through %d times\n', i1);

% increase conversion factor as much as possible
convFactorInit = convFactor;
for ind=convFactor:delFact:convFactorDesired,
    convFactor = ind;
    lcaPut(pvConvFactor, convFactor);
    pause(5);
    gapDacCount = lcaGet(pvGapDACCount);
    fprintf(1, 'Conv Fact = %f, DAC Counts = %f\n', ...
        convFactor, gapDacCount);
    if (gapDacCount > 0.95*maxDacCount),
        break;
    end % if (gapDacCount > 0.95*maxDacCount),
end % for ind=convFactor:delFact:convFactorDesired,
fprintf(1, 'desired conversion factor is %f\n', convFactorDesired );

% set SIGNAL multiplexer to TOTAL
lcaPut([rf_module, ':FBSIG'], 'Total');
% enable the DACs
lcaPut([rf_module, ':DACS'], 'On');

% place the module in single shot mode
lcaPut([rf_module, ':SSCONT'], 'Single Shot');

[ out_data ] = configdirectdataacq( max_count, num_data, rf_module, ...
    u_header, measured_direct_I, measured_direct_Q );

fprintf(1,'Calculating closed loop transfer function\n');
[Hsum,FF]=tfestimate(in_data,out_data,hanning(num_fft),[],num_fft,fs);
Hsum=Hsum';
Hsum = [Hsum(num_fft/2+2:num_fft) Hsum(1:num_fft/2+1)]; % reorder by frequency

magnitude = 20*log10(abs(Hsum));
phases = angle(Hsum);

figure(figInd)
subplot(211)
hold on
% plot(baseband_freq(plotIndFull)/1e3,magnitude(plotIndFull),'g') 
plot(baseband_freq(plotIndLow)/1e3, magnitude(plotIndLow),'g', ...
    baseband_freq(plotIndMid)/1e3, magnitude(plotIndMid), 'g--', ...
    baseband_freq(plotIndHigh)/1e3, magnitude(plotIndHigh), 'g');
subplot(212)
hold on
% plot(baseband_freq(plotIndFull)/1e3, ...
%      (180/pi)*(angle(exp(1i*phases(plotIndFull)))),'g')
% plot(baseband_freq(chop:num_fft-chop)/1e3, ...
%      (180/pi)*(unwrap(angle(exp(1i*phases(chop:num_fft-chop))))),'g')
phi = (180/pi)*unwrap(angle(exp(1i*phases)));
phiAve = (phi(plotIndFull(1)) + phi(plotIndFull(end)))/2;
phiShift = 360*round(phiAve/360);
plot(baseband_freq(plotIndLow)/1e3, ...
    phi(plotIndLow)-phiShift,'g', ...
    baseband_freq(plotIndMid)/1e3, ...
    phi(plotIndMid)-phiShift,'g--', ...
    baseband_freq(plotIndHigh)/1e3, ...
    phi(plotIndHigh)-phiShift,'g');


% current place holder before fitting routine is written
dirLoopGain = lcaGet('SRF1:STNDIRECT:LOOP:COUNTS.I');
dirLoopPhase = lcaGet('SRF1:STNDIRECT:LOOP:COUNTS.J');
fprintf(1, '\nramping to direct loop settings of %f dB and %f phase\n', ...
    dirLoopGain, dirLoopPhase);
dirloopramp(station, dirLoopGain, dirLoopPhase);

% if the conversion factor is not at its desired value, ramp it to this
% value
for ind = convFactor:delFact:convFactorDesired,
    lcaPut(pvConvFactor, ind);
    pause(5);
    dacCount = lcaGet(pvGapDACCount);
    if (dacCount > 0.95*maxDacCount),
        break;
    end % if (dacCount > 0.95*maxDacCount),
end % for ind = convFactor:delFact:convFactorDesired,

% need to make a function out of these next plotting lines
[ out_data ] = configdirectdataacq( max_count, num_data, rf_module, ...
    u_header, measured_direct_I, measured_direct_Q );

fprintf(1,'Calculating closed loop transfer function\n');
[Hsum,FF]=tfestimate(in_data,out_data,hanning(num_fft),[],num_fft,fs);
Hsum=Hsum';
Hsum = [Hsum(num_fft/2+2:num_fft) Hsum(1:num_fft/2+1)]; % reorder by frequency

magnitude = 20*log10(abs(Hsum));
phases = angle(Hsum);

% initialize figure number for plot
figHandles = handles.figHandles; % retrieve figure data
figInd=length(figHandles);
figInd=figInd+1; figHandles(figInd) = figInd;
handles.figHandles = figHandles;
guidata(handles.output, handles); % update  handles data
figure(figInd);clf;
subplot(211)
% plot(baseband_freq(plotIndFull)/1e3,magnitude(plotIndFull)) 
plot(baseband_freq(plotIndLow)/1e3, magnitude(plotIndLow),'r', ...
    baseband_freq(plotIndMid)/1e3, magnitude(plotIndMid), 'r--', ...
    baseband_freq(plotIndHigh)/1e3, magnitude(plotIndHigh), 'r');
grid('on')
title(['Measured Transfer Function of Direct RF Feedback Loop - ',station])
xlabel('baseband frequency - kHz')
ylabel('amplitude - dB')
subplot(212)
% plot(baseband_freq(plotIndFull)/1e3, ...
%      (180/pi)*(angle(exp(1i*phases(plotIndFull)))))
phi = (180/pi)*unwrap(angle(exp(1i*phases)));
phiAve = (phi(plotIndFull(1)) + phi(plotIndFull(end)))/2;
phiShift = 360*round(phiAve/360);
plot(baseband_freq(plotIndLow)/1e3, ...
    phi(plotIndLow)-phiShift,'r', ...
    baseband_freq(plotIndMid)/1e3, ...
    phi(plotIndMid)-phiShift,'r--', ...
    baseband_freq(plotIndHigh)/1e3, ...
    phi(plotIndHigh)-phiShift,'r');
grid('on')
xlabel('baseband frequency - kHz')
ylabel('phase - degrees')

%restore_RFP_mux  % restore the mux setting for fast history buffers
restore_RFP_mux(hObject, eventdata, handles)

fprintf(1,'\n*** Direct RF Loop Configuration Sequence Complete***\n');

return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ out_data ] = configdirectdataacq( max_count, num_data, ...
    rf_module, u_header, measured_direct_I, measured_direct_Q )

cyclerfstates( rf_module );

% get the data files
% read the SIGNAL_I file first
lcaPut([rf_module,':MODU.GSIR'], 1);
fprintf(1,'Moving data from I channel to file\n');
test = 0;	% force the first pass in the while loop
count = 0;	% count how many times we look at the status mesasage
pause(2);	% wait 2 seconds to allow things to start
while test ~= 1,
   answer = lcaGet([rf_module,':MODU.SIST']);
   count = count +1;
   test = strcmp(answer, 'NO_ALARM');
   if count > max_count
      fprintf(1,'Error - can not read the SIGNAL_I file - timed out\n');
      return
   end
   if test ~= 1, pause(1), end;	% sleep for 1 second
end; % end of the while loop

% read the SIGNAL_Q file now
lcaPut([rf_module,':MODU.GSQR'], 1);
fprintf(1,'Moving data from Q channel to file\n');
test = 0;	% force the first pass in the while loop
count = 0;	% count how many times we look at the status mesasage
pause(2);	% wait 2 seconds to allow things to start
while test ~= 1,
   answer = lcaGet([rf_module,':MODU.SQST']);
   count = count +1;
   test = strcmp(answer, 'NO_ALARM');
   if count > max_count
      fprintf(1,'Error - can not read the SIGNAL_Q file - timed out\n');
      return
   end
   if test ~= 1, pause(1), end;	% sleep for 1 second
end; % end of the while loop

% make the file ID's
fid1 = -1;
fid2 = -1;
while (fid1 == -1), fid1 = fopen([u_header,measured_direct_I],'r','ieee-be'); end;
while (fid2 == -1), fid2 = fopen([u_header,measured_direct_Q],'r','ieee-be'); end;

% read the measured data files
[header,count] = fread(fid1,[1,16],'char');
fprintf(1,'Reading %s%s\n',u_header,measured_direct_I);
[i_dat,count] = fread(fid1,[1,inf],'short'); fclose(fid1);
header = char(header);
if count ~= (num_data)
   fprintf(1,'length of file in %s is incorrect. Length = %d\n', ...
       header, count);
   return
end
[header,count] = fread(fid2,[1,16],'char');
fprintf(1,'Reading %s%s\n',u_header,measured_direct_Q);
[q_dat,count] = fread(fid2,[1,inf],'short'); fclose(fid2);
header = char(header);
if count ~= (num_data)
   fprintf(1,'length of file in %s is incorrect. Length = %d\n', ...
       header, count);
   return
end

i_dat = (((i_dat/16)*2.0) + 1.0)/4095;
q_dat = (((q_dat/16)*2.0) + 1.0)/4095;
out_data = i_dat + 1i*q_dat;

return
end