function stuckcomb()

%Procedure to unstick a comb. Error checking ok.
%Milanovich and Colocho, 22 Mar 03

%MOD: 13-Apr-2004, W. Colocho (colocho)
%     Added call to elogprint() to send an entry to RF elog every time this procedure gets run.

%MOD: 4-May-2003 Milanovich
%     Fix that the pauses don't work in compiled version, replacing them with inputs



%%%%%%%%%% Figure out which station is stuck!
  stationlist = ['LR43';'LR44';'LR45';'HR41';'HR81';'HR83';'HR85';'HR21';'HR23';'HR25';'HR26'];
  for i = 1:length(stationlist),
       [status,stuck]=caShell(['caget -t -w 20 ', stationlist(i,:),':STN:CFM1:INTSTATE.B8']);
       if status ~=0 
           fprintf(['Unable to read comb overflow for station ', stationlist(i,:),' module 1.\n']);
       else   
           if str2num(stuck) == 0
                fprintf(['Station ',stationlist(i,:), ' comb module 1 is OK.\n']);
           else
                fprintf(['Station ',stationlist(i,:), ' comb module 1 is STUCK.\n']);
           end
       end
       [status, stuck]=caShell(['caget -t -w 20 ', stationlist(i,:),':STN:CFM2:INTSTATE.B8']);
       if status ~= 0
           fprintf(['Unable to read comb overflow for station ', stationlist(i,:),' module 2.\n']);
       else
           if str2num(stuck) == 0
               fprintf(['Station ',stationlist(i,:), ' comb module 2 is OK.\n']);
           else
               fprintf(['Station ',stationlist(i,:), ' comb module 2 is STUCK.\n']);
           end
       end 
  end

%%%%%%%%%% Get the info
 
station = upper( input('Which station (Enter as HR25 or LR43) or Q to quit?','s') );
if station == 'Q'
	fprintf('Exiting program.\n');
        exit;
end

CFmodule = input('Which module (1 or 2)?','s');

%%%%%%%%%% Are they really ready?

fprintf('Please verify: Station %s Module %s\n',station,CFmodule);
confirm=upper(input('(y)es or (n)o?','s'));
if (confirm == 'Y' | confirm == 'YES')

%%%%%%%%%% read the Comb setting.
        
	[status,CFMsetting] = caShell(['caget -t -w 20 ', station,':STN:CFM',CFmodule ,':CMBSETSEL']);
        if status ~=0
          	fprintf(1,'Error - unable to read comb setting. Not changing anything.\n');
		input('Press return to exit.\n','s');
          	return
        end

%%%%%%%%%% read the comb loop gain
	
	[status,gain] = caShell(['caget -t -w 20 ', station,':STNCOMB:LOOP:COUNTS.A']);
        	if status ~=0
          	fprintf(1,'Error - unable to read comb loop gain. Not changing anything.\n');
          	input('Press return to exit.\n','s');
		return
        end

%%%%%%%%%% read the comb loop conversion factor

        [status,convfactor] = caShell(['caget -t -w 20 ', station,':STNCOMB:LOOP:COUNTS.E']);
                if status ~=0
                fprintf(1,'Error - unable to read comb loop conversion factor. Not changing anything.\n');
                input('Press return to exit.\n','s');
                return
        end


%%%%%%%%%% read the starting DAC counts
	
	[status,DACstartcounts] = caShell(['caget -t -w 20 ', station,':STNCOMB:LOOP:COUNTS']);
	if status ~=0
          	fprintf(1,'Error - unable to read number of DAC counts. Not changing anything.\n');
		input('Press return to exit.\n','s');
          	return
	end

        fprintf('Lowering the conversion factor to reduce the DAC counts.\n');
        fprintf('Conversion factor is %s and DAC counts is %s.\n', convfactor, DACstartcounts);

%%%%%%%%%% Output to elog

	elogTitle = ['Station ', station, ' Module ', CFmodule, ' Stuck Comb reset started'];
        elogText = [ 'Comb Set = ', CFMsetting, ', Loop Gain = ', gain,...
		     ', Conversion factor = ', convfactor, ', DAC = ', DACstartcounts];
                     
        elogprint(elogTitle,elogText,'rf','colocho'); 

%%%%%%%%%% do the main loop! first lower the conversion factor until DAC counts < 50.
	j = str2num(gain);
	k = str2num(convfactor);
	DACcurrentcounts = str2num(DACstartcounts);

	while ((DACcurrentcounts > 20) & (k > 5))
		
%		[status,answer] = caShell(['caput -w 20 ', station,':STNCOMB:LOOP:COUNTS.A ', num2str(j)]);
%		if status ~=0
%   			fprintf(1,'Error - Could not properly lower gain. Gain should be at %s. Please check!\n',gain);
%			fprintf('Not trying to clear the comb overflow.\n');
%			input('Press return to exit.\n','s');
%   			return
%		end
 		[status,answer] = caShell(['caput -w 20 ', station,':STNCOMB:LOOP:COUNTS.E ', num2str(k)]);
                if status ~=0
                        fprintf(1,'Error - Could not properly lower conversion factor. Factor should be at %s. Please check!\n',convfactor);
                        fprintf('Not trying to clear the comb overflow.\n');
                        input('Press return to exit.\n','s');                        
                        return
                end
		[status,DACreadback] = caShell(['caget -t -w 20 ', station,':STNCOMB:LOOP:COUNTS']);
        	if status ~=0
                	fprintf(1,'Error - unable to read number of DAC counts while lowering gain. \n');
			fprintf('Gain should be at %s. Please check and change as necessary! \n',gain);
  			fprintf('Conversion factor should be at %s. Please check and change as necessary! \n',convfactor);
			fprintf('Not trying to clear the comb overflow.\n');
			input('Press return to exit.\n','s');
                	return
        	end
		DACcurrentcounts = str2num(DACreadback);
                fprintf('Conversion factor is %.2f and DAC counts is %.2f.\n', k, DACcurrentcounts);
                pause(1);
                j = j-2.0;
		k = k-0.05*str2num(convfactor);
	end
%%%%%%%%%% Next really set the conversion factor to zero
	fprintf('Setting conversion factor to 0.\n');
        [status,answer] = caShell(['caput -w 20 ', station,':STNCOMB:LOOP:COUNTS.E 0']);
        if status ~=0
                  fprintf(1,'Error - Could not properly lower conversion factor. Factor should be set back to  %s. Please restore manually!\n',convfactor);
                  fprintf('Not trying to clear the comb overflow.\n')
                  input('Press return to exit.\n','s');                        
                  return
        end

%%%%%%%%%% Set the CFM to 'thru' to try to clear the setting.
	fprintf('Setting comb module to THRU mode.\n');
	[status,answer] = caShell(['caput -w 20 ', station,':STN:CFM',CFmodule, ':CMBSETSEL 3']);
                if status ~=0
                        fprintf('Error - Could not set module to THRU mode.\n');
			fprintf('No longer trying to clear comb overflow. Please recheck the overflow interrupt.\n');
			fprintf('Comb module setting should be %s and gain should be %s.\n',CFMsetting,gain);
                        fprintf('Conversion factor should be at %s. Please check and change as necessary! \n',convfactor);
			fprintf('Please manually return to these values!\n');
			input('Press return to exit.\n','s');
                        return
                end
	pause(5);

%%%%%%%%%% Set the CFM back to its original setting
	fprintf('Setting comb module to %s.\n', CFMsetting);
	[status,answer] = caShell(['caput -w 20 ', station,':STN:CFM', CFmodule,':CMBSETSEL ', CFMsetting]);
                if status ~=0
                        fprintf(1,'Error - Could not set module to original mode.\n');
                        fprintf('Comb module setting should be %s and gain should be %s.\n',CFMsetting,gain);
                        fprintf('Conversion factor should be at %s. Please check and change as necessary! \n',convfactor);
                        fprintf('Please manually return to these values!\n');
			input('Press return to exit.\n','s');
                        return
                end

%%%%%%%%%% Raise the gain back up
	fprintf('Raising the conversion factor to %s.\n',convfactor);
	while (DACcurrentcounts < 0.95*str2num(DACstartcounts))

%		[status,answer] = caShell(['caput -w 20 ', station,':STNCOMB:LOOP:COUNTS.A ', num2str(j)]);
%                if status ~=0
%                       fprintf(1,'Error - Could not properly raise gain. Gain should be at %s. Please check and raise manually!\n',gain);
%			fprintf('Overflow should be cleared. Please check.\n');
%			input('Press return to exit.\n','s');
%                       return
%                end
                [status,answer] = caShell(['caput -w 20 ', station,':STNCOMB:LOOP:COUNTS.E ', num2str(k)]);
                if status ~=0
                        fprintf(1,'Error - Could not properly raise conversion factor. It should be at %s. Please check and raise manually!\n',convfactor);
                        fprintf('Overflow should be cleared. Please check.\n');
                        input('Press return to exit.\n','s');
                        return
                end
                [status,DACreadback] = caShell(['caget -t -w 20 ', station,':STNCOMB:LOOP:COUNTS']);
                if status ~=0
                        fprintf(1,'Error - unable to read number of DAC counts while raising gain. \n');
			fprintf('DAC counts should be %s.\n',DACstartcounts);
                        fprintf('Gain should be at %s. Please check and change as necessary! \n',gain);
                        fprintf('Conversion factor should be at %s. Please check and change as necessary! \n',convfactor);
			fprintf('Overflow should be cleared. Please check.\n');
			input('Press return to exit.\n','s');
                        return
                end
		DACcurrentcounts = str2num(DACreadback);
                fprintf('Conversion factor is %.2f and DAC counts is %.2f.\n', k, DACcurrentcounts);
		j = j+2.0;
		k = k+0.05*str2num(convfactor);
        	pause(1);
	end

        [status,answer] = caShell(['caput -w 20 ', station,':STNCOMB:LOOP:COUNTS.E ', convfactor]);
        if status ~=0
                        fprintf(1,'Error - Could not properly raise conversion factor. It should be at %s. Please check and restore manually!\n',convfactor);
                        fprintf('Overflow should be cleared. Please check.\n');
                        input('Press return to exit.\n','s');
                        return
        end

        [status,DACreadback] = caShell(['caget -t -w 20 ', station,':STNCOMB:LOOP:COUNTS']);
                if status ~=0
                        fprintf(1,'Error - unable to read number of DAC counts while raising gain. \n');
			fprintf('DAC counts should be %s.\n',DACstartcounts);
                        fprintf('Gain should be at %s. Please check and change as necessary! \n',gain);
                        fprintf('Conversion factor should be at %s. Please check and change as necessary! \n',convfactor);
			fprintf('Overflow should be cleared. Please check.\n');
			input('Press return to exit.\n','s');
                        return
                end
	DACcurrentcounts = str2num(DACreadback);
        fprintf('Conversion factor is %.2f and DAC counts is %.2f.\n', str2num(convfactor), DACcurrentcounts);

%%%%%%%%%%% Never expect to get here. If so, something strange has happened while changing gain.
	if (DACcurrentcounts - str2num(DACstartcounts) > 0.5)
		fprintf('An error has occurred: DAC counts was %s, now is %f!\n',DACstartcounts, DACcurrentcounts);
		fprintf('Comb overflow should be cleared. Gain was %s when starting, please check!\n',gain);
		fprintf('Conversion factor was %s when starting. Please check!\n',convfactor);
		input('Press return to exit.\n','s');
      
	else 
            for i = 1:length(stationlist),
                 [status,stuck]=caShell(['caget -t -w 20 ', stationlist(i,:),':STN:CFM1:INTSTATE.B8']);
                 if str2num(stuck) == 0
                      fprintf(['Station ',stationlist(i,:), ' comb module 1 is OK.\n']);
                 else
                      fprintf(['Station ',stationlist(i,:), ' comb module 1 is STUCK.\n']);
                 end
                 [status, stuck]=caShell(['caget -t -w 20 ', stationlist(i,:),':STN:CFM2:INTSTATE.B8']);
                 if str2num(stuck) == 0
                         fprintf(['Station ',stationlist(i,:), ' comb module 2 is OK.\n']);
                 else
                         fprintf(['Station ',stationlist(i,:), ' comb module 2 is STUCK.\n']);
                 end
            end
       fprintf('Script ran successfully. Overflow should be cleared.\n')
       input('Press return to exit.\n','s');	
       end

else fprintf('Aborting execution! Nothing changed.\n');
end


return
