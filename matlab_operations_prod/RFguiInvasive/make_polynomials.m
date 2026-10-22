function make_polynomials(hObject, eventdata, handles)
% hObject    handle to loadDataPb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
% make_polynomials.m - Measures the cavity frequency vs. tuner position
%                      and creates polynomials to describe the relationship.
%                      Also measures the temperature sensitivity of each cavity
%                      by applying RF voltage and measureing the frequency shift.
%                      All polynomial coefficients and sensitivities are written
%                      to the EPICS database.  Paul 5/1/97

% J. Sebek, V. Pacak  02/06/2007
%       install changes to ignore data out of range or when fit is bad
%       use only good data to find polynomial fit
% J. Sebek 10/31/2006  - restore original DSP file name if desired one
% cannot be loaded
%MOD: 01-14-2004 W. Colocho, For NOISE_I_BL.out (and Q) use RF_DATA/<station>
%     (u_header) instead of RFTBL.
% 11-14-02 Changes R. Akre
% Check for 2CV or 4CV instead of LER or HER
% Widen range of polynomial fit.
% MOD: W. Colocho, 06/1/2003 - Made into a function(). It uses handles
% structure to pass data. Called by RFguiInvasive.m


format compact

fprintf(1,'\n*** Beginning Measuring Cavity Tuning Polynomials ***\n');

% here are some configuration strings

station = handles.station;
rf_data = handles.rfData;
rf_module    = [station,':STN:RFP'];
gainFactor = get_RFP_noise_gain(station);%RFP module dependent gain
% previously measured noise files
% define the measured loop response file names
v_header = '/dat'; 			% string for the augeas stuff
u_header = [rf_data,'/',station];  	% string for the system stuff
measured_cavity_I = '/CAVITY_I';
measured_cavity_Q = '/CAVITY_Q';
noise_I_file = '/dat/NOISE_I_BL';	% file to load into I DAC
noise_Q_file = '/dat/NOISE_Q_BL'; 	% file to load into Q DAC

measured_I_noise = '/NOISE_I_BL.out';
measured_Q_noise = '/NOISE_Q_BL.out';

DSP_file = handles.dspFile; % define DSP files

% some config values
hvps_voltage_HER = 58;		% use this value for tuning HER - allows no drive signal
hvps_voltage_LER = 55;		% use this value for tuning LER - allows no drive signal

max_count = 30;			% maximum number of tries to write data files
max_pass = 100;			% maximum number of tries to tune cavities
Tsample = handles.Tsample;      % sampling interval from handles
f_rf = handles.rfFrequency;	% rf frequency - Hz
F_rf_MHz = handles.rfFrequencyMHz  %rf frequency - MHz
w_rf = f_rf*2*pi;		% rf frequency - radians/sec
fs = 1/Tsample;  		% clock frequency
ts = Tsample;			% sampling interval name used here
num_data = 2^16;		% set the desired length of the data files
num_fft  = 2^14;		% set the desired length of FFTs
poly_order = 3;			% order of polynomials for cavity frequency vs. position
t  = linspace(0,ts*num_data,num_data);	% time vector
chop=7000;			% how much of the data is chopped off
% array of strings for use in writing polynomial coefficients
polyTag = [
    '.D';
    '.C';
    '.B';
    '.A'
    ];

% cut on good fit
maxGoodResnorm = 200;

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
    fprintf(1,'Error - incorrect cavity number - not 4CV or 2CV\n');
    return
end

%Prompt for cavity range

promptTxt = {'ENTER FIRST CAVITY','ENTER LAST CAVITY'};
dlgTitle = 'Cavity Range';  defTxt = {'1',num2str(num_cavities)};
answer=inputdlg(promptTxt,dlgTitle,[1 20],defTxt);
if isempty(answer)
    fprintf(1,'No cavities selected by user\n');
    return
end

firstCav = str2num(char(answer(1)));
lastCav = str2num(char(answer(2)));
if (isempty(firstCav) | isempty(lastCav) )
    fprintf(1,'Non numeric value entered for CAVITY number\n')
    return
end

numCavs = lastCav - firstCav + 1;   %Used for matix initializations
if ((numCavs) <=0) | (numCavs > num_cavities)
    fprintf(1,'Cavity range %i to %i is not vaid\n',firstCav,lastCav)
    return
end

% make sure the RF is on - remove carrige return
fprintf(1,'Configuring RF system - please be patient\n');
[status,answer] = caShell(['caget -t -w 20 ', rf_module,':RFENABLE']);
if status ~=0
    fprintf(1,'Error - unable to read RF tune/operate status\n');
    return
end
if strcmp(answer(1:2),'ON') ~= 1
    fprintf(1,'Error - RF must be on to tune cavities\n');
    return
end

% make sure the direct loop is off - remove carrige return
[status,answer] = caShell(['caget -t -w 20 ', station,':STNDIRECT:LOOP:CTRL']);
if status ~=0
    fprintf(1,'Error - unable to read direct loop on/off status\n');
    return
end
if ( (length(answer) < 3) || (strcmp(answer(1:3),'OFF') ~= 1) )
    fprintf(1,'Error - Direct loop must be open for this measurement\n');
    return
end

% open the HVPS voltage loop
[status,answer] = caShell(['caput -w 20 ', station,':HVPS:LOOP:CTRL 0']);
if status ~=0
    fprintf(1,'Error - can not disable HVPS loop\n');
    return
end

% set HVPS voltage
fprintf(1,'Setting desired station HVPS operating voltage\n');
if num_cavities == 4,
    [status,answer] = caShell(['caput -w 20 ', station,':HVPS:VOLT:CTRL.VAL ', ...
        num2str(hvps_voltage_HER)]);
    if status ~=0
        fprintf(1,'Error - can not set HVPS output voltage\n');
        return
    end
else
    [status,answer] = caShell(['caput -w 20 ', station,':HVPS:VOLT:CTRL.VAL ', ...
        num2str(hvps_voltage_LER)]);
    if status ~=0
        fprintf(1,'Error - can not set HVPS output voltage\n');
        return
    end
end

% make sure the RF is in operate mode - remove carrige return
[status,answer] = caShell(['caput -w 20 ', rf_module,':RUNMODE 1']);
if status ~=0
    fprintf(1,'Error - unable to place RF module in OPERATE mode\n');
    return
end

% disable tuner loop
fprintf(1,'Deactivating tuner loop\n');
[status,answer] = caShell(['caput -w 20 ', station,':CAVTUNR:LOOP:CTRL 0']);
if status ~=0
    fprintf(1,'Error - can not disable the tuner loop\n');
    return
end

% disable the drive power loop for ON_CW mode
[status,answer] = caShell(['caput -w 20 ', station,':STN:ON:CTRL 0']);
if status ~=0
    fprintf(1,'Error - can not enable drive power loop for ON_CW mode\n');
    return
end

fprintf(1,'Zeroing the ON_CW drive power\n');
% must take care of both cases - with/wo gap module
[status,answer] = caShell(['caput -w 20 ', station,':STN:GFF:IQ.A ', num2str(0)]);
if status ~=0
    fprintf(1,'Error - can not clear ON_CW drive power setpoint\n');
    return
end
[status,answer] = caShell(['caput -w 20 ', station,':STN:ON:IQ.A ', num2str(0)]);
if status ~=0
    fprintf(1,'Error - can not clear ON_CW drive power setpoint\n');
    return
end

% move the tuners back to home
fprintf(1,['Moving all tuners to HOME position\n']);
[status,answer] = caShell(['caput -w 20 ', station,':CAVTUNR:LOOPON:RESET.PROC 1']);
if status ~=0
    fprintf(1,['Error - unable to HOME tuners\n']);
    return
end
pause(10); % let the tuners get home

for cavity = firstCav:lastCav,
    % initialize the tuner task so calculated position matches actual position
    fprintf(1,['Initializing cavity #',num2str(cavity),' stepper motor task\n']);
    [status,answer] = caShell(['caput -w 20 ', station,':CAV',num2str(cavity),'TUNR:STEP:STOP.PROC 1']);
    if status ~=0
        fprintf(1,['Error - unable to initialize cavity #',num2str(cavity),' stepper motor task\n']);
        return
    end
    %   pause(5); % let the task initialize
end
pause(5); % let the task initialize

% write the desired length of the data files to the RF module driver
fprintf(1,'Setting data file length\n');
[status,answer] = caShell(['caput -w 20 ', rf_module,':MODU.RMSZ ', num2str(num_data/1024)]);
if status ~=0
    fprintf(1,'Error - can not set the desired file length\n');
    return
end

% make sure the ripple loop is closed - remove carrige return
fprintf(1,'Checking status of RIPPLE loop\n');
[status,answer] = caShell(['caget -t -w 20 ', rf_module,':RIPPLELOOP']);
if status ~=0
    fprintf(1,'Error - unable to read ripple loop status\n');
    return
end
if strcmp(answer(1:2),'On') ~= 1
    fprintf(1,'Activating Ripple loop\n');
    [status,answer] = caShell(['caput -w 20 ', rf_module,':RIPPLELOOP 1']);
    if status ~=0
        fprintf(1,'Error - can not close the ripple loop\n');
        return
    end
end

% open the direct loop
fprintf(1,'Opening DIRECT RF loop\n');
[status,answer] = caShell(['caput -w 20 ', rf_module,':DIRECTLOOP 0']);
if status ~=0
    fprintf(1,'Error - can not open the direct loop\n');
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
if strcmp(answer(1:length(answer)),noise_I_file) ~= 1
    fprintf(1,'loading correct DAC_I file to module RAM\n');
    [status,answer] = caShell(['caput -w 20 ', rf_module,':MODU.DIRF ',noise_I_file]);
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
if strcmp(answer(1:length(answer)),noise_Q_file) ~= 1
    fprintf(1,'loading correct DAC_Q file to module RAM\n') ;
    [status,answer] = caShell(['caput -w 20 ', rf_module,':MODU.DQRF ',noise_Q_file]);
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
[status,answer] = caShell(['caput -t -w 20 ', rf_module,':MODU.CIRF ', ...
    v_header,measured_cavity_I]);
if status ~=0
    fprintf(1,'Error - unable to write CAV_I filename\n');
    return
end
[status,answer] = caShell(['caput -t -w 20 ', rf_module,':MODU.CQRF ', ...
    v_header,measured_cavity_Q]);
if status ~=0
    fprintf(1,'Error - unable to write CAV_Q filename\n');
    return
end

% write the corrrect file for the DSP and reload it
[status,answer] = caShell(['caget -t -w 20 ', rf_module,':MODU.DSPE']);
if status ~=0
    fprintf(1,'Error - unable to read DSP filename\n');
    return
end
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

% turn off the lead compensation
[status,answer] = caShell(['caput -w 20 ', rf_module,':LEADCOMP 0']);
if status ~=0
    fprintf(1,'Error - can not turn off the lead compensation\n');
    return
end

% turn off the integral compensation
[status,answer] = caShell(['caput -w 20 ', rf_module,':INTCOMP 0']);
if status ~=0
    fprintf(1,'Error - can not turn off the integral compensation\n');
    return
end

pass = 0;		% clear the pass counter
max_error = 999;	% set the max_error for first run through cavities
% decrease size of tuner excursion
% maxPass = 22;
maxPass = 17;
cavity_frequency = NaN * zeros(num_cavities,maxPass);
tuner_position = NaN * zeros(num_cavities,maxPass);
tuner_step_count = maxPass * ones(1,4);
home = zeros(1,num_cavities);

% get figure handle for make_polynomials and update gui structure
figHandles = handles.figHandles; % retrieve figure data
figInd=length(figHandles);
figInd=figInd+1;
figHandles(figInd) = figInd;
handles.figHandles = figHandles;
guidata(handles.output, handles); % update  handles data

% next we loop through the four cavities, move tuners, measure frequency
% to allow making the tuner position polynomials
for cavity = firstCav:lastCav,

    % remember the HOME positions
    [status,answer] = caShell(['caget -t -w 20 ', station,':CAV',num2str(cavity), ...
        'TUNR:POSN:ONHOME']);
    home(cavity) = str2num(answer);
    if status ~=0
        fprintf(1,['Error - unable to read cavity #',num2str(cavity),' home position\n']);
        return
    end

    % ************************* Change from -18 to -2  to  -24 to -2 ( 1:19 to 22 and -20 to -26)

    % move the cavity tuner in 18mm (raise freq) and measure freq every 2mm until out 18mm
    for pass = 1:maxPass,
        % delta_position = (2*pass)-26;
        delta_position = (2*pass) - (maxPass + 6);

        % move the tuner
        fprintf(1,['\nMoving cavity #',num2str(cavity),' to ', ...
            num2str(home(cavity)+delta_position),' mm\n']);
        [status,answer] = caShell(['caput -w 20 ', station,':CAV',num2str(cavity),'TUNR:POSN:CTRL ', ...
            num2str(home(cavity)+delta_position)]);
        if status ~=0
            fprintf(1,['Error - unable to change cavity #',num2str(cavity),' tuner position\n']);
            return
        end

        % wait for the tuner to move
        if(pass == 1)
            pause(60); % first move is a big one
        else pause(5);
        end

        % measure the tuner position via potentiometer
        [status,answer] = caShell(['caget -t -w 20 ', station,':CAV',num2str(cavity), ...
            'TUNR:POSN']);
        tuner_position(cavity,pass) = str2num(answer);	% store in a matrix
        if status ~=0
            fprintf(1,['Error - unable to read cavity #',num2str(cavity),' tuner position\n']);
            return
        end
        fprintf(1,['New tuner position is ',num2str(tuner_position(cavity,pass)),' mm\n']);

        % reinitialize the stepper motor task to keep desired position equal to actual
        [status,answer] = caShell(['caput -w 20 ', station,':CAV',num2str(cavity),'TUNR:STEP:STOP.PROC 1']);

        % measure the cavity resonance frequency for this tuner position

        % set CAVITY multiplexer to variable=cavity-1
        [status,answer] = caShell(['caput -s -w 20 ', rf_module,':CAVSEL ',num2str(cavity)]);
        if status ~=0
            fprintf(1,['Error - can not set the CAVITY signal to ',num2str(cavity),'\n']);
            return
        end
        
        cyclerfstates( rf_module );

        % get the data files
        % read the CAVITY_I file first
        [status,answer] = caShell(['caput -w 20 ', rf_module,':MODU.GCIR 1']);
        if status ~=0
            fprintf(1,'Error - can not activate the CAVITY_I file read\n');
            return
        end
        fprintf(1,'Moving data from I channel to file\n');
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
        [status,answer] = caShell(['caput -w 20 ', rf_module,':MODU.GCQR 1']);
        if status ~=0
            fprintf(1,'Error - can not activate the CAVITY_Q file read\n');
            return
        end
        fprintf(1,'Moving data from Q channel to file\n');
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

        % make the file ID's
        fid1 = -1;
        fid2 = -1;
        while (fid1 == -1), fid1 = fopen([u_header,measured_cavity_I],'r','ieee-be'); end;
        while (fid2 == -1), fid2 = fopen([u_header,measured_cavity_Q],'r','ieee-be'); end;
        if (cavity == firstCav) & (pass == 1), 	% don't bother reading again
            fid3 = -1;
            fid4 = -1;
            while (fid3 == -1), fid3 = fopen([u_header,measured_I_noise],'r','ieee-be'); end;
            while (fid4 == -1), fid4 = fopen([u_header,measured_Q_noise],'r','ieee-be'); end;
        end

        % read the measured data files
        [header,count] = fread(fid1,[1,16],'char');
        fprintf(1,'Reading %s%s\n',u_header,measured_cavity_I);
        [i_dat,count] = fread(fid1,[1,inf],'short'); fclose(fid1);
        header = setstr (header);
        if count ~= (num_data)
            ['length of file in ',header,' is incorrect. Length = ',num2str(count)]
            return
        end
        [header,count] = fread(fid2,[1,16],'char');
        fprintf(1,'Reading %s%s\n',u_header,measured_cavity_Q);
        [q_dat,count] = fread(fid2,[1,inf],'short'); fclose(fid2);
        header = setstr (header);
        if count ~= (num_data)
            ['length of file in ',header,' is incorrect. Length = ',num2str(count)]
            return
        end

        i_dat = (fix(i_dat/16))/2047;	% shift data and scale
        q_dat = (fix(q_dat/16))/2047;	% shift data and scale
        out_data = i_dat + j*q_dat;
        clear i_dat
        clear q_dat

        if (cavity == firstCav) & (pass ==1),
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

            i_dat = (fix(i_dat/16))/2047;
            q_dat = (fix(q_dat/16))/2047;
            in_data = (i_dat + j*q_dat) / gainFactor;
            clear i_dat
            clear q_dat
        end

        if (cavity == firstCav) & (pass ==1),
            delta_f=fs/(num_fft);
            baseband_freq=delta_f*[((-1*(num_fft/2 -1)):-1) 0 (1:num_fft/2)];
        end

        fprintf(1,['Calculating cavity #',num2str(cavity),' transfer function\n']);
        [Hsum,FF]=tfestimate(in_data,out_data,hanning(num_fft),[],num_fft,fs);
        % ignore the DC term and neighbors - usually has large errors
        Hsum(1:3) = Hsum(10);
        Hsum(length(Hsum)-3:length(Hsum)) = Hsum(length(Hsum)-10);
        Hsum=Hsum';
        % reorder the results to go from -freq to + freq
        Hsum = [Hsum(num_fft/2+2:num_fft) Hsum(1:num_fft/2+1)]; % reorder by frequency

        magnitude = 20*log10(abs(Hsum));
        phases = angle(Hsum);

        %     figHandles = handles.figHandles; % retrieve figure data
        %     figInd=length(figHandles);
        %     figInd=figInd+1; figure(figInd); clf; figHandles(figInd) = figInd;
        %     handles.figHandles = figHandles;
        %     guidata(handles.output, handles); % update  handles data
        figure(figInd); clf;
        subplot(211)
        plot(baseband_freq(chop:num_fft-chop)/1e3, ...
            magnitude(chop:num_fft-chop),'r.')
        junk=axis;
        axis([junk(1:2) -30 30])
        grid on
        title(['Measured Transfer Function of ',station,' Cavity #',num2str(cavity)])
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
        % store the measured frequency as kHz offset from 476 MHz
        if xTot(6) >= maxGoodResnorm,
            fprintf(1, 'resnorm too large; data ignored\n');
        else
            cavity_frequency(cavity,pass) = ((Wc/(2*pi)) - F_rf_MHz)*1000;
        end % if xTot(6) >= maxGoodResnorm,

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
            (180/pi)*angle(exp(j*fitted_phase)),'b')

        %plot frequency detuning vs. tuner position

        figure(figInd+cavity);
        clf
        plot(tuner_position(cavity,1:pass),cavity_frequency(cavity,1:pass),'.-');
        title([station,', Cavity # ',num2str(cavity),', Frequency Detuning vs. Tuner Position']);
        xlabel('Tuner Position, [mm]');
        ylabel('Frequency Detuning, [kHz]');
        grid on

        %% stop this cavity if  the cavity frequency goes beyond 600 kHz above 476 MHz  *******************
        if cavity_frequency(cavity,pass) > 600
            tuner_step_count(cavity) = pass;
            break;
        end

    end % for pass = 1:maxPass,
    fprintf(1,['Moving cavity #',num2str(cavity),' tuner back to HOME position\n']);
    [status,answer] = caShell(['caput -w 20 ', station,':CAV',num2str(cavity),'TUNR:LOOP:RESET.PROC 1']);
    if status ~=0
        fprintf(1,['Error - unable to HOME cavity #',num2str(cavity),' tuner\n']);
        return
    end
end % for cavity = firstCav:lastCav,


% make the polynomials and store the coefficeints into the database
fprintf(1,['\nWriting tuner polynomials to database\n']);
coeffs = zeros(numCavs,poly_order+1);
for cavity = firstCav:lastCav,
    tunePos = tuner_position(cavity, ~isnan(cavity_frequency(cavity,:)));
    cavFreq = cavity_frequency(cavity, ~isnan(cavity_frequency(cavity,:)));
%     [coeffs(cavity,:),junk] = polyfit(tuner_position(cavity,1:tuner_step_count(cavity))-home(cavity), ...
%         cavity_frequency(cavity,1:tuner_step_count(cavity)),poly_order);
    [coeffs(cavity,:),junk] = polyfit(tunePos-home(cavity), cavFreq, poly_order);
    figure(figInd+cavity); hold on;
    fitFreq = polyval(coeffs(cavity,:), tunePos-home(cavity));
    plot(tunePos, fitFreq, 'r');
    % write the tuning polynomial coefficients to the database
    for pass = 1:poly_order+1,
        [status,answer] = caShell(['caput -w 20 ', station,':CAV', num2str(cavity), ':FREQ:OFFS', ...
            sprintf('%s %10.6f', polyTag(pass,:), coeffs(cavity,pass))]);
        if status ~=0
            fprintf(1,'Error - can not write polynomial coefficient to database\n');
            return
        end
    end
end

% move the tuners back to home
fprintf(1,['Moving all tuners to HOME position\n']);
[status,answer] = caShell(['caput -w 20 ', station,':CAVTUNR:LOOPON:RESET.PROC 1']);
if status ~=0
    fprintf(1,['Error - unable to HOME tuners\n']);
    return
end
pause(10); % wait for tuners to move

for cavity = firstCav:lastCav,
    % initialize the tuner task so calculated position matches actual position
    fprintf(1,['Initializing cavity #',num2str(cavity),' stepper motor task\n']);
    [status,answer] = caShell(['caput -w 20 ', station,':CAV',num2str(cavity),'TUNR:STEP:STOP.PROC 1']);
    if status ~=0
        fprintf(1,['Error - unable to initialize cavity #',num2str(cavity),' stepper motor task\n']);
        return
    end
    %   pause(5); % let the task initialize
end
pause(5); % let the task initialize

fprintf(1,'Remembering orginal ON_CW drive power\n');
[status,answer] = caShell(['caget -t -w 20 ', station,':KLYSDRIVFRWD:POWER:ON']);
original_drive_power = str2num(answer);	% save the origianl ON_CW drive power
if status ~=0
    fprintf(1,'Error - can not read original ON_CW drive power\n');
    return
end

% enable the drive power loop for ON_CW mode
[status,answer] = caShell(['caput -w 20 ', station,':STN:ON:CTRL 1']);
if status ~=0
    fprintf(1,'Error - can not enable drive power loop for ON_CW mode\n');
    return
end

% turn tuner loop to "ON" mode - enable loop
fprintf(1,'Activating tuner loop\n');
[status,answer] = caShell(['caput -w 20 ', station,':CAVTUNR:LOOP:CTRL 1']);
if status ~=0
    fprintf(1,'Error - can not enable the tuner loop\n');
    return
end

fprintf(1,'Restoring original station ON_CW drive power\n');
% write the desired drive power
[status,answer] = caShell(['caput -w 20 ', station,':KLYSDRIVFRWD:POWER:ON ', num2str(original_drive_power)]);
if status ~=0
    fprintf(1,'Error - can not restore ON_CW drive power setpoint\n');
    return
end

% close the HVPS voltage loop
fprintf(1,'Closing HVPS loop\n');
[status,answer] = caShell(['caput -w 20 ', station,':HVPS:LOOP:CTRL 2']);
if status ~=0
    fprintf(1,'Error - can not enable HVPS loop\n');
    return
end

% wait until tuners stabilize
fprintf(1,'Waiting 2 minutes for the cavity temperatures to stabilize\n');
pause(120);
% measure tuner positions after cavities have warmed up
% allocate space for data
tuner_position_hot = zeros(1,numCavs);
freq_estimate = zeros(1,numCavs);
cavity_voltage = zeros(1,numCavs);
voltage_correction = zeros(1,numCavs);
for cavity = firstCav:lastCav,
    % measure the tuner position via potentiometer
    [status,answer] = caShell(['caget -t -w 20 ', station,':CAV',num2str(cavity), ...
        'TUNR:POSN']);
    tuner_position_hot(cavity) = str2num(answer);	% store in a matrix
    if status ~=0
        fprintf(1,['Error - unable to read cavity #',num2str(cavity),' tuner position\n']);
        return
    end

    % evaluate the polynomial to see what the estimated frequency is based on position alone
    freq_estimate(cavity) = polyval(coeffs(cavity,:), ...
        tuner_position_hot(cavity)-home(cavity));

    % measure the cavity voltage
    [status,answer] = caShell(['caget -t -w 20 ', station,':CAV',num2str(cavity), ...
        'PROBE:AMPL']);
    cavity_voltage(cavity) = str2num(answer);	% store in a matrix
    if status ~=0
        fprintf(1,['Error - unable to read cavity #',num2str(cavity),' voltage\n']);
        return
    end

    % calculate the tuning correction factor based on the cavity_voltage^2
    voltage_correction(cavity) = -freq_estimate(cavity)/(cavity_voltage(cavity)^2);

    % write the correction factor into the database
    [status,answer] = caShell(['caput -w 20 ', station,':CAV',num2str(cavity),':FREQ:OFFS.E ', ...
        num2str(voltage_correction(cavity))]);
    if status ~=0
        fprintf(1,'Error - can not write cavity %d tuning voltage correction factor\n', cavity);
        return
    end
end

fprintf(1,'*** Cavity Tuning Polynomials Sequence Complete ***\n');
