function plot_all_cavities_probe(hObject, eventdata, handles)
 
% plot_IQA2.m - File used to plot the fast history buffer fault files
%               for PEP-II LLRF IQA detector modules 2 and 3 cavity probes.
%               William Colocho, Feb. 28, 2007

% hObject    handle to loadDataPb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

format compact

fprintf(1,'\n*** Beginning Fast History Buffer Plotting for IQA Cavity Signals\n\n');

% some config values and strings
num_files = 30;		% maximum number of fault files which will be stored to disk
fault_file_string1 = '/FAULTIqa2Amp_';	% file name to append fault number to (I)
                                          %number of turns.
station = handles.station;
rf_data = handles.rfData;
u_header = [rf_data,'/',station];   	% string for the caShell stuff
%Tsample = 1/((72*476e6)/3492);  	% sampling interval
Tsample = handles.Tsample;

% determine if the station is 4 cavities or 2 cavities
[status,answer] = caShell(['caget -t -w 20 ', station,':STN:NCV:PLC']);
if status ~=0, fprintf(1,'Error - unable to read number of cavities\n'); return, end
if strcmp (answer(1:3),'4CV' ) == 1
   num_cavities = 4;
elseif strcmp (answer(1:3),'2CV' ) == 1
   num_cavities = 2;
else
   fprintf(1,'Error - incorrect number of cavities - not 4CV or 2CV\n');
   return
end

% define channel names for each mux setting
channel_5 = 'Cavity A Probe';
channel_6 = 'Cavity B Probe';

% define the database strings for each mux setting
string_5 = ':CAV1PROBE:';
string_6 = ':CAV2PROBE:';

if (handles.faultNumber == 0)
   % read the desired fault file number from the panel
   [status,fltNum] = caShell(['caget -t -w 20 ', station,':STN:FAULT:ANUM']);
   if status ~=0
      fprintf(1,'Error - unable to read selected fault file number\n');
      return
   end % if status
else
   fltNum = handles.faultNumber;
end %if handles.faultNumber == 0

% check if the fault file number is valid (between 1 and num_files)
file_number = str2num(fltNum);
if file_number <= 0 | file_number >= (num_files+1)
   fprintf(1,['Error - selected fault file error number out of range file# = %1.0f \n'], ...
               file_number);
  return
end

% read the date and time stamp for the file from the EPICS panel
[status,datetime] = caShell(['caget -t -w 20 ', station,':STN:FAULT:TIME', ...
                           num2str(file_number)]);
if status ~=0
   fprintf(1,'Error - unable to read selected fault file date/time stamp\n');
   return
end
% remove the last characters from the string
%datetime = datetime(1:length(datetime)-1);
datetime = [datetime(1:10),' ' ,datetime(11:end)];

% Loop over cavities
cavProbeCh = [ 5,6,5,6];
cavFowrdCh = [ 1,3,1,3];
cavRefleCh = [ 2,4,2,4];
muxString = {'FRWD','REFL','PROBE'};
IQAnum = 2;
cavProbeTxt = {'Cavity A','Cavity B','Cavity C','Cavity D'};

for thisCav = 1:num_cavities 
    % get the file ID
    if (thisCav == 3), %look at IQA 3 
        fault_file_string1 = '/FAULTIqa3Amp_'; 
        IQAnum = 3;
    end

    fid1 = -1;
    fid1 = fopen([u_header,fault_file_string1,num2str(file_number)],'r','ieee-be');
    if fid1 == -1
      fprintf(1,'Error - can not open selected IQA module fault file:\n')
          disp([u_header,fault_file_string1,num2str(file_number)])
	  return
    end
	
	% read the fault file to find channel name
	% first read 1 word to determine what channel the mux was set to
	fprintf(1,'Reading IQA multiplexer setting from file\n');
	[header1,count]  = fread(fid1,[1,21],'char');	% read the header string
	[mux_data_compare,count] = fread(fid1,[1],'uint16'); %Used to see if its 8 ch. mode.
	[mux_data,count] = fread(fid1,[1],'uint16'); fclose(fid1); % read one word
	mux_data_compare = bitand(mux_data_compare,7) + 1;
	mux_data = bitand(mux_data,7) + 1;	% zero the top 13 bits and add one
	
	% read the measured fault file
	% get the file ID again
	fid1 = -1;
	fid1 = fopen([u_header,fault_file_string1,num2str(file_number)],'r','ieee-be');
	if fid1 == -1
          fprintf(1,'Error - can not open selected IQA module fault file\n')
          return
	end
	fprintf(1,'Reading %s\n',[u_header,fault_file_string1,num2str(file_number)]);
	[header1,count]  = fread(fid1,[1,21],'char');	% read the header string
	[data,count1] = fread(fid1,[1,inf],'uint16'); fclose(fid1);
	
	% make the time vector
	timeVector = linspace(0,Tsample*count1,count1);	% time vector
	
	% scale the data
	% IQA module ampitudes use bits 15:4 of the 15:0 word
	% we will divide down the data to ignore bits 3:0
	data = (fix((data-32768)/16))/2048;	% ignore lower 4 bits & scale for full scale = 1
	%out_data = fliplr(data);	% arrange from old to new data
	data = fliplr(data);
	dataLength = length(data);
	
	% Determine IQA2 version number.
	%%[status,IQA2vern] = caShell(['caget -t -w 20 ', station,':STN:IQA',IQAnum,':MODU.VERN']);
	%%if status ~=0
          %%fprintf(1,'Error - unable to read IQA version number\n');
          %%return
	%%end

	IQA2vern = '4371';
	% if IQA2vern (version number) is 4371 and mux_data for two consecutive
	% data points are different then loop through mux_data.
	
	eightChFlag = 0;
	if ( (str2num(IQA2vern) == 4371) & (mux_data ~= mux_data_compare) )
          eightChFlag = 1;
          mux_data = 1;
	end %if str2num(IQA2vern)
	
	% Fail if not set to 8 channel mode.
	if ( ~eightChFlag ), 
          fprintf('IQA module data was not in 8 channel mode.\nData for all cavities not avilable\n');
          return
	end
    out_data_cav = data(1,(cavProbeCh(thisCav)):8:dataLength);
    out_data_fwd = data(1,(cavFowrdCh(thisCav)):8:dataLength);
    out_data_rev = data(1,(cavRefleCh(thisCav)):8:dataLength);
    time = timeVector(1,(cavProbeCh(thisCav)):8:dataLength);

   for i = 1:3 %loop through muxString = {'FRWD','REFL','PROBE'};
   % read the database coupling loss scale factor
   [status,answer] = caShell(['caget -t -w 20 ', station, ':CAV' ,num2str(thisCav), muxString{i},':IQ:SCALE.A']);
   if status ~=0,  fprintf(1,'Error - unable to read coupler ratio\n'); return, end
   coupling_dB = str2num(answer);

   % read the database cable loss scale factor
   [status,answer] = caShell(['caget -t -w 20 ', station, ':CAV' ,num2str(thisCav), muxString{i} ,':IQ:SCALE.B']);  
   if status ~=0, fprintf(1,'Error - unable to read cable loss\n'); return, end
   cable_loss_dB = str2num(answer);

   % read the database fudge factor
   [status,answer] = caShell(['caget -t -w 20 ', station, ':CAV' ,num2str(thisCav), muxString{i},':IQ:SCALE.F']);
   if status ~=0, fprintf(1,'Error - unable to read fudge factor\n'); return,  end
   fudge_factor_dB = str2num(answer);

   % read the database amplitude conversion loss
   [status,answer] = caShell(['caget -t -w 20 ', station,  ':CAV' ,num2str(thisCav), muxString{i},':A:SCALE.C']);
   if status ~=0,  fprintf(1,'Error - unable to read amplitude conversion loss\n'); return, end
   ampl_conv_dB= str2num(answer);

   % calcuate the total channel conversion loss in dB
   total_dB = coupling_dB + cable_loss_dB + fudge_factor_dB + ampl_conv_dB;

   % convert to voltage scale factor
   voltage_scaling(i) = 10^(total_dB/20);
   end % for i

   % calculate the power in KW for foward and reflected signals.
   outDataFwd(thisCav,:) = ((abs(out_data_fwd)*voltage_scaling(1)*2).^2)/(100*1e3);
   outDataRev(thisCav,:) = ((abs(out_data_rev)*voltage_scaling(2)*2).^2)/(100*1e3);

   % calculate the power in KV for cavity probes
   outDataCav(thisCav,:) = ((abs(out_data_cav)*voltage_scaling(3)*2))/(1e3);

end %for thisCav

% plot the time domain response
fprintf(1,['Plotting cavity probes fast fault file #%1.0f\n'],file_number)
% increment to the next figure
figHandles = handles.figHandles;
figInd=length(figHandles);
figInd=figInd+1; figure(figInd); clf; figHandles(figInd) = figInd;

plot(time/1e-3,abs(outDataCav))
grid on
legend(cavProbeTxt(1:thisCav),0);
title(['IQA Cavity Probes Fault File - ',station,' ',' ',datetime])
xlabel('time - ms')
ylabel('gap voltage - kV')
handles.maxTime(figInd) = max(time);
handles.figHandles = figHandles;

% increment to the next figure
figHandles = handles.figHandles;
figInd=length(figHandles);
figInd=figInd+1; figure(figInd); clf; figHandles(figInd) = figInd;

subplot(211)
plot(time/1e-3,abs(outDataFwd))
grid on
legend(cavProbeTxt(1:thisCav),0);
title(['IQA Cavity Foward Power - ',station,' ',' ',datetime])
xlabel('time - ms')
ylabel('power - kW')
%handles.maxTime(figInd) = max(time);

subplot(212)
plot(time/1e-3,abs(outDataRev))
grid on
legend(cavProbeTxt(1:thisCav),0);
title(['IQA Cavity Reflected Power - ',station,' ',' ',datetime])
xlabel('time - ms')
ylabel('power - kW')
handles.maxTime(figInd) = max(time);

figure(figInd - 1)
% update system variables
%handles.tSample = Tsample;
handles.figHandles = figHandles;
handles.time = time;
handles.data = out_data_cav;
% save system variables
guidata( handles.output, handles );

return
