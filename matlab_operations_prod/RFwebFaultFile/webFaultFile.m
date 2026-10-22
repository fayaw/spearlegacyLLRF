function webFaultFile()

% webFaultFile() will compare web .jpg file dates with faultFile file dates.
% If a new fault file exist for a given station.  
%The data is processed and a new .jpg is created

eventdata = [];
hObject = figure(100);
stationName = 'LR43';
machine = stationtomachine( stationName );

prm = sys_prm(machine);

rfFrequency =  prm.accel.wrf / (2 * pi);
harmonicNumber =  prm.accel.h;
samplesPerRev =  prm.rf.hcomb;
%rfData = prm.files.rf_data;
rfData = '/nfs/mccfs0/u1/pepii/llrf/' ;      %Needed to run on slcs1
rfFrequencyMHz = rfFrequency/1e6;

handles = struct( 'output', hObject, ...  % pointer to figure window
    'rfData', rfData, ...                 % directory that contains the files
    'station',stationName, ...                 % rf station under investigation
    'idAction', 1, ...                    % id of plotting routine
    'labAction', 'RFP Cavity', ...        % label of plotting command
    'fftFlag', 0, ...                     % yes/no flag to calculate fft 
    'samplingFrequency', (rfFrequencyMHz*samplesPerRev)/harmonicNumber, ... % Module sampling frequency in MHz.
    'Tsample', 1/((samplesPerRev*rfFrequency)/harmonicNumber), ...               % sample period for one revolution
    'nTurns', inf, ...                    % number of turns to plot
    'figHandles', [], ...                 % number of figures that are plotted
    'fftFigHandles',[], ...               % number of figures that plot FFTs
    'time', [], ...                       % time vector (abscissa) of data
    'data', [], ...                       % matrix of data (ordinate) to plot
    'faultNumber', 1 );                   % fault file number to plot.
% Update handles structure
    guidata(hObject, handles);

webDir = ['/afs/slac.stanford.edu/www/grp/ad/op/PEPIIFaultFiles/'];
stationList = ['LR43'; 'LR44'; 'LR45'; 'HR41'; 'HR81'; ...
               'HR83'; 'HR85'; 'HR21'; 'HR23';'HR25' ;'HR26'];

iocList = ['rfs04ler03/'; 'rfs04ler04/'; 'rfs04ler05/'; 'rfs04her01/'; ...
                  'rfs08her01/'; 'rfs08her03/'; 'rfs08her05/'; 'rfs12her01/'; ...
		  'rfs12her03/'; 'rfs12her05/'; 'rfs12her06/' ];

stationCount = length( stationList );

faultFileNameList = {'FAULTAim_'; 'FAULTGvf_'; 'FAULTRfpCI_'; 'FAULTRfpSQ_'; ...
		'FAULTCmbI_'; 'FAULTIqa1Amp_'; 'FAULTRfpCQ_'; ...
		'FAULTCmbQ_'; 'FAULTIqa2Amp_'; 'FAULTRfpSI_'}; % Not yet used

jpegFileNameList = {'FAULTRfpC'; 'FAULTRfpS'; 'FAULTCmb'; 'FAULTGvf'; ...
		    'FAULTIqa1'; 'FAULTIqa2'; 'FAULTIqa3'}; % Noy yet used


%while (1)  %Loop forever one station directory at a time.

for thisSt = 1:stationCount   
   
      thisStation = stationList(thisSt,:)
      rfsDir = ['/nfs/mccfs0/u1/pepii/ctrl/', iocList(thisSt,:) ];
      handles.station = thisStation;

      % determine if the station is 4 cavities or 2 cavities
      [status,answer] = caShell(['caget -t -w 20 ', handles.station,':STN:NCV:PLC']);
      if status ~=0
         fprintf(1,'Error - unable to read number of cavities\n');
      return
      end
      if strcmp (answer(1:3),'4CV' ) == 1
         num_cavities = 4;
      elseif strcmp (answer(1:3),'2CV' ) == 1
         num_cavities = 2;
      else
         fprintf(1,'Error - incorrect number of cavities - not 4CV or 2CV\n');
         return
      end %if strcmp

% Look at fault File directory for this station and decide if there is a new file to process.

      faultDir = dir([rfsDir,'FAULTRfpCI_*']);   % faultDir is a structure with fault directory information.
                                                   % Look at one file to decide if it is newer that the web files.
      for j = 1 : length(faultDir);
         thisFile = faultDir(j).name
         barIndex = findstr('_',thisFile);
         faultNumStr = thisFile(barIndex + 1:length(thisFile));
         handles.faultNumber = num2str(faultNumStr);
         thisFileJpeg = dir([webDir, iocList(thisSt,:), 'FAULTRfpC_',faultNumStr,'_A.jpg']); 
         if ( length(thisFileJpeg) == 0 )
            fprintf('There is something wrong: Call William (thisFileJpeg does not exist?)\n');
            return
         end % thisFileJpeg == 0 ? 
 %%%Need to change < to >.
         if ( datenum(faultDir(j).date) > datenum(thisFileJpeg.date) ) %We have a new fault file set.
 
            [status, result] =caShell(['rm ', webDir, iocList(thisSt,:) ,'/tempFile ']);
            if (status ~= 0)
               fprintf('Failed to remove tempFile %s \n', [iocList(thisSt,:) ,'/tempFile ']);
            end 
%%%disp('before fopen'),keyboard;  
            fileId = fopen([webDir, iocList(thisSt,:) ,'/tempFile'],'w');

            handles.figHandles = []; % Reset figHandels so we only print the new figures on the next pass.
            plot_RFP_cavity(hObject, eventdata, handles);
            handles = guidata(handles.output);
            printJpegFile( hObject, eventdata, handles, ... 
                          [webDir, iocList(thisSt,:)], ['FAULTRfpC_', faultNumStr], fileId );
%if (0)
            handles.figHandles = []; % Reset figHandels so we only print the new figures on the next pass.
            plot_RFP_signal(hObject, eventdata, handles); 
            handles = guidata(handles.output);
            printJpegFile( hObject, eventdata, handles, ...
                          [webDir, iocList(thisSt,:)], ['FAULTRfpS_', faultNumStr], fileId );

            handles.figHandles = []; % Reset figHandels so we only print the new figures on the next pass.
            plot_COMBS(hObject, eventdata, handles);
            handles = guidata(handles.output);
            printJpegFile( hObject, eventdata, handles, ...
                           [webDir, iocList(thisSt,:)], ['FAULTCmb_', faultNumStr], fileId );
            
            handles.figHandles = []; % Reset figHandels so we only print the new figures on the next pass.
            plot_GAP(hObject, eventdata, handles);
            handles = guidata(handles.output);
            printJpegFile( hObject, eventdata, handles, ...
                           [webDir, iocList(thisSt,:)], ['FAULTGvf_', faultNumStr], fileId );

            handles.figHandles = []; % Reset figHandels so we only print the new figures on the next pass.
            plot_IQA1(hObject, eventdata, handles);
            handles = guidata(handles.output);
            printJpegFile( hObject, eventdata, handles, ...
                           [webDir, iocList(thisSt,:)], ['FAULTIqa1_', faultNumStr], fileId );

            handles.figHandles = []; % Reset figHandels so we only print the new figures on the next pass.
            plot_IQA2(hObject, eventdata, handles);
            handles = guidata(handles.output);
            printJpegFile( hObject, eventdata, handles, ...
                           [webDir, iocList(thisSt,:)], ['FAULTIqa2_', faultNumStr], fileId );

            if (num_cavities == 4)
               handles.figHandles = []; % Reset figHandels so we only print the new figures on the next pass.
               plot_IQA3(hObject, eventdata, handles);
               handles = guidata(handles.output);
               printJpegFile( hObject, eventdata, handles, ...
                              [webDir, iocList(thisSt,:)], ['FAULTIqa3_', faultNumStr], fileId );
            end % if num_cavities == 4
%end %if 0          
         end %if new fault file set   
%%%disp('before if exist fileId'); keyboard
         if exist('fileId')
            fclose(fileId); clear('fileId') %Close the file and clear the variable.
            [status, result] = caShell(['cp ',webDir, iocList(thisSt,:) ,'tempFile ', ... 
                                       webDir, iocList(thisSt,:),'faultFile_', faultNumStr,'.html']);
            if (status ~= 0)
               fprintf('Failed to copy  %s to %s \n', [webDir, iocList(thisSt,:) ,'/tempFile '], ...
                       [webDir, iocList(thisSt,:) ,'tempFile fautlFile_', faultNumStr,'.html']);
            else
	       fprintf(['Saved File: ',webDir, iocList(thisSt,:) ,'fautlFile_', faultNumStr,'.html']) 
            end %if status
	 end % if exist(fileId) 
         
      end %for faultDir- Done with this fault directory file list. All files have been checked.    
   end % for thisSt - Done with all station 
%   pause(600); % pause 10 minutes.
%end % while loop forever.  
disp('Done with all loops')
return



function printJpegFile(hObject, eventdata, handles, fileDir,fileName, fileId)

% prints figToPrint figures to files. figToPrint is a vector with figure handles.(i.e.: [1 2 3 4])

figToPrint = handles.figHandles;
charA = 64;
for k = 1 : length(figToPrint)
   figNumber = figToPrint(k) ; 
   print(figNumber, '-djpeg', '-r65', [ fileDir, fileName, '_', char(charA+k)]);
   fprintf(fileId,['<img src="',fileName, '_', char(charA+k), '.jpg">']);
   disp(['Saved file: ', fileDir, fileName, '_', char(charA+k),'.jpg'])  
end %for figToPrint

return
