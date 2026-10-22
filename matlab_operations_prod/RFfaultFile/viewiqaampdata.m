function viewiqaampdata(moduleNumber)
% function viewiqaampdata(moduleNumber)
% acquires data from IQA modules
% currently supported fo IQA2 and IQA3, not yet IQA1

pvLoad = sprintf('SRF1:STN:IQA%d:MODU.GAHS', moduleNumber);
pvStatus = sprintf('SRF1:STN:IQA%d:MODU.ASTT', moduleNumber);
readyStatus = 0;
undefinedStatus = 17;
% set monitor for status flag
lcaSetMonitor(pvStatus, 1, 'int');
% clear initial monitor value
monStatus = waitformonitor(pvStatus, readyStatus);
if (monStatus ~= readyStatus),
    fprintf(1, 'monitor ended with %d, not %d\n', monStatus, readyStatus);
    return
end % if (monStatus ~= readyStatus),

% initiate data acquisition
lcaPutNoWait(pvLoad, 1);

% wait for monitor change 
monStatus = waitformonitor(pvStatus, undefinedStatus);
if (monStatus ~= undefinedStatus),
    fprintf(1, 'monitor ended with %d, not %d\n', ...
        monStatus, undefinedStatus);
    return
end % if (monStatus ~= undefinedStatus),
% wait for ready
monStatus = waitformonitor(pvStatus, readyStatus);
if (monStatus ~= readyStatus),
    fprintf(1, 'monitor ended with %d, not %d\n', monStatus, readyStatus);
    return
end % if (monStatus ~= readyStatus),

% pause to ensure that file closes
pause(1);
% plot data
plot_IqaAmpHistory(moduleNumber);

lcaClear;
return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [monStatus] = waitformonitor(pvStatus, desStatus)
pauseTime = 0.1;
maxWait = 100;
indWait = 0;
monStatus = lcaGet(pvStatus,  1, 'int');
while ((monStatus ~= desStatus) && (indWait < maxWait)),
    indWait = indWait + 1;
    pause(pauseTime);
    monStatus = lcaGet(pvStatus, 1, 'int');
end % while ((monStatus ~= desStatus) && (indWait < maxWait)),
if (monStatus == desStatus),
    return
else
    monStatus = -1;
    return
end % if (monStatus == desStatus),
end