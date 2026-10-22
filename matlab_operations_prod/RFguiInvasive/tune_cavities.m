function tune_cavities(hObject, eventdata, handles)
% hObject    handle to loadDataPb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
% tune_cavities.m - Turns off RF power, measures the  cavities in a 
%                   RF station and moves tuners to place all cavities
%                   at resonance (476 MHz). Then applies CW RF power to
%                   allow nulling the cavity phases and tuner loop phases.
%                                                 Paul 1/21/97

%MOD: 01-14-2004 W. Colocho, For NOISE_I_BL.out (and Q) use RF_DATA/<station>
%     (u_header) instead of RFTBL.
% MOD: W. Colocho, 06/1/2003 - Made into a function(). It uses handles
% structure to pass data. Called by RFguiInvasive.m

format compact

fprintf(1,'\n*** Beginning Tuning Cavites ***\n');

% here are some configuration strings

station = handles.station;
rf_data = handles.rfData;	
rf_module    = [station,':STN:RFP'];
gainFactor = get_RFP_noise_gain(station);%RFP module dependent gain

% previously measured noise files
measured_I_noise = '/NOISE_I_BL.out';  
measured_Q_noise = '/NOISE_Q_BL.out';
noise_I_file = '/dat/NOISE_I_BL'; % file to load into I DAC
noise_Q_file = '/dat/NOISE_Q_BL'; % file to load into Q DAC
% define the measured loop response file names
v_header = '/dat'; % string for the augeas stuff
u_header = fullfile(rf_data, station); % directory name for nfs
measured_cavity_I = '/CAVITY_I'; 
measured_cavity_Q = '/CAVITY_Q';
DSP_file = handles.dspFile; % define DSP files

% some config values
combiner_gain = 1900;	% default gain of combining network - LER=1900 HER=1900
hvps_voltage_4CV = 58;  % use this value for tuning 4 cav - allows no drive signal
hvps_voltage_2CV = 55;  % use this value for tuning 2 cav - allows no drive signal
drive_power = 10;	% default value of drive power after initial tuning is done

max_count = 30;			% maximum number of tries to write data files
max_pass = 20;			% maximum number of tries to tune cavities
delta_f_coarse_max = 20.0;	% maximum coarse cavity tuning error - kHz
delta_f_fine_max = 1.0;
delta_degrees = -20;		% phase offset used to measure tuner sensitivity - degrees
Tsample = handles.Tsample;      % sampling interval from handles
f_rf = handles.rfFrequency;	% rf frequency - Hz
F_rf_MHz = handles.rfFrequencyMHz; % rf frequency  - MHz
w_rf = f_rf*2*pi;		% rf frequency - radians/sec
fs = 1/Tsample;  		% clock frequency
ts = Tsample;			% sampling interval name used here
num_data = 2^17;		% set the desired length of the data files
num_fft  = 2^14;		% set the desired length of FFTs
chop=7000;			% how much of the data is chopped off
piPhaseShift = 180;
                          
coef = ['.A';'.C';'.E';'.G'];   % string for use in writing octal DAC coefficients 
coef_I_Q = ['II';'IQ';'QI';'QQ']; % string for use in "fprint" error message
% % parameters for fine phase tuning
% minPhaseStep = 0.5; % degrees
% maxPhaseStep = 20; % degrees
% minPhaseGain = 1.0;
% maxPhaseGain = 8.0;

% determine if the station is 4 cavities or 2 cavities
numCav = char(lcaGet([station,':STN:NCV:PLC']));
num_cavities = sscanf(numCav, '%d', 1);
if isempty(num_cavities)
    fprintf(1, 'Error - unable to read number of cavitites\n');
    return
end % if isempty(num_cavitites)
if ((num_cavities ~= 2) && (num_cavities ~= 4)),
    fprintf(1, 'Error - incorrect NCV - not 2CV or 4CV, but %s\n', numCav);
    return;
end % if ((num_cavities ~= 2) && (num_cavities ~= 4)),

% create matrix of flags to use to determine when cavity is tuned  
cavityTuned = zeros(1, num_cavities);

% make sure the RF is on
fprintf(1,'Configuring RF system - please be patient\n');
if (strcmp(char(lcaGet([rf_module, ':RFENABLE'])), 'ON') ~= 1),
    fprintf(1, 'Error - RF must be on to tune cavities\n');
    return
end % if (strcmp(char(lcaGet([rf_module, ':RFENABLE'])), 'ON') ~= 1),

% make sure the direct loop is off
if (strcmp(char(lcaGet([station, ':STNDIRECT:LOOP:CTRL'])), 'OFF') ~= 1),
   fprintf(1,'Error - Direct loop must be open for this measurement\n');
   fprintf(1,'  remember to open the Analog Ripple Loop along with the Direct Loop\n');
   return
end % if (strcmp(char(lcaGet([station, ':STNDIRECT:LOOP:CTRL'])), 'OFF') ~= 1),


% make sure the comb loop is off
combStatus = char(lcaGet([station,':STNCOMB:LOOP:CTRL']));
% add test to insure answer is non-empty
if ~isempty(combStatus),
    if strcmp(combStatus(1:2),'ON') == 1
        fprintf(1,'Error - Comb loop must be open for this measurement\n');
    return
    end
end % if ~isempty(combStatus),

% open the HVPS voltage loop
lcaPut([station,':HVPS:LOOP:CTRL'], 0);

% set HVPS voltage
fprintf(1,'Setting desired station HVPS operating voltage\n');
if num_cavities == 4,
    lcaPut([station,':HVPS:VOLT:CTRL.VAL'], hvps_voltage_4CV);
else
    lcaPut([station,':HVPS:VOLT:CTRL.VAL'], hvps_voltage_2CV);
end % if num_cavities == 4,

% make sure the RF is in operate mode
lcaPut([rf_module,':RUNMODE'], 1);

fprintf(1,'Reading original station drive power setting\n');
original_drive_power = lcaGet([station,':KLYSDRIVFRWD:POWER:ON']);

fprintf(1,'Writing desired station drive power\n');
lcaPut([station,':KLYSDRIVFRWD:POWER:ON'], drive_power);

% enable the drive power loop for ON_CW mode
lcaPut([station,':STN:ON:CTRL'], 1);

% load default set points into cavity combiner coefficients
fprintf(1,'Loading default values into cavity combining network\n');
for cavity = 1:num_cavities,
    for count = 1:3:4,
        lcaPut([rf_module,':CAV',num2str(cavity), coef(count,:)], ...
            combiner_gain);
    end
    for count = 2:3,
        lcaPut([rf_module,':CAV',num2str(cavity), coef(count,:)], 0);
    end
end

lcaPut([rf_module,':MODU.LOD'], 1);

% disable tuner loop
fprintf(1,'Deactivating tuner loop\n');
lcaPut([station,':CAVTUNR:LOOP:CTRL'], 0);

% move the tuners back to home
fprintf(1,'Moving all tuners to HOME position\n');
lcaPut([station,':CAVTUNR:LOOPON:RESET.PROC'], 1);

% wait for all tuners to move home
tWait = 30;
for cavityNumber=1:num_cavities,
    desiredPos = lcaGet(sprintf('%s:CAV%1dTUNR:POSN:ONHOME', ...
        station, cavityNumber));
    if(waitfortunermovetopot( station, cavityNumber, desiredPos, tWait ) == -1)
        fprintf(1, 'tuner %d failed to reach %f\n', cavityNumber, ...
            desiredPos);
        return
    end % if(waitfortunermove(
end % for cavityNumber=1:num_cavities,

% write the desired length of the data files to the RF module driver
fprintf(1,'Setting data file length\n');
lcaPut([rf_module,':MODU.RMSZ'], num_data/1024);

% make sure the ripple loop is closed
fprintf(1,'Checking status of RIPPLE loop\n');
rippleStatus = char(lcaGet([rf_module,':RIPPLELOOP']));
if (strcmp(rippleStatus, 'On') ~= 1),
    lcaPut([rf_module,':RIPPLELOOP'], 1);
end % if (strcmp(rippleStatus, 'On') ~= 1),

loadrfstates( rf_module );

% % tested to this line on 04/23/2013
% see what files are in the DACs - load correct files if necessary
% first do the I DACs
if strcmp(char(lcaGet([rf_module, ':MODU.DIRF'])), noise_I_file) ~= 1
    fprintf(1,'loading correct DAC_I file to module RAM\n');
    lcaPut([rf_module,':MODU.DIRF'], noise_I_file);
    lcaPut([rf_module,':MODU.LDIR'], 1);
    
    test = 0;	% force the first pass in the while loop
    count = 0;	% count how many times we look at the status mesasage
    pause(2);	% wait 2 seconds to allow things to start
    while test ~= 1,
        answer = char(lcaGet([rf_module,':MODU.DIST']));
        count = count +1;
        test = strcmp(answer(1),'N');
        if count > max_count
            fprintf(1,'Error - can not load the DAC_I file - timed out\n');
            return
        end
        if test ~= 1, pause(1), end;	% sleep for 1 seconds
    end; % end of the while loop
end % if strcmp(char(lcaGet(

% next do the Q DACs
if strcmp(char(lcaGet([rf_module, ':MODU.DQRF'])), noise_Q_file) ~= 1
    fprintf(1,'loading correct DAC_Q file to module RAM\n') ;
    lcaPut([rf_module,':MODU.DQRF'], noise_Q_file);
    lcaPut([rf_module,':MODU.LDQR'], 1);
    
    test = 0;	% force the first pass in the while loop
    count = 0;	% count how many times we look at the status mesasage
    pause(2);	% wait 2 seconds to allow things to start
    while test ~= 1,
        answer = char(lcaGet([rf_module,':MODU.DQST']));
        count = count +1;
        test = strcmp(answer(1),'N');
        if count > max_count
            fprintf(1,'Error - can not load the DAC_Q file - timed out\n') ;
            return
        end
        if test ~= 1, pause(1), end;	% sleep for 1 seconds
    end; % end of the while loop
end % if strcmp(char(lcaGet(

% write the corrrect file names to save data
lcaPut([rf_module,':MODU.CIRF'], [v_header,measured_cavity_I]);
lcaPut([rf_module,':MODU.CQRF'], [v_header,measured_cavity_Q]);
% write the corrrect file for the DSP and reload it
answer = char(lcaGet([rf_module,':MODU.DSPE']));
if strcmp(answer, DSP_file) ~= 1
    origFileName = answer;
    fprintf(1,'replacing DSP file %s with %s\n', origFileName, DSP_file );
    lcaPut([rf_module,':MODU.DSPE'], DSP_file);
    lcaPut([rf_module,':MODU.LDSP'], 1);
    test = 0;	% force the first pass in the while loop
    count = 0;	% count how many times we look at the status mesasage
    pause(2);	% wait 2 seconds to allow things to start
    while test ~= 1,
        answer = char(lcaGet([rf_module,':MODU.DSTT']));
        count = count +1;
        test = strcmp(answer(1),'N');
        if count > max_count
            fprintf(1,'Error - can not load the DSP file - timed out\n');
            fprintf(1,'  restoring original DSP file name %s\n', origFileName);
            lcaPut([rf_module,':MODU.DSPE'], origFileName);
            return
        end
        if test ~= 1, pause(1), end;	% sleep for 1 seconds
    end; % end of the while loop
end % if strcmp(answer, DSP_file) ~= 1

% place the module in single shot mode
lcaPut([rf_module,':SSCONT'], 0);

% enable the DACs
lcaPut([rf_module,':DACS'], 1);

% turn off the lead compensation
lcaPut([rf_module,':LEADCOMP'], 0);

% turn off the integral compensation
lcaPut([rf_module,':INTCOMP'], 0);

pass = 0;		% clear the pass counter
max_error = 999;	% set the max_error for first run through cavities

% get two figure handles for data fits and history information
figHandles = handles.figHandles; % retrieve figure data
figInd=length(figHandles);
figInd=figInd+1;
figHandles(figInd) = figInd;
figIndOne = figInd;
figInd=figInd+1;
figHandles(figInd) = figInd;
figIndTwo = figInd;
handles.figHandles = figHandles;
guidata(handles.output, handles); % update  handles data

% here is the loop which coarse tunes the cavities
% allocate arrays for data
freq_hist = zeros(max_pass, num_cavities);
tuning_hist = zeros(max_pass, num_cavities);
fitted_gain = zeros(1, num_cavities);
old_magnitude = zeros(1, num_cavities);
old_phases = zeros(1, num_cavities);
new_phases = zeros(1, num_cavities);

while ((abs(max_error) > delta_f_coarse_max) && (pass <= max_pass)),
    pass = pass +1;
    max_error = 0;	% reset the max_error for next run through cavities
    for cavity = 1:num_cavities,
        % break out of loop if this cavity is already tuned
        if (cavityTuned(cavity) == 1),
            % fill in diagnostic arrays with appropriate constant values
            freq_hist(pass,cavity)   = freq_hist(pass-1,cavity);	% error is constant save tuning history for diagnostic
            tuning_hist(pass,cavity) = 0;		        % no tuner motion save tuner movement for diagnostic
            continue;
        end % if (cavityTuned(cavity) == 1),
        
        % set CAVITY multiplexer to variable=cavity-1
        % note that :CAVSEL has four states, 0,1,2,3, corresponding to string
        % values '1','2','3','4'
        % caShell passed the string values, but lcaPut passes the integer
        % values, so while caShell uses the value of cavity, lcaPut must
        % use the value of cavity - 1 (cavity goes from 1:4)
        % lcaPut([rf_module, ':CAVSEL'], num2str(cavity));
        lcaPut([rf_module,':CAVSEL'], cavity - 1);
        
        cyclerfstates( rf_module );
        
        % get the data files
        % read the CAVITY_I file first
        lcaPut([rf_module,':MODU.GCIR'], 1);
        
        fprintf(1,'Moving data from I channel to file\n');
        test = 0;	% force the first pass in the while loop
        count = 0;	% count how many times we look at the status mesasage
        pause(2);	% wait 2 seconds to allow things to start
        while test ~= 1,
            answer = char(lcaGet([rf_module,':MODU.CIST']));
            count = count +1;
            test = strcmp(answer(1),'N');
            if count > max_count
                fprintf(1,'Error - can not read the CAVITY_I file - timed out\n');
                return
            end
            if test ~= 1, pause(1), end;	% sleep for 1 seconds
        end; % end of the while loop
        
        % read the CAVITY_Q file now
        lcaPut([rf_module,':MODU.GCQR'], 1);
        fprintf(1,'Moving data from Q channel to file\n');
        test = 0;	% force the first pass in the while loop
        count = 0;	% count how many times we look at the status mesasage
        pause(2);	% wait 2 seconds to allow things to start
        while test ~= 1,
            answer = char(lcaGet([rf_module,':MODU.CQST']));
            count = count +1;
            test = strcmp(answer(1),'N');
            if count > max_count
                fprintf(1,'Error - can not read the CAVITY_Q file - timed out\n');
                return
            end
            if test ~= 1, pause(1), end;	% sleep for 1 seconds
        end; % end of the while loop
        
        % make the file ID's
        fileNameI = fullfile(u_header, measured_cavity_I);
        fid1 = fileopenreadieee( fileNameI, 5 );
        if (fid1 == -1), return; end;
        fileNameQ = fullfile(u_header, measured_cavity_Q);
        fid2 = fileopenreadieee( fileNameQ, 5 );
        if (fid2 == -1), return; end;
        if (pass == 1) && (cavity == 1), 		% don't bother reading again
            fileNameINoise = fullfile(u_header, measured_I_noise);
            fid3 = fileopenreadieee( fileNameINoise, 5 );
            if (fid3 == -1), return; end;
            fileNameQNoise = fullfile(u_header, measured_Q_noise);
            fid4 = fileopenreadieee( fileNameQNoise, 5 );
            if (fid4 == -1), return; end;
        end
        
        % read the measured data files
        [header,count] = fread(fid1,[1,16],'char');
        fprintf(1,'Reading %s\n',fileNameI);
        [i_dat,count] = fread(fid1,[1,inf],'short'); fclose(fid1);
        header = char(header);
        if count ~= (num_data)
            fprintf(1, 'length of file in %s is incorrect. Length = %d\n', ...
                header, count);
            return
        end
        [header,count] = fread(fid2,[1,16],'char');
        fprintf(1,'Reading %s\n',fileNameQ);
        [q_dat,count] = fread(fid2,[1,inf],'short'); fclose(fid2);
        header = char(header);
        if count ~= (num_data)
            fprintf(1, 'length of file in %s is incorrect. Length = %d\n', ...
                header, count);
            return
        end
        
        i_dat = (fix(i_dat/16))/2047;	% shift data and scale
        q_dat = (fix(q_dat/16))/2047;	% shift data and scale
        out_data = i_dat + 1i*q_dat;
        out_data = out_data-mean(out_data);
        clear i_dat
        clear q_dat
        
        if (pass == 1) && (cavity ==1),
            % read the recorded noise files
            [header,count] = fread(fid3,[1,16],'char');
            fprintf(1,'Reading %s\n',fileNameINoise);
            [i_dat,count] = fread(fid3,[1,num_data],'short'); fclose(fid3);
            header          = char(header);
            if count ~= (num_data)
                fprintf(1, 'length of file in %s is incorrect. Length = %d\n', ...
                    header, count);
                return
            end
            [header,count] = fread(fid4,[1,16],'char');
            fprintf(1,'Reading %s\n',fileNameQNoise);
            [q_dat,count] = fread(fid4,[1,num_data],'short'); fclose(fid4);
            header          = char(header);
            if count ~= (num_data)
                fprintf(1, 'length of file in %s is incorrect. Length = %d\n', ...
                    header, count);
                return
            end
            
            i_dat = (fix(i_dat/16))/2047;
            q_dat = (fix(q_dat/16))/2047;
            in_data = (i_dat + 1i*q_dat) / gainFactor;
            clear i_dat
            clear q_dat
        end
        
        fprintf(1,['Calculating cavity #',num2str(cavity),' transfer function\n']);
        [Hsum,FF]=tfestimate(in_data,out_data,hanning(num_fft),[],num_fft,fs);
        Hsum(1) = Hsum(2);	% ignore the DC term - usually has large errors
        Hsum=Hsum';
        % reorder the results to go from -freq to + freq
        %%%% should we replace this with fftshift here?
        Hsum = [Hsum(num_fft/2+2:num_fft) Hsum(1:num_fft/2+1)]; % reorder by frequency
        
        magnitude = 20*log10(abs(Hsum));
        phases = angle(Hsum);
        
        if (pass == 1) && (cavity ==1),
            delta_f=fs/(num_fft);
            %%%% this could also be replaced by [-(num_fft/2 -
            %%%% 1):(num_fft/2)]
            baseband_freq=delta_f*[((-1*(num_fft/2 -1)):-1) 0 (1:num_fft/2)];
        end
        
        figure(figIndOne); clf;
        subplot(211)
        plot(baseband_freq(chop:num_fft-chop)/1e3, ...
            magnitude(chop:num_fft-chop),'r.')
        junk=axis;
        axis([junk(1:2) -30 30])
        grid on
        title(['Measured Transfer Function of Cavity #',num2str(cavity),' - ',station])
        xlabel('baseband frequency - kHz')
        ylabel('amplitude - dB')
        
        subplot(212)
        plot(baseband_freq(chop:num_fft-chop)/1e3, ...
            (180/pi)*phases(chop:num_fft-chop),'r.')
        grid on
        xlabel('baseband frequency - kHz')
        ylabel('phase - degrees')
        
        fprintf(1,['Fitting cavity #',num2str(cavity), ...
            ' system parameters to measured data\n']);
        
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
        fprintf(1,'Fitted cavity frequency is %7.4f MHz\n',Wc/(2*pi));
        fprintf(1,'Fitted loaded cavity Q is %4.0f\n',Ql);
        fprintf(1,'Fitted loop gain is %3.1f volts/volt\n',k);
        fprintf(1,'Fitted system delay is %3.0f ns\n',Td);
        fprintf(1,'Fitted phase shift is %3.0f degrees\n',phase_offset);
        
        % make a fitted magnitude vector and plot it on top of the measured data
        fitted_magnitude = 20*log10(abs(fitData));
        fitted_gain(cavity) = 10^(max(fitted_magnitude)/20);
        % make a fitted phase vector and plot it on top of the measured data
        fitted_phase = angle(fitData);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % end of modified cavity fit section
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % plot the fitted results
        figure(figIndOne)
        subplot(211)
        hold on
        plot(baseband_freq(chop:num_fft-chop)/1e3,fitted_magnitude,'b')
        subplot(212)
        hold on
        plot(baseband_freq(chop:num_fft-chop)/1e3, ...
            (180/pi)*angle(exp(1i*fitted_phase)),'b')
        
        % read the current setting for the cavity baseband modulator
        cavity_II = lcaGet([rf_module,':CAV',num2str(cavity),'.A']);
        cavity_IQ = lcaGet([rf_module,':CAV',num2str(cavity),'.C']);
        cavity_QI = lcaGet([rf_module,':CAV',num2str(cavity),'.E']);
        cavity_QQ = lcaGet([rf_module,':CAV',num2str(cavity),'.G']);
        
        % calculate the phase and magnitude of the cavity coefficients
        old_phases(cavity)     = (180/pi)*atan2(mean([cavity_IQ, cavity_QI]), ...
            mean([cavity_II, cavity_QQ]));
        old_magnitude(cavity) = sqrt((mean([cavity_IQ, cavity_QI]))^2 + ...
            (mean([cavity_II, cavity_QQ]))^2);
        
        % calculate the required phase adjustment
        phase_adjust = x(5) + piPhaseShift;
        new_phases(cavity) = mod(old_phases(cavity) + phase_adjust + 180, 360) - 180;
        fprintf(1, ...
            'Current phase of cavity %1d DAC baseband combiner coeffs = %6.1f degrees\n', ...
            cavity, old_phases(cavity));
        fprintf(1,' changing the coeff phase by %6.1f degrees to %6.1f degrees\n', ...
            phase_adjust, new_phases(cavity) );
        
        % calculate the new cavity coefficients
        cavity_II = old_magnitude(cavity) * cos((pi/180) * new_phases(cavity));
        cavity_QI = old_magnitude(cavity) * sin((pi/180) * new_phases(cavity));
        cavity_IQ = cavity_QI;	% later we may want to remove modulator errors here
        cavity_QQ = cavity_II;	% and here
        
        % write the new settings for the direct loop baseband modulator
        lcaPut([rf_module,':CAV',num2str(cavity),'.A'], cavity_II);
        lcaPut([rf_module,':CAV',num2str(cavity),'.C'], cavity_IQ);
        lcaPut([rf_module,':CAV',num2str(cavity),'.E'], cavity_QI);
        lcaPut([rf_module,':CAV',num2str(cavity),'.G'], cavity_QQ);
        lcaPut([rf_module,':MODU.LOD'], 1);
        
        % calculate the required tuner movement
        freq_error = (Wc/(2*pi) - F_rf_MHz)*1e3;	% calculate the freq error from 476 (kHz)
        max_error = max([max_error,abs(freq_error)]);
        fprintf(1,'Tuning error for cavity #%d = %fkHz\n', ...
            cavity, freq_error);
        mm_per_degree = lcaGet([station,':CAV',num2str(cavity), ...
            'TUNR:POSN:DELTA.C']);
        delta_mm = freq_error * (90/((F_rf_MHz*1e3)/Ql)) * (-1*mm_per_degree);
        
        % get the present tuner position and calculate the new position
        present_mm = lcaGet([station,':CAV',num2str(cavity), ...
            'TUNR:STEP:MOTOR.RBV']);
        
        % display current position of the tuner
        fprintf(1,['Cavity #',num2str(cavity),' present tuner position = ',...
            num2str(present_mm), 'mm\n']);
        
        new_position = present_mm + delta_mm;
        
        % move the tuner
        fprintf(1,'Moving cavity #%d tuner by %f mm\n', cavity, delta_mm);
        lcaPut([station,':CAV',num2str(cavity),'TUNR:POSN:CTRL'], ...
            new_position);
        
        % wait until the tuner is within 0.05mm of the new position
        % get and display the new tuner position
        % stop program if tuner not in the new position in 45 seconds
        new_mm = present_mm;
        pause(5)
        tic   %starting the time clock
        while abs(new_mm - new_position) > 0.05
            pause(1)
            new_mm = lcaGet([station,':CAV',num2str(cavity), ...
                'TUNR:STEP:MOTOR.RBV']);
            fprintf(1, 'desired position = %f; position = %f\n', ...
                new_position, new_mm);
            if toc > 45
                fprintf(1,['Error - unable to move cavity #',num2str(cavity),' tuner\n']);
                return
            end
        end   %end of while loop
        fprintf(1,'Cavity #%d new tuner position = %f mm\n', ...
            cavity, new_mm);
        
        
        freq_hist(pass,cavity)   = freq_error;	% save tuning history for diagnostic
        tuning_hist(pass,cavity) = delta_mm;		% save tuner movement for diagnostic
        if (abs(freq_error) <= delta_f_coarse_max),
            cavityTuned(cavity) = 1;
        end % if (abs(freq_error) <= delta_f_coarse_max),
    end	% end of the cavity 1 to num_cavities loop
    
    % plot the tuning freq_history - not on the first pass
    if pass > 1
        figure(figIndTwo); clf;
        subplot(211)
        plotVec = 1:pass;
        freqPlot = freq_hist(plotVec,:);
        plot(plotVec);
        hold on
        plot(plotVec,'*');
        title(['Tuning History for All Cavities - ',station])
        xlabel('Iteration Number')
        ylabel('Tuning Error - kHz')
        grid on
        subplot(212)
        tuningPlot = tuning_hist(plotVec,:);
        plot(tuningPlot);
        hold on
        plot(tuningPlot, '*');
        xlabel('Iteration Number')
        ylabel('Tuner Movement - mm')
        grid on
    end
    
    
end	% end of the while loop - max = max_pass

if ((pass > max_pass) && (abs(max_error) > delta_f_coarse_max))
    fprintf(1,'Error - failed to tune cavities in %d passes\n', pass);
    return
else
    fprintf(1,'\nCavities tuned to within %f kHz in %d passes\n\n', ...
        max_error, pass);
end


% At this point cavities are within delta_f_coarse_max kHz of 476.  Now we null the tuner
% loop phase offsets, activate tuner loop and enter cavity frequency fine tuning loop.
% Tuner loop will prevent drift due to variations in cavity water temperature.

% read each cavity probe phase and forward phase and enter the necessary offset for 
% each to null transmission phase
% allocate arrays for data
probe_phases = zeros(1, num_cavities);
new_probe_phase_offset = zeros(1, num_cavities);
forward_phases = zeros(1, num_cavities);
new_forward_phase_offset = zeros(1, num_cavities);
reflected_phases = zeros(1, num_cavities);
new_reflected_phase_offset = zeros(1, num_cavities);

for cavity = 1:num_cavities,
    
    fprintf(1,['Nulling cavity phase measurements for cavity #', num2str(cavity),'\n']);
    % set the probe phase offset to zero and update data base
    lcaPut([station,':CAV',num2str(cavity), 'PROBE:PHASE:OFFS'], 0);
    pause(1);	% wait for the database to update
    % read the current setting for the cavity probe phase
    probe_phases(cavity) = ...
        lcaGet([station,':CAV',num2str(cavity),'PROBE:PHASE']);
    % calculate the probe phase offset and update data base
    new_probe_phase_offset(cavity) = -probe_phases(cavity);
    lcaPut([station,':CAV',num2str(cavity), 'PROBE:PHASE:OFFS'], ...
        new_probe_phase_offset(cavity));
    fprintf(1,' Set cavity %1d probe phase offset to %4.1f degrees\n', ...
        cavity, new_probe_phase_offset(cavity) );
    
    % set the cavity forward phase offset to zero and update data basepiPhaseShift
    lcaPut([station,':CAV',num2str(cavity), 'FRWD:PHASE:OFFS'], 0);
    pause(1);	% wait for the database to update
    % read the current setting for the cavity forward phase
    forward_phases(cavity) = ...
        lcaGet([station,':CAV',num2str(cavity),'FRWD:PHASE']);
    % calculate the new probe phase offset and update data base
    new_forward_phase_offset(cavity) = -forward_phases(cavity);
    lcaPut([station,':CAV',num2str(cavity), 'FRWD:PHASE:OFFS'], ...
        new_forward_phase_offset(cavity));
    fprintf(1,' Set cavity %1d forward phase offset to %4.1f degrees\n', ...
        cavity, new_forward_phase_offset(cavity) );
    
    % set the cavity reflected phase offset to zero and update data base
    lcaPut([station,':CAV',num2str(cavity), 'REFL:PHASE:OFFS'], 0);
    pause(1);	% wait for the database to update
    % read the current setting for the cavity reflected phase
    reflected_phases(cavity) = ...
        lcaGet([station,':CAV',num2str(cavity),'REFL:PHASE']);
    % calculate the new reflected phase offset and update data base
    new_reflected_phase_offset(cavity) = -reflected_phases(cavity);
    lcaPut([station,':CAV',num2str(cavity), 'REFL:PHASE:OFFS'], ...
        new_reflected_phase_offset(cavity));
    fprintf(1,' Set cavity %1d reflected phase offset to %4.1f degrees\n', ...
        cavity, new_reflected_phase_offset(cavity) );
    
end

for cavity=1:num_cavities,
    % get the present tuner position and calculate the new position
    present_mm = lcaGet([station,':CAV',num2str(cavity), 'TUNR:STEP:MOTOR.RBV']);
    fprintf(1,' Cavity %1d tuner position at %8.5f before tuner loop activated\n', ...
        cavity, present_mm );
end

% turn tuner loop to "ON" mode - enable loop
fprintf(1,'Activating tuner loop\n');
lcaPut([station,':CAVTUNR:LOOP:CTRL'], 1);
% force one pass through the fine tuning loop
max_error = 999;

% reset cavityTuned
cavityTuned = zeros(1,num_cavities);

% here is the loop which fine tunes the cavities
while ((abs(max_error) > delta_f_fine_max) && (pass <= max_pass)),
    pass = pass +1;
    max_error = 0;	% reset the max_error for next run through cavities
    for cavity = 1:num_cavities,
        
        % break out of loop if this cavity is already tuned
        if (cavityTuned(cavity) == 1),
            % fill in diagnostic arrays with appropriate constant values
            freq_hist(pass,cavity)   = freq_hist(pass-1,cavity);	% error is constant save tuning history for diagnostic
            continue;
        end % if (cavityTuned(cavity) == 1),
        
        % set CAVITY multiplexer to variable=cavity-1
        % note that :CAVSEL has four states, 0,1,2,3, corresponding to string
        % values '1','2','3','4'
        % caShell passed the string values, but lcaPut passes the integer
        % values, so while caShell uses the value of cavity, lcaPut must
        % use the value of cavity - 1 (cavity goes from 1:4)
        % lcaPut([rf_module, ':CAVSEL'], num2str(cavity));
        lcaPut([rf_module,':CAVSEL'], cavity - 1);
        cyclerfstates( rf_module );
        
        % get the data files
        % read the CAVITY_I file first
        lcaPut([rf_module,':MODU.GCIR'], 1);
        fprintf(1,'Moving data from I channel to file\n');
        test = 0;	% force the first pass in the while loop
        count = 0;	% count how many times we look at the status mesasage
        pause(2);	% wait 2 seconds to allow things to start
        while test ~= 1,
            count = count +1;
            test = strcmp(char(lcaGet([rf_module,':MODU.CIST'])), 'NO_ALARM');
            if count > max_count
                fprintf(1,'Error - can not read the CAVITY_I file - timed out\n');
                return
            end
            if test ~= 1, pause(1), end;	% sleep for 1 seconds
        end; % end of the while loop
        
        % read the CAVITY_Q file now
        lcaPut([rf_module,':MODU.GCQR'], 1);
        fprintf(1,'Moving data from Q channel to file\n');
        test = 0;	% force the first pass in the while loop
        count = 0;	% count how many times we look at the status mesasage
        pause(2);	% wait 2 seconds to allow things to start
        while test ~= 1,
            count = count +1;
            test = strcmp(char(lcaGet([rf_module,':MODU.CQST'])), 'NO_ALARM');
            if count > max_count
                fprintf(1,'Error - can not read the CAVITY_Q file - timed out\n');
                return
            end
            if test ~= 1, pause(1), end;	% sleep for 1 seconds
        end; % end of the while loop
        
        % make the file ID's
        fid1 = fileopenreadieee( fileNameI, 5 );
        if (fid1 == -1), return; end;
        fid2 = fileopenreadieee( fileNameQ, 5 );
        if (fid2 == -1), return; end;
        
        % read the measured data files
        [header,count] = fread(fid1,[1,16],'char');
        fprintf(1,'Reading %s\n', fileNameI);
        [i_dat,count] = fread(fid1,[1,inf],'short'); fclose(fid1);
        header = char(header);
        if count ~= (num_data)
            fprintf(1, 'length of file in %s is incorrect.  Length = %d\n', ...
                header, count);
            return
        end
        [header,count] = fread(fid2,[1,16],'char');
        fprintf(1,'Reading %s\n', fileNameQ);
        [q_dat,count] = fread(fid2,[1,inf],'short'); fclose(fid2);
        header = char(header);
        if count ~= (num_data)
            fprintf(1, 'length of file in %s is incorrect.  Length = %d\n', ...
                header, count);
            return
        end
        
        i_dat = (fix(i_dat/16))/2047;	% shift data and scale
        q_dat = (fix(q_dat/16))/2047;	% shift data and scale
        out_data = i_dat + 1i*q_dat;
        clear i_dat
        clear q_dat
        
        fprintf(1,['Calculating cavity #',num2str(cavity),' transfer function\n']);
        [Hsum,FF]=tfestimate(in_data,out_data,hanning(num_fft),[],num_fft,fs);
        Hsum=Hsum';
        % reorder the results to go from -freq to + freq
        Hsum = [Hsum(num_fft/2+2:num_fft) Hsum(1:num_fft/2+1)]; % reorder by frequency
        
        magnitude = 20*log10(abs(Hsum));	% filter the data
        phases = angle(Hsum);	% filter the data
        
        figure(figIndOne)
        clf
        subplot(211)
        plot(baseband_freq(chop:num_fft-chop)/1e3, ...
            magnitude(chop:num_fft-chop),'r.')
        junk=axis;
        axis([junk(1:2) -30 30])
        grid on
        title(['Measured Transfer Function of Cavity #',num2str(cavity),' - ',station])
        xlabel('baseband frequency - kHz')
        ylabel('amplitude - dB')
        
        subplot(212)
        plot(baseband_freq(chop:num_fft-chop)/1e3, ...
            (180/pi)*phases(chop:num_fft-chop),'r.')
        grid on
        xlabel('baseband frequency - kHz')
        ylabel('phase - degrees')
        
        fprintf(1,['Fitting cavity #',num2str(cavity), ...
            ' system parameters to measured data\n']);
        
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
        fprintf(1,'Fitted cavity frequency is %7.4f MHz\n',Wc/(2*pi));
        fprintf(1,'Fitted loaded cavity Q is %4.0f\n',Ql);
        fprintf(1,'Fitted loop gain is %3.1f volts/volt\n',k);
        fprintf(1,'Fitted system delay is %3.0f ns\n',Td);
        fprintf(1,'Fitted phase shift is %3.0f degrees\n',phase_offset);
        
        % make a fitted magnitude vector and plot it on top of the measured data
        fitted_magnitude = 20*log10(abs(fitData));
        fitted_gain(cavity) = 10^(max(fitted_magnitude)/20);
        % make a fitted phase vector and plot it on top of the measured data
        fitted_phase = angle(fitData);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % end of modified cavity fit section
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % plot the fitted results
        figure(figIndOne)
        subplot(211)
        hold on
        plot(baseband_freq(chop:num_fft-chop)/1e3,fitted_magnitude,'b')
        subplot(212)
        hold on
        plot(baseband_freq(chop:num_fft-chop)/1e3, ...
            (180/pi)*angle(exp(1i*fitted_phase)),'b')
        
        % read the current setting for the cavity baseband modulator
        cavity_II = lcaGet([rf_module,':CAV',num2str(cavity),'.A']);
        cavity_IQ = lcaGet([rf_module,':CAV',num2str(cavity),'.C']);
        cavity_QI = lcaGet([rf_module,':CAV',num2str(cavity),'.E']);
        cavity_QQ = lcaGet([rf_module,':CAV',num2str(cavity),'.G']);
        
        % calculate the phase and magnitude of the cavity coefficients
        old_phases(cavity)     = (180/pi)*atan2(mean([cavity_IQ, cavity_QI]), ...
            mean([cavity_II, cavity_QQ]));
        old_magnitude(cavity) = sqrt((mean([cavity_IQ, cavity_QI]))^2 + ...
            (mean([cavity_II, cavity_QQ]))^2);
        
        % calculate the required phase adjustment
        phase_adjust = x(5) + piPhaseShift;
        new_phases(cavity) = mod(old_phases(cavity) + phase_adjust + 180, 360) - 180;
        fprintf(1, ...
            'Current phase of cavity %1d DAC baseband combiner coeffs = %6.1f degrees\n', ...
            cavity, old_phases(cavity));
        fprintf(1,' changing the coeff phase by %6.1f degrees to %6.1f degrees\n', ...
            phase_adjust, new_phases(cavity) );
        
        % calculate the new cavity coefficients
        cavity_II = old_magnitude(cavity) * cos((pi/180) * new_phases(cavity));
        cavity_QI = old_magnitude(cavity) * sin((pi/180) * new_phases(cavity));
        cavity_IQ = cavity_QI;	% later we may want to remove modulator errors here
        cavity_QQ = cavity_II;	% and here
        
        % write the new settings for the direct loop baseband modulator
        lcaPut([rf_module,':CAV',num2str(cavity),'.A'], cavity_II);
        lcaPut([rf_module,':CAV',num2str(cavity),'.C'], cavity_IQ);
        lcaPut([rf_module,':CAV',num2str(cavity),'.E'], cavity_QI);
        lcaPut([rf_module,':CAV',num2str(cavity),'.G'], cavity_QQ);
        lcaPut([rf_module,':MODU.LOD'], 1);

        fprintf(1, '\tcav %1d II = %8.2f\n', cavity, cavity_II);
        fprintf(1, '\tcav %1d IQ = %8.2f\n', cavity, cavity_IQ);
        fprintf(1, '\tcav %1d QI = %8.2f\n', cavity, cavity_QI);
        fprintf(1, '\tcav %1d QQ = %8.2f\n', cavity, cavity_QQ);
        
        % calculate the required tuner phase offset adjustment
        freq_error = (Wc/(2*pi) - F_rf_MHz)*1e3;	% calculate the freq error from 476 (kHz)
        max_error = max([max_error,abs(freq_error)]);
        fprintf(1,['Tuning error for cavity #',num2str(cavity),' = ' ...
            num2str(freq_error),' kHz\n']);
        
        delta_offset_cavity = (-180/pi)*atan(2*Ql*freq_error/(f_rf/1e3));
        delta_offset_delay  = (180/pi)*angle(exp(-1i*2*pi*freq_error*(Td/1e6)));
        delta_offset_phase  = delta_offset_cavity + delta_offset_delay;
        
        % get and display the tuner position
        present_mm = ...
            lcaGet([station,':CAV',num2str(cavity),'TUNR:STEP:MOTOR.RBV']);
        fprintf(1,['Cavity #',num2str(cavity),' present tuner position = ',...
            num2str(present_mm), 'mm\n']);
        
        % get the present probe phase offset and calculate the new value
        present_phase = ...
            lcaGet([station,':CAV',num2str(cavity), 'PROBE:PHASE:OFFS']);
        new_phase_offset = mod(present_phase + delta_offset_phase + 180, 360) - 180;
        
        % update the probe phase offset
        fprintf(1,'Current phase of cavity %1d probe phase offset = %6.1f degrees\n', ...
            cavity, present_phase);
        lcaPut([station,':CAV',num2str(cavity),'PROBE:PHASE:OFFS'], ...
            new_phase_offset);
        pause(10) %waiting for tuner to move
        % display the new value of probe_phase_offset
        fprintf(1,' changing the phase by %6.1f degrees to %6.1f degrees\n', ...
            delta_offset_phase, new_phase_offset );
        
        % get and display the new tuner position
        new_mm = ...
            lcaGet([station,':CAV',num2str(cavity), 'TUNR:STEP:MOTOR.RBV']);
        fprintf(1,['Cavity #',num2str(cavity),' new tuner position = ',...
            num2str(new_mm), 'mm\n']);
        
        freq_hist(pass,cavity)   = freq_error;	% save tuning history for diagnostic
        if (abs(freq_error) <= delta_f_fine_max),
            cavityTuned(cavity) = 1;
        end % if (abs(freq_error) <= delta_f_fine_max),
    end	% end of the cavity 1 to num_cavities FOR fine_tune loop
    
    % plot the tuning freq_history - not on the first pass        fprintf(1, '\tcav %1d II = %8.2f\n', cavity, cavity_II);

    if pass > 1

        figure(figIndTwo)
        clf
        plotVec = 1:pass;
        freqPlot = freq_hist(plotVec,:);
        plot(freqPlot);
        hold on
        plot(freqPlot, '*');
        title('Tuning History for All Cavities')
        ylabel('Tuning Error - kHz')
        xlabel('Iteration Number')
        grid on
    end
    
end	% end of the while loop - max = max_pass

if ((pass > max_pass) && (abs(max_error) > delta_f_fine_max))
    fprintf(1,'Error - failed to tune cavities in %d passes\n', pass);
    return
else
    fprintf(1,'\nCavities tuned to within %f kHz in %d passes\n\n', ...
        max_error, pass);
end

% at this point initial cavity tuning loop is complete - set tuner home positions
fprintf(1,'Setting tuner HOME positions\n');

lcaPut([station,':CAVTUNR:LOOPON:HOME.PROC'], 1);
fprintf(1,'Restoring original station drive power\n');
% write the desired drive power
lcaPut([station,':KLYSDRIVFRWD:POWER:ON'], original_drive_power);
pause(30);	% wait for things to settle

% here we adjust the cavity combining networks amplitudes to match the measured
% values from the database using IQ&A values and coupling/cable losses

% measure the gap voltage in each cavity
cavity_voltage = zeros(1,num_cavities);
for cavity = 1:num_cavities,
    cavity_voltage(cavity) = ...
        lcaGet([station,':CAV',num2str(cavity), 'PROBE:AMPL']);
end

fprintf(1, '\nbefore normalization\n');        fprintf(1, '\tcav %1d II = %8.2f\n', cavity, cavity_II);

for ind = 1:num_cavities,
    fprintf(1, 'cavity %d:\n\tvoltage = %f\n', ind, cavity_voltage(ind));
    fprintf(1, '\tfitted gain = %f\n', fitted_gain(ind));
end
fprintf(1, '\n');

% scale each cavity voltage by total station gap voltage
cavity_voltage = cavity_voltage/sum(cavity_voltage);

% update each cavity combining network based on the saved value of max amplitude
% from previous measurement loop and the actual IQ & A measured voltage distribution

delta_coeffs = cavity_voltage/mean(cavity_voltage)./(fitted_gain/mean(fitted_gain));
new_magnitude = old_magnitude .* delta_coeffs;
% protect from saturating the DACs (max count = 2047 including ~150 counts for offset)
if max(new_magnitude) > (2047 - 150)
  new_magnitude = new_magnitude * ((2047 - 150)/(max(abs((new_magnitude)))));
  fprintf(1,'Possible saturation of DACs - scaling max cavity combiner coeffs to 1900\n');
end

fprintf(1, '\nafter normalization\n');        fprintf(1, '\tcav %1d II = %8.2f\n', cavity, cavity_II);

for ind = 1:num_cavities,
    fprintf(1, 'cavity %d:\n\tvoltage = %f\n', ind, cavity_voltage(ind));
    fprintf(1, '\tfitted gain = %f\n', fitted_gain(ind));
    fprintf(1, '\told magnitude = %f\n', old_magnitude(ind));
    fprintf(1, '\tnew magnitude = %f\n', new_magnitude(ind));
end
fprintf(1, '\n');

for cavity = 1:num_cavities,
    cavity_II = new_magnitude(cavity) * cos((pi/180) * new_phases(cavity));
    cavity_QI = new_magnitude(cavity) * sin((pi/180) * new_phases(cavity));
    cavity_IQ = cavity_QI;	% later we may want to remove modulator errors here
    cavity_QQ = cavity_II;	% and here
    
    fprintf(1,['Updating cavity combiner network for cavity #', num2str(cavity),'\n']);
    
    % write the new settings for the direct loop baseband modulator
    lcaPut([rf_module,':CAV',num2str(cavity),'.A'], cavity_II);
    lcaPut([rf_module,':CAV',num2str(cavity),'.C'], cavity_IQ);
    lcaPut([rf_module,':CAV',num2str(cavity),'.E'], cavity_QI);
    lcaPut([rf_module,':CAV',num2str(cavity),'.G'], cavity_QQ);
    lcaPut([rf_module,':MODU.LOD'], 1);

        fprintf(1, '\tcav %1d II = %8.2f\n', cavity, cavity_II);
        fprintf(1, '\tcav %1d IQ = %8.2f\n', cavity, cavity_IQ);
        fprintf(1, '\tcav %1d QI = %8.2f\n', cavity, cavity_QI);
        fprintf(1, '\tcav %1d QQ = %8.2f\n', cavity, cavity_QQ);
        
end

% next we measure the tuner sensitivities (mm/degree) for each cavity
fprintf(1,'\n');
for cavity = 1:num_cavities,
    
    fprintf(1,['Calculating tuner sensitivity for cavity #',num2str(cavity),'\n']);
    
    % remember the current setting of the probe phase offset
    present_phase = ...
        lcaGet([station,':CAV',num2str(cavity), 'PROBE:PHASE:OFFS']);
    % remember the current position of the tuner (mm)
    present_mm = ...
        lcaGet([station,':CAV',num2str(cavity), 'TUNR:STEP:MOTOR.RBV']);
    % offset the probe phase by delta_degrees
    lcaPut([station,':CAV',num2str(cavity),'PROBE:PHASE:OFFS'], ...
        present_phase + delta_degrees);
    % read the new position of the tuner (mm)
    pause(10);	% wait for the tuners to move
    new_mm = ...
        lcaGet([station,':CAV',num2str(cavity), 'TUNR:STEP:MOTOR.RBV']);
    % calculate the new tuner sensitivity (mm/degree)
    mm_per_degree = abs((present_mm - new_mm)/delta_degrees);	% do we really want the ABS here?
    
    lcaPut([station,':CAV',num2str(cavity), 'TUNR:POSN:DELTA.C'], ...
        mm_per_degree);
    % remove the delta_degrees offset of the probe phase
    lcaPut([station,':CAV',num2str(cavity),'PROBE:PHASE:OFFS'], ...
        present_phase);
    fprintf(1, '\tcavity %d sensitivity is %6.4f mm/Deg\n', ...
        cavity, mm_per_degree);
end

% close the HVPS voltage loop
lcaPut([station,':HVPS:LOOP:CTRL'], 2);
fprintf(1,'*** Tuner Configuration Sequence Complete***\n');
return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [status] = waitfortunermovetopot( station, cavityNumber, desiredPos, tWait )
%
% cavityNumber      number of cavity 1..4
% desiredPos        desired position of tuner setpoint in mm
% tWait             amount of time in seconds to wait for move before exiting
%
% status            -1 for failure; 1 for success
%
% move to pot rather than stepper motor readback value

% positional tolerance
tolPos = 0.25;
status = -1;
% pvTuner = sprintf('%s:CAV%1dTUNR:STEP:MOTOR.RBV', station, cavityNumber);
pvTuner = sprintf('%s:CAV%1dTUNR:POSN', station, cavityNumber);
nWait = round(tWait);
currentPos = lcaGet(pvTuner);
for ind = 1:nWait,
    if(abs(currentPos - desiredPos) > tolPos)
            pause(1)
            currentPos = lcaGet(pvTuner);
            fprintf(1, 'desired position = %f; position = %f\n', ...
                desiredPos, currentPos);
    else
        status = 1;
        return;
    end % if(abs(currentPos - desiredPos) > tolPos)
end % for ind = 1:nWait,

% exceeded desired wait time
fprintf(1,'Error - unable to move cavity #%1d tuner\n', cavityNumber);
return
end
