function [status, answer] = caShell( actionStr )

% CASHELL Parse actionStr and execute lcaGet() or lcaPut() call.
%    [STATUS, ANSWER] = caShell ( actionStr )
% actionStr is of the format [<cmd> -t -w <wait> <pv> <putValue>]
% the -t -n options are ignored.
%  
% Example calls:
%  
% [status,answer] = caShell(['caput -w 20 ', rf_module,':DACS 0']);
% [status,answer] = caShell(['caget -t -w 20 ', rf_module,':MODU.CQST']); 

status = 0;
answer = [];
wait = '20';
nFlag = 0;

[cmd remainderStr] = strtok(actionStr);
[optFlag remainderStr] = strtok(remainderStr);

while ( findstr('-',optFlag) )
  switch optFlag					     
   case '-w'
    [wait remainderStr]= strtok(remainderStr);
    break; %gets out of loop; assumes -w is last flag.
   case '-t'  %just get the next option 
    [optFlag remainderStr] =  strtok(remainderStr);
   case '-s'  %just get the next option 
    [optFlag remainderStr] =  strtok(remainderStr);
   case '-n'
    nFlag = 1;
    [optFlag remainderStr] =  strtok(remainderStr);
   otherwise
    fprintf(1,'Error from caShell_lca call: option %s not defined\n',optFlag)
    return
  end 
end %while
wait = str2num(wait);


[pv remainderStr] = strtok(remainderStr);
pv = cellstr(pv);
[putValue remainderStr] = strtok(remainderStr); %removes leading space.
putValue = [putValue, deblank(remainderStr)];

% Begin lcaAction
prev_retryCount = lcaGetRetryCount;
new_retryCount = ceil(wait/lcaGetTimeout);
if (new_retryCount > prev_retryCount) 
	lcaSetRetryCount(new_retryCount);
end
try
switch (cmd)
 case 'caget'
  if nFlag
    getResult = lcaGet(pv,0,'double');
  else
    getResult = lcaGet(pv);
  end %if nFlag
  
  %convert getResult to string if it's numeric or cell
   if iscell(getResult); 
     answer = char(getResult); 
   elseif isnumeric(getResult);
     answer = num2str(getResult);
   else
     answer = getResult;
  end %if iscell()
 
 case 'caput' 
    lcaPut(pv, putValue);
 otherwise
  status = 1;
  
end %switch
catch
	fprintf(1, 'Error from lca call: command %s\n',cmd);
	status = 1;
end %try
lcaSetRetryCount(prev_retryCount);
% End of lcaAction

