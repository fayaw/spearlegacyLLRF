
function measure_group_delay(hObject, eventdata, handles)
% hObject    handle to loadDataPb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
% measure_group_delay.m - measures three times the open loop transfer
%                   function of the direct RF feedback loop and extracts
%                   the group delay value from the fitted phase curve.
%                   Program displays the three values, their average and 
%                   the standard deviation.
%                   The RF station must be ON and NO beam circulating
%                   in the machine for the program to run. Station is 
%                   turned OFF and the Direct Loop/Comb Filter are turned
%                   OFF. The RF Station is remotely restarted and the open 
%                   loop Transfer Function is measured three  times.
%                   The results of the fitted values of the GROUP DELAY 
%                   are displayed on the screen. 
%                   Station is then configured to its initial state.
%
%                                                    Vojtech, May-July,2004
%

% MOD: 01-14-2004 W. Colocho, For NOISE_I_BL_SMALL.out (and Q) use
% RF_DATA/<station> (u_header) instead of RFTBL.
% MOD: 06-1 -2003 W. Colocho, Made into a function(). It uses handles
% structure to pass data. Called by RFguiInvasive.m

format compact

fprintf(1,'\n*** Beginning Group Delay Measurement Sequence ***\n');

% here are some configuration strings

%Use handles structure
station = handles.station;
gainFactor = get_RFP_noise_gain(station);%RFP module dependent gain
rf_data = handles.rfData;
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
num_data = 2^17;		% set the desired length of the data files
num_fft  = 2^13;		% set the desired length of FFTs
t  = linspace(0,ts*num_data,num_data);	% time vector
desired_margin = 66;		% desired phase margin of the direct loop
chop=3500;			% how much of the data is chopped off
maxDACCounts = 1900;
max_pass = 10;			% maximum number of iterations to configure direct loop
max_gain_error = 0.25;		% allowed error in loop gain - dB
max_phase_error = 2.0;		% allowed error in loop phase - degrees


%PROGRAM EXECUTION BEGINS
% make sure RF is on when program begins - exit if not
fprintf(1,'\nChecking the status of the RF station\n');
try [answer] = lcaGet([rf_module,':RFENABLE']);
catch 
    fprintf(1,'Error - unable to read RF on/off status\n');
    return
end
answer = answer{1};
if strcmp(answer(1:2),'ON') ~= 1
    fprintf(1,'Error - RF must be ON to measure the group delay\n');
    return
end

% make sure there is no beam before switching station OFF
fprintf(1,'\nChecking there is no circulating beam inside the machine\n');
try [answer] = lcaGet([station,':STN:BEAM:CURR']);
catch 
    fprintf(1,'Error - unable to read beam current\n');
    return
end
beam = answer;
if beam > 0.1
    fprintf(1,'Error - there is circulating beam in the machine\n');
    return
end

% turn the RF station OFF - it has to be OFF to open the direct loop
fprintf(1,'\nTurning Station OFF to open direct loop\n');
try lcaPut([station,':STN:STATE:CTRL'], 0);
catch 
    fprintf(1,'Error - can not turn the RF station OFF\n');
    return
end
%wait 10 seconds
pause(10)

% turn the direct loop OFF - main control on the feeback window
try lcaPut([station,':STNDIRECT:LOOP:CTRL'], 0);
catch 
    fprintf(1,'Error - can not turn the direct loop OFF\n');
    return
end

% turn the comb loop OFF - main control on the feedback window
if strcmp(station,'SRF1') ~= 1
    try lcaPut([station,':STNCOMB:LOOP:CTRL'], 0);
    catch 
        fprintf(1,'Error - can not turn the comb loop OFF\n');
        return
    end
else
end

% turn the RF station ON - with the direct loop OFF
try lcaPut([station,':STN:STATE:CTRL'], 4);
catch 
    fprintf(1,'Error - can not turn the RF station ON\n');
    return
end
%wait 60 seconds to bring the station up
fprintf(1,'\nWait 1 minute for turn-on sequence to finish\n');
pause(60)

% make sure the RF is on - remove carrige return
fprintf(1,'\nConfiguring RF system - please be patient\n');
try [answer] = lcaGet([rf_module,':RFENABLE']);
catch 
    fprintf(1,'Error - unable to read RF on/off status\n');
    return
end
answer = answer{1};
if strcmp(answer(1:2),'ON') ~= 1
    fprintf(1,'Error - RF must be ON to measure the group delay\n');
    return
end

%save_RFP_mux	% remember the state of the muxes for fast fault data
%handles = save_RFP_mux(hObject, eventdata, handles)
save_RFP_mux(hObject, eventdata, handles)
handles = guidata(handles.output);  % Updates handles with mux info

% turn tuner loop to "ON" mode - enable loop
fprintf(1,'Activating tuner loop\n');
try lcaPut([station,':CAVTUNR:LOOP:CTRL'], 1);
catch 
    fprintf(1,'Error - can not enable the tuner loop\n');
    return
end

% turn on the lead compensation
try lcaPut([station,':STNDIRECT:LEADCOMP:CTRL'], 1);
catch 
    fprintf(1,'Error - can not turn on the lead compensation\n');
    return
end

% turn off the integral compensation
try lcaPut([rf_module,':INTCOMP'], 0);
catch 
    fprintf(1,'Error - can not turn off the integral compensation\n');
    return
end

% write the desired length of the data files to the RF module driver
try lcaPut([rf_module,':MODU.RMSZ'], (num_data/1024));
catch 
    fprintf(1,'Error - can not set the desired file length\n');
    return
end

% enable the drive power loop for ON_CW mode
try lcaPut([station,':STN:ON:CTRL'], '1');
catch 
    fprintf(1,'Error - can not enable drive power loop for ON_CW mode\n');
    return
end

% make sure the ripple loop is closed - remove carrige return
try [answer] = lcaGet([rf_module,':RIPPLELOOP']);
catch 
    fprintf(1,'Error - unable to read ripple loop status\n');
    return
end
answer = answer{1};
if strcmp(answer(1:2),'On') ~= 1
    fprintf(1,'Activating Ripple loop\n');
    try lcaPut([rf_module,':RIPPLELOOP'], 1);
    catch 
        fprintf(1,'Error - can not close the ripple loop\n');
        return
    end
end

% open the comb loop - PEP only, skip for SPEAR3
if strcmp(station,'SRF1') ~= 1
    try lcaPut([rf_module,':COMBLOOP'], 0);
    catch 
        fprintf(1,'Error - can not open the comb loop\n');
        return
    end
else
end

% open the direct loop switch on the RFP window
try lcaPut([rf_module,':DIRECTLOOP'], 0);
catch 
    fprintf(1,'Error - can not open the direct loop\n');
    return
end

% wait 10 sec and check if the station is ON
pause(10)

% check the RF is still ON
try [answer] = lcaGet([rf_module,':RFENABLE']);
catch 
    fprintf(1,'Error - unable to read RF on/off status\n');
    return
end
answer = answer{1};
if strcmp(answer(1:2),'ON') ~= 1
    fprintf(1,'Error - RF must be ON to measure the group delay\n');
    return
end

% place module in operate mode
try lcaPut([rf_module,':RUNMODE'], 1);
catch 
    fprintf(1,'Error - can not place RF module into operate mode\n');
    return
end

% place the module in Reset mode
try lcaPut([rf_module,':STATE'], 0);
catch 
    fprintf(1,'Error - can not place RF module in Reset state\n');
    return
end

% place the module in Load mode
try lcaPut([rf_module,':STATE'], 1);
catch 
    fprintf(1,'Error - can not place RF module in Load state\n');
    return
end

% see what files are in the DACs - load correct files if necessary
% first do the I DACs
try [answer] = lcaGet([rf_module,':MODU.DIRF']);
catch 
    fprintf(1,'Error - unable to read DAC_I filename\n');
    return
end
answer = answer{1};
if strcmp(answer(1:length(answer)),noise_I_file) ~= 1
    fprintf(1,'loading correct DAC_I file to module RAM\n');
    try lcaPut([rf_module,':MODU.DIRF '],noise_I_file);
    catch 
        fprintf(1,'Error - can not write the DAC_I filename\n');
        return
    end
    try lcaPut([rf_module,':MODU.LDIR'], 1);
    catch 
        fprintf(1,'Error - can not load the DAC_I file\n');
        return
    end
    test = 0;	% force the first pass in the while loop
    count = 0;	% count how many times we look at the status mesasage
    pause(2);	% wait 2 seconds to allow things to start
    while test ~= 1,
        [answer] = lcaGet([rf_module,':MODU.DIST']);
        count = count +1;
        answer = answer{1};
        test = strcmp(answer(1),'N');
        if count > max_count
            fprintf(1,'Error - can not load the DAC_I file - timed out\n');
            return
        end
        if test ~= 1, pause(1), end;	% sleep for 1 seconds
    end; % end of the while loop
end

% next do the Q DACs
try [answer] = lcaGet([rf_module,':MODU.DQRF']);
catch 
    fprintf(1,'Error - unable to read DAC_Q filename\n');
    return
end
answer = answer{1};
if strcmp(answer(1:length(answer)),noise_Q_file) ~= 1
    fprintf(1,'loading correct DAC_Q file to module RAM\n') ;
    try lcaPut([rf_module,':MODU.DQRF'], noise_Q_file);
    catch 
        fprintf(1,'Error - can not write the DAC_Q filename\n');
        return
    end
    try lcaPut([rf_module,':MODU.LDQR'], 1);
    catch 
        fprintf(1,'Error - can not load the DAC_Q file\n');
        return
    end
    test = 0;	% force the first pass in the while loop
    count = 0;	% count how many times we look at the status mesasage
    pause(2);	% wait 2 seconds to allow things to start
    while test ~= 1,
        [answer] = lcaGet([rf_module,':MODU.DQST']);
        count = count +1;
        answer = answer{1};
        test = strcmp(answer(1),'N');
        if count > max_count
            fprintf(1,'Error - can not load the DAC_Q file - timed out\n');
            return
        end
        if test ~= 1, pause(1), end;	% sleep for 1 seconds
    end; % end of the while loop
end

% write the corrrect file names to save data
try lcaPut([rf_module,':MODU.SIRF'], [v_header,measured_direct_I]);
catch 
    fprintf(1,'Error - unable to write SIG_I filename\n');
    return
end
try lcaPut([rf_module,':MODU.SQRF'], [v_header,measured_direct_Q]);
catch 
    fprintf(1,'Error - unable to write SIG_Q filename\n');
    return
end

% write the corrrect file for the DSP and reload it
try [answer] = lcaGet([rf_module,':MODU.DSPE']);
catch 
    fprintf(1,'Error - unable to read DSP filename\n');
    return
end
answer = answer{1};


if strcmp(answer(1:length(answer)),DSP_file) ~= 1
    origFileName = answer;
   fprintf(1,'replacing DSP file %s with %s\n', origFileName, DSP_file );
   [status,answer] = caShell(['caput -t -w 20 ', rf_module,':MODU.DSPE ',DSP_file]);
   if status ~=0
      fprintf(1,'Error - unable to write the DSP filename\n');
      return
   end
   [status,answer] = caShell(['caput -t -w 20 ', rf_module,':MODU.LDSP 1']);
   if status ~=0
      fprintf(1,'Error - unable to load the DSP file %s; restoring %s\n', ...
          DSP_file, origFileName);
       [status,answer] = ...
           caShell(['caput -t -w 20 ', rf_module,':MODU.DSPE ',origFileName]);
       if status ~=0
          fprintf(1,'Error - unable to restore the DSP filename %s\n', ...
              origFileName);
       end
      return
   end
   test = 0;	% force the first pass in the while loop
   count = 0;	% count how many times we look at the status mesasage
   pause(2);	% wait 2 seconds to allow things to start
   while test ~= 1,
      [status,answer] = caShell(['caget -t -w 20 ', rf_module,':MODU.DSTT']);
      count = count +1;
      test = strcmp(answer(1),'N');
      if count > max_count
         fprintf(1,'Error - can not load the DSP file - timed out\n');
         fprintf(1,'  restoring original DSP file name %s\n', origFileName);
           [status,answer] = ...
               caShell(['caput -t -w 20 ', rf_module,':MODU.DSPE ',origFileName]);
           if status ~=0
              fprintf(1,'Error - unable to restore the DSP filename %s\n', ...
                  origFileName);
           end
         return
      end
      if test ~= 1, pause(1), end;	% sleep for 1 seconds
   end; % end of the while loop
end

if strcmp(answer(1:length(answer)),DSP_file) ~= 1
    origFileName = answer;
    fprintf(1,'loading correct DSP file\n');
    try lcaPut([rf_module,':MODU.DSPE'],DSP_file);
    catch 
        fprintf(1,'Error - unable to write the DSP filename\n');
        return
    end
    try lcaPut([rf_module,':MODU.LDSP'], 1);
    catch 
        fprintf(1,'Error - unable to load the DSP\n');
        fprintf(1,'  reloading original DSP file name %s\n', origFileName);
        try lcaPut([rf_module,':MODU.DSPE'],origFileName);
        catch 
            fprintf(1,'unable to restore original DSP file name %s\n', ...
                    origFileName);
        end
        return
    end
    test = 0;	% force the first pass in the while loop
    count = 0;	% count how many times we look at the status mesasage
    pause(5);	% wait 5 seconds to allow things to start
    while test ~= 1,
        [answer] = lcaGet([rf_module,':MODU.DSTT']);
        count = count +1;
        answer = answer{1};
        test = strcmp(answer(1),'N');
        if count > max_count
            fprintf(1,'Error - can not load the DSP file - timed out\n');
            fprintf(1,'  reloading original DSP file name %s\n', origFileName);
            try lcaPut([rf_module,':MODU.DSPE'],origFileName);
            catch 
                fprintf(1,'unable to restore original DSP file name %s\n', ...
                        origFileName);
            end
            return
        end
        if test ~= 1, pause(1), end;	% sleep for 1 seconds
    end; % end of the while loop
end

% place the module in single shot mode
try lcaPut([rf_module,':SSCONT'], 0);
catch 
    fprintf(1,'Error - can not place the module in Single Shot mode\n');
    return
end

% enable the DACs
try lcaPut([rf_module,':DACS'], 1);
catch 
    fprintf(1,'Error - can not enable the DACs\n');
    return
end

% set SIGNAL multiplexer to TOTAL
try lcaPut([rf_module,':FBSIG'], 0);
catch 
    fprintf(1,'Error - can not set the feedback signal to TOTAL\n');
    return
end



%%% OPEN LOOP TRANSFER FUNCTION MEASUREMENT
group_delay = zeros(1,5);  %prepare variable name for group delay
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FOR loop - measures 5 times group delay of the "open direct loop" system
%  end of the loop around line 577
for pass=1:5;
  
    % initialize figure number for plot
    figHandles = handles.figHandles; % retrieve figure data
    figInd=length(figHandles);
    figInd=figInd+1; 
    figHandles(figInd) = figInd;
    handles.figHandles = figHandles;
    guidata(handles.output, handles); % update  handles data

    % place the module in Reset mode
    try lcaPut([rf_module,':STATE'], 0);
    catch 
        fprintf(1,'Error - can not place RF module in Reset state\n');
        return
    end

    % place the module in Load mode
    try lcaPut([rf_module,':STATE'], 1);
    catch 
        fprintf(1,'Error - can not place RF module in Load state\n');
        return
    end

    %  take a single shot of data - go to run mode
    fprintf(1,'\nTaking a single shot of data\n');
    try lcaPut([rf_module,':STATE'], 2);
    catch 
        fprintf(1,'Error - can not place RF module in Run state\n');
        return
    end

    % place the module in Load mode
    try lcaPut([rf_module,':STATE'], 1);
    catch 
        fprintf(1,'Error - can not place RF module in Load state\n');
        return
    end

    % get the data files
    % read the SIGNAL_I file first
    try lcaPut([rf_module,':MODU.GSIR'], 1);
    catch 
        fprintf(1,'Error - can not activate the SIGNAL_I file read\n');
        return
    end
    fprintf(1,'Moving data from I channel to file\n');
    test = 0;	% force the first pass in the while loop
    count = 0;	% count how many times we look at the status mesasage
    pause(2);	% wait 2 seconds to allow things to start
    while test ~= 1,
        [answer] = lcaGet([rf_module,':MODU.SIST']);
        count = count +1;
        answer = answer{1};
        test = strcmp(answer(1),'N');
        if count > max_count
            fprintf(1,'Error - can not read the SIGNAL_I file - timed out\n');
            return
        end
        if test ~= 1, pause(1), end;	% sleep for 1 second
    end; % end of the while loop

    % read the SIGNAL_Q file now
    try lcaPut([rf_module,':MODU.GSQR'], 1);
    catch 
        fprintf(1,'Error - can not activate the SIGNAL_Q file read\n');
        return
    end
    fprintf(1,'Moving data from Q channel to file\n');
    test = 0;	% force the first pass in the while loop
    count = 0;	% count how many times we look at the status mesasage
    pause(2);	% wait 2 seconds to allow things to start
    while test ~= 1,
        [answer] = lcaGet([rf_module,':MODU.SQST']);
        count = count +1;
        answer = answer{1};
        test = strcmp(answer(1),'N');
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
    if pass ==1
        fid3 = -1;
        fid4 = -1;
        while (fid3 == -1), fid3 = fopen([u_header,measured_I_noise],'r','ieee-be'); end;
        while (fid4 == -1), fid4 = fopen([u_header,measured_Q_noise],'r','ieee-be'); end;
        % read the recorded noise files
        [header,count] = fread(fid3,[1,16],'char');
        fprintf(1,'Reading %s%s\n',u_header,measured_I_noise);
        [i_dat,count] = fread(fid3,[1,num_data],'short'); fclose(fid3);
        header          = setstr (header);
        if count ~= (num_data)
            ['length of file in ',header,' is incorrect. Length = ',num2str(count)]
            return
        end
        [header,count] = fread(fid4,[1,16],'char');
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
    end
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
    clear i_dat
    clear q_dat

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

    figure(figInd); clf;
    subplot(211)
    plot(baseband_freq(chop:num_fft-chop)/1e3, ...
        magnitude(chop:num_fft-chop),'r')
    grid on
    title(['Measured Transfer Function of Open Direct Loop - ',station])
    xlabel('baseband frequency - kHz')
    ylabel('amplitude - dB')

    subplot(212)
    plot(baseband_freq(chop:num_fft-chop)/1e3, ...
        (180/pi)*(angle(exp(j*phases(chop:num_fft-chop)))),'r')
    grid on
    xlabel('baseband frequency - kHz')
    ylabel('phase - degrees')


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % modified cavity fit section
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    w=2*pi*(F_rf_MHz+baseband_freq(chop:num_fft-chop)/1e6);	% make w vector

    % custom fitting routine
    [xTot, fitData] = cavityfit( w, Hsum(chop:num_fft-chop), w_rf/1e6 );

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
    group_delay(1,pass) = xTot(4);  %save group delay value
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
    plot(baseband_freq(chop:num_fft-chop)/1e3,fitted_magnitude,'b')
    subplot(212)
    hold on
    plot(baseband_freq(chop:num_fft-chop)/1e3, ...
        (180/pi)*(angle(exp(j*fitted_phase))),'b')
    
    

end %end FOR loop from around line 375 - group delay measured 5 times
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%PRINT THE FINAL RESULTS%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf(1,'\nEnd of %2.0f measurements of the Transfer function\n', ... %%
	pass); ...                                                      %%
average_group_delay = mean(group_delay);                            %%%%%%
standard_deviation = std(group_delay);                                 %%%
fprintf(1,'\n OPEN LOOP GROUP DELAYS\n');                                %
fprintf(1,' Group Delay = %3.0f ns\n', group_delay );                    %
fprintf(1,' Average Group Delay = %3.0f ns\n',average_group_delay );   %%%
fprintf(1,' Standard Deviation  = %3.0f ns\n', standard_deviation );%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% close the direct loop - feedback window
fprintf(1,'\nClosing the direct RF feedback loop\n');
try lcaPut([station,':STNDIRECT:LOOP:CTRL'], 1);
catch 
    fprintf(1,'Error - can not close the direct loop\n');
    return
end

fprintf(1,'Waiting 90 seconds for sequence to close direct loop\n');
pause(90);

% close the comb loop - PEP only, skip for SPEAR3
if strcmp(station,'SRF1') ~= 1
    try lcaPut([station,':STNCOMB:LOOP:CTRL'], 1);
    catch 
        fprintf(1,'Error - can not close the comb loop\n');
        return
    end
    fprintf(1,'Waiting 30 seconds for sequence to close comb loop\n');
    pause(30);
else
end

% turn ON the integral compensation
try lcaPut([rf_module,':INTCOMP'], 1);
catch 
    fprintf(1,'Error - can not turn on the integral compensation\n');
    return
end

% set SIGNAL multiplexer to TOTAL
try lcaPut([rf_module,':FBSIG'], 0);
catch 
    fprintf(1,'Error - can not set the feedback signal to TOTAL\n');
    return
end

% restore_RFP_mux  % restore the mux setting for fast history buffers
restore_RFP_mux(hObject, eventdata, handles)

fprintf(1,'\n*** Group Delay Measurement of Open Direct Loop Complete***\n');
