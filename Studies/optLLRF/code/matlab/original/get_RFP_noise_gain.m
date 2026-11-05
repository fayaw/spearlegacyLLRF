function gainFactor = get_RFP_noise_gain(station)
% hObject    handle to loadDataPb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% get_RFP_noise_gain(station)  - Returns gain for a given station
  
% MOD:
% J. Sebek  07/14/2008  Changed gain factor for SPEAR from 1 to 10 because
%                       SPEAR changed to the standard RFP module with the
%                       hardware noise gain that was x10 smaller than
%                       the previous version
station=upper(station);
file = '';
hostMachine = getenv('HOST');

if station == 'SRF1'
  gainFactor = 10;
  return
elseif strncmpi(hostMachine,'slcsun1',7)
   file = ['/afs/slac.stanford.edu/g/cd/soft/ref/epics/iocBoot/', ...
	    'tbl/rfp_noise_gain'];
  else    
  file='/u1/pepii/llrf/tbl/rfp_noise_gain';
end

fid=fopen(file, 'r');

s = fgets(fid);
while (s ~= -1)
  if (~isempty(strfind(s, station)))
    gainFactor = sscanf(s(strfind(s, ' '):end), ' %g');
    fclose(fid);
    return
  end
  s = fgets(fid);
end
fclose(fid);
error(['Station ', station, ' not found in file ', file]);
 
 return
