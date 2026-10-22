function comb_filter_freq(hObject, eventdata, handles)
% hObject    handle to loadDataPb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
% Change_comb_filter_freq.m - This program calculates the new synchrotron
%                       frequency for a given total accellerating voltage.
%                       Next, it calculates the coefficients of the comb
%                       filter for the given synchrotron frequency and
%                       updates the "cmfIirCoefs..." file. The new coeffs
%                       are placed in the file to be loaded when COMBSETSEL
%                       is set to "0". The modified file is loaded into the
%                       comb filter module and activated.
%                                                   Vojtech Pacak 8/3/04
%MOD: 02-08-2007 Program modified for the new Comb Filter Modules
%                                                   Vojtech
%MOD: 01-14-2004 W. Colocho, For NOISE_I_BL_SMALL.out (and Q) use RF_DATA/<station>
%     (u_header) instead of RFTBL.
% MOD: W. Colocho, 06/01/2003 - Made into a function(). It uses handles
% structure to pass data. Called by RFguiInvasive.m


format compact

fprintf(1,'\n*** Beginning Comb Filter Coeff Modification ***\n');
fprintf(1,'\n*** The program calculates the A1 Comb Filter coeff''s for the selected ring voltage. ***\n');
fprintf(1,'*** The new A1 coeff''s,(II and QQ), will be written into the inactive bank.***\n');
fprintf(1,'*** The modified banks will be activated in all RF station CF2 modules. ***\n');

% Use handles structure to load important machine parameters
station = handles.allStations(1).name;   % update the station
allStations = handles.allStations; % list of all RF stations
machine = handles.machine;              % machine
h   =  handles.harmonicNumber;          % harmonic number
f_rev = handles.revolutionFreq;         % revolution frequency
f_rf    = handles.rfFrequency;			% RF frequency - Hz
F_rf_MHz = handles.rfFrequencyMHz;      % RF frequency - MHz
rf_data = handles.rfData;	            % directory that contains the data files
rf_tbl  = handles.tableDir;             % directory that contains the table files
cfmIirCoefFile = handles.combIir;       % cfm file
hcomb   = handles.samplesPerRev;        % number of clock samples per 1 revolution
Tsample = handles.Tsample;              % sampling interval
Eo = handles.ringEnergy;                % energy of the ring in eV
synchRadLoss = handles.synchRadLoss;    % losses due synchrotron radiation [V]
beamCurrent = handles.beamCurrent/1000; % beam current [A]
C  = handles.lossFactorHOM;             % HOM losses factor
alpha = handles.compactionFactor;       % momentum compaction factor
rf_module    = [station,':STN:RFP'];    %"shortcut" to PV on RFP window
comb_module    = [station,':STN:CF2'];  %"shortcut" to PV on COMB_F1 window
handles.rfModule = rf_module;           % Needed to pass rf_module to save_RFP_mux

DSP_file = handles.dspFile;             % define DSP files = /dsp/rippleRfp normally

% Prepare "LER" or "HER" strings for the filename
if  strcmp(machine,'pepii-HER')==1
    ring = 'HER';
elseif strcmp(machine,'pepii-LER')==1
    ring = 'LER';
end
% Some configuration values
max_count = 10;			% maximum number of tries to write data files
w_rf = 2*pi*f_rf;		% RF frequency - radians/sec
fs = 1/Tsample;  		% clock frequency in Hz
T0 = 1/f_rev;			% revolution period

%***CHECKING BEAM CURRENT AND SELECTING TOTAL GAP VOLTAGE*****************
% Get the beam current PV reading for the selected machine
% Check the beam is <= 10 mA
fprintf(1,'\nChecking there is no circulating beam inside the machine\n');
if  strcmp(machine,'pepii-HER')==1
    try [answer] = lcaGet('BICH:DCCT:SUMY');
    catch 
        fprintf(1,'\nError - unable to read HER beam current\n');
        return
    end
elseif strcmp(machine,'pepii-LER')==1
    try [answer] = lcaGet('BICL:DCCT:SUMY');
    catch 
        fprintf(1,'\nError - unable to read LER beam current\n');
        return
    end
else
    fprintf(1,'\nMachine Name Error, program stops\n')
    return
end  %strcmp(machine,'pepii-HER')==1
beam = answer;
if beam > 10
    fprintf(1,'\nError - there is circulating beam in the machine\n');
    fprintf(1,'Comb filter setting cannot be changed - program stops \n');
    return
end  %beam > 1

% Get the total gap voltage for the machine
fprintf(1,'\nGetting the total gap voltage in the machine\n');
if strcmp(machine,'pepii-HER')==1
    try [answer] = lcaGet('BICH:RF:VOLT');
    catch 
        fprintf(1,'\nError - unable to read HER total gap voltage\n');
        return
    end
else strcmp(machine,'pepii-LER')==1;
    try [answer] = lcaGet('BICL:RF:VOLT');
    catch 
        fprintf(1,'\nError - unable to read LER total gap voltage\n');
        return
    end
end  %strcmp(machine,'pepii-HER')==1
%answer = 13700 %!!!!!!!!!!!!!!!! COMMENT OUT BEFORE COMMITING
total_gap_voltage = answer;
% Display the current total accelerating voltage
fprintf(1,['\n The total accelerating voltage = ',num2str(answer),'kV\n'])

% Prompt for confirmation, input corect gap voltage from the keyboard if needed
exit_to_final_conf = 0; % exit flag from voltage confirmation loop
while exit_to_final_conf == 0;
    confirm = input('Is the machine total voltage correct? (y/n),   [n] ','s');
    if (isempty(confirm) || strncmpi(confirm,'n',1)==1)
        fprintf(1,'\nEnter the correct gap voltage in kV!\n')
        answer = input('Selected gap voltage in kiloVolts is: ');
        total_gap_voltage = answer;
        exit_to_final_conf = 1;
    elseif strncmpi(confirm,'y',1)==1;
        exit_to_final_conf = 1;
    end % if (isempty...
end %while exit_to_final_conf == 0;


Vg = total_gap_voltage*1e3;   %Machine total voltage in Volts

% Final confirmation the selected gap voltage is correct
exit_to_final_conf = 0; % exit flag from voltage final confirmation loop
while exit_to_final_conf == 0;
    fprintf(1,['\nSelected gap voltage to change comb filter coeff is ',num2str(Vg/1000),' kV\n'])
    confirm = input('Calculate the synchronous frequency and A1 coeff? (y/n),   [y] ','s');
    if (isempty(confirm) || strncmpi(confirm,'y',1)==1)
        exit_to_final_conf = 1;
    elseif strncmpi(confirm,'n',1)==1;
        fprintf(1,'\nYou selected to exit the program.\n')
        fprintf(1,'To change the comb filters restart the program\n')
        return
    end %if (isempty...
end %while exit_to_final_conf == 0;


%***CALCULATION SYNCHRONOUS ANGLE AND SYNCHROTRON FREQUENCY***************
% Now there is all the data necessary to calculate the synchronous phase angle
% and the new synchrotron frequency based on the new total gap voltage

Va = synchRadLoss + (C*((beamCurrent)/2.25)^2)/beamCurrent; %Total (beam) losses per 1 turn [V]

% Calculation of the synchronous angle
fprintf(1,'\nCalculation of the synchronous angle Phi=arccos(Va/Vg) \n')
Phi = (180/pi)*acos(Va/Vg);


% Calculation of the synchrotron frequency
fprintf(1,['\nCalculation of the synchrotron frequency',...
    '\nFsync=f_rev*sqrt((alpha*h*Vg*sin(Phi))/(2*pi*Eo))\n'])
f_sync = f_rev*sqrt((Vg*alpha*h*sin(Phi*pi/180))/(2*pi*Eo));

fprintf(1,'\nCalculation of the new comb filter coeff \n')

% Call the function calculating the new coefficients of comb filter
A1 = make_combs_f(f_rf, h,f_sync,hcomb);

% Final confirmation before changing the comb filter setting
exit_to_final_conf = 0; % exit flag for final confirmation loop
while exit_to_final_conf == 0;
    fprintf(1,['\nSelected gap voltage for new comb filter file is ',num2str(Vg/1000),' kV\n'])
    fprintf(1,['Synchronous angle is ',num2str(Phi,4),' deg\n']);
    fprintf(1,['Synchrotron frequency is ',num2str(round(f_sync)),' Hz\n']);
    fprintf(1,['New value of A1 comb filter coeff is ',num2str(A1),'\n']);
    confirm = input('\nChange the comb filter coefficient? (y/n),   [y] ','s');
    if (isempty(confirm) || strncmpi(confirm,'y',1)==1)
        exit_to_final_conf = 1;
    elseif strncmpi(confirm,'n',1)==1;
        fprintf(1,'\nYou selected to exit the program.\n')
        fprintf(1,'To change the comb filters restart the program\n')
        return
    end %if (isempty...
end %while exit_to_final_conf == 0;
%*****************************
%%This is only for the purpose of testing on PC
%return      %USED ONLY FOR PC TESTING > REMOVE BEFORE COMPILING!!!!!!!!!!
%*****************************


%***THE PROGRAM LOADING THE CF2 COEFF BEGINS *****************************
%All stations in the selected machine will have the new CF2 coeff A1 loaded

for k=1:length(allStations) %Main FOR loop to go through all RF stations
    station = allStations(k).name;
    fprintf(1,['\nUpdating Com Filter Coeffs. file for station ',station,'\n'])

    % Update station dependant parameters
    rf_module       = [station,':STN:RFP'];
    comb_module    = [station,':STN:CF2'];
    handles.rfModule = rf_module;
    handles.station  = station;
    guidata(handles.output,handles); % GUI handles updated to next station

    % Find what cf2 bank is not active
    bank_selector = 0; % will point to inactive bank
    try [answer] = lcaGet([comb_module,':CMBBNKSEL']);
    catch 
        fprintf(1,'Error - can not write the COMB #1 IIR filename\n');
        return
    end
    answer = str2num(char(answer));
    if answer == 0;
        bank_selector = 1;
    else
    end
    II = [':MODU.C',num2str(bank_selector),'05'];
    QQ = [':MODU.C',num2str(bank_selector),'15'];

    % Load the new a1 coeff's into the inactive bank
    fprintf(1,'\nLoading A1 coeffs into II/QQ sections of CF2 inactive bank\n')
    %Load II A1 Coeff first
    try lcaPut([comb_module,II],A1);
    catch 
        fprintf(1,'Error - can not write the A1 coeff into II\n');
        return
    end
    % Next Load QQ A1 Coeff
    try lcaPut([comb_module,QQ],A1);
    catch 
        fprintf(1,'Error - can not write the A1 coeff into QQ\n');
        return
    end
    % End of loading the new a1 coeff's into the inactive bank


    % UPDATE THE FILENAME AND THE COMMENT BEFORE FINALLY ACTIVATING THE BANK
    % First the filename
    fprintf(1,'\nMaking a new file_name for the selected gap voltage\n')
    new_file_name = ['/dat/cf2Iir',ring,'_',num2str(total_gap_voltage/1000),...
        'MV.dat'];
    try lcaPut([comb_module,':MODU.CF1',num2str(bank_selector)], new_file_name);
    catch 
        fprintf(1,'Error - can not change the CF2 filename\n');
        return
    end
    % Next update the comment
    fprintf(1,'\nMaking a new comment input for the selected gap voltage\n')
    comment = [ring,' Comb2 IIR ',num2str(total_gap_voltage/1000),...
        'MV, ',num2str(f_sync/1000),'kHz'];
    try lcaPut([comb_module,':MODU.CC1',num2str(bank_selector)], comment);
    catch 
        fprintf(1,'Error - can not change the CF2 comment\n');
        return
    end

    % Finally activate the updated cf2 bank
    fprintf(1,'\nActivating the updated CF2 Bank\n')
    try lcaPut([comb_module,':CMBBNKSEL'], bank_selector);
    catch 
        fprintf(1,'Error - can not activate the CF2 bank\n');
        return
    end

    % Print final announcement for the updated RF station
    fprintf(1,['\nCoeffs A1 updated and loaded into the station ',station,' CF2 Module\n'])
    fprintf(1,'New CF2 Module Bank selected\n')
    fprintf(1,'CF2 Coeff File_Name Updated but not saved\n')

end  %k=1:length(allStations)... FOR loop to go through all RF stations

% Print final statement
fprintf(1,['\nAll CF2 "cfmIirCoefs',machine,'.tbl" files modified\n'])
fprintf(1,['Comb Filters set for the ',machine,' gap voltage ',num2str(Vg/1000),' kV\n'])
return
