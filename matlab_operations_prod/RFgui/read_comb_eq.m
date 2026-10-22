% read_comb_eq     - Reads comb equalizer coefficient file
%
% function Beq = read_comb_eq(handles)
%

function Beq = read_comb_eq(handles);

% Read equalizer coefficients
% read the comb IIR coeffieient file
station = handles.station;
rf_tbl = handles.tableDir; % '/u1/pepii/llrf/tbl';
EQ_file_HER = ['/detunEqHER.tbl']; % define COMB equalizer files - HER
EQ_file_LER = ['/detunEqLER.tbl']; % define COMB equalizer files - LER
if (station(1)=='L')
  file = EQ_file_LER;
else
  file = EQ_file_HER;
end

fid = fopen([rf_tbl, file],'r');
if (fid == -1)
  error(['Cannot read equalizer coefficient file ', rf_tbl, file]);
end
% read the IIR coefficient file header
[header] = fgetl(fid);
% read the measured data files
[Beq, count] = fscanf(fid,'%f'); fclose(fid);
