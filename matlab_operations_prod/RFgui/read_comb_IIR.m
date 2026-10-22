function [num0, num1, den1, den2] = read_comb_IIR(handles);

% Read IIR coefficients
% read the comb IIR coeffieient file
station = handles.station;
rf_tbl = handles.tableDir; %'/u1/pepii/llrf/tbl';
IIR_file_HER = ['/cfmIirCoefsHER.tbl']; % define COMB IIR files - HER
IIR_file_LER = ['/cfmIirCoefsLER.tbl']; % define COMB IIR files - LER
if (station(1)=='L')
  IIR_file = IIR_file_LER;
else
  IIR_file = IIR_file_HER;
end

fid = fopen([rf_tbl,IIR_file],'r');
if (fid == -1)
  error(['Cannot read IIR coefficient file ', rf_tbl, IIR_file]);
end
% read the IIR coefficient file header
[header] = fgetl(fid);
% read the measured data files
[IIR_coeffs, count] = fscanf(fid,'%f'); fclose(fid);
% parse into the individual coefficients
% compensate for /2 scaling used in actual hardware
% because hardware coeffs are limited to -1.0 < X < 1.0
% and invert denominator coeffs
den2 = IIR_coeffs(1:4)*(-2);
den1 = IIR_coeffs(5:8)*(-2);
num1 = IIR_coeffs(9:12);
num0 = IIR_coeffs(13:16);
