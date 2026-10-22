function [stations, faultNumbers, faultTimes] = getFaultNumber(station, faultTimeStr)
%function faultNum = getFaultNumber(station, faultTimeStr)
% functin to get list of fault numbers within one minute
% of the given fault time. 
% inputs
% station - used to pick ring to plot (HER or LER)
% faultTimeStr - time of fault
% output
% station - vector with station names
% faultNum - vector of fault numbers
  
% William Colocho, March 2007
switch station(1:2)
  case 'LR'
    stn = { 'LR42', 'LR43', 'LR44', 'LR45' };
  case 'HR'
    stn = { 'HR41', 'HR46','HR81', 'HR83', 'HR85', 'HR21','HR22','HR23', ...
	    'HR24','HR25', 'HR26' };
  case 'SR'
    stn = { 'SRF1' };
end

fltTime =[ datestr( datevec(faultTimeStr(1:end-8)) ), ' ',faultTimeStr(end-7:end)] ;

tevt=datenum(fltTime);
faultNumbers = [];
stations = [];
faultTimes = [];
for st=1:length(stn)
  u=[];
  for evt=1:15
    tstamp_str = lcaGet([stn{st}, ':STN:FAULT:TIME', num2str(evt)]);
    tstamp(st, evt) = datenum(tstamp_str);
    % Events within a minute
    if (abs(tstamp(st,evt)-tevt)<1/24/60);
      u = evt;
      break;
    end
  end
  if (isempty(u))
    disp(['Fault file not available for station ', stn{st}]);
  else
%    fprintf('Found station: %s, fault: %f, time: %s\n',...
%	    stn{st},u,datestr(tstamp(st,u)) )
    stations = [stations; stn{st}];
    faultNumbers = [faultNumbers, u];
    faultTimes = [faultTimes, tstamp(st,u)];
  end
end
