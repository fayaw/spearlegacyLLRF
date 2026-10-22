function cyclerfstates( rf_module )
% function cyclerfstates( rf_module )
% cyclerfstates runs the data taking mode through the appropriate state
% sequence, with the necessary delays to insure all states are recognized
%
% rf_module    prefix before state, such as SRF1:STN:RFP

pauseTime = 0.1;

% place the module in Reset mode
try
    lcaPut([rf_module,':STATE'], 0);
    % force a wait to insure module goes through this state
    pause(pauseTime);
catch MEcycleStates
    fprintf(1,'Error - can not place RF module in Reset state\n');
    return
end

% place the module in Load mode
try
    lcaPut([rf_module,':STATE'], 1);
    % force a wait to insure module goes through this state
    pause(pauseTime);
catch MEcycleStates
    fprintf(1,'Error - can not place RF module in Load state\n');
    return
end

% take a single shot of data - go to run mode
fprintf(1,'Taking a single shot of data\n');
try
    lcaPut([rf_module,':STATE'], 2);
    % force a wait to insure module goes through this state
    pause(pauseTime);
catch MEcycleStates
    fprintf(1,'Error - can not place RF module in Run state\n');
    return
end

% place the module in Load mode
try
    lcaPut([rf_module,':STATE'], 1);
    % force a wait to insure module goes through this state
    pause(pauseTime);
catch MEcycleStates
    fprintf(1,'Error - can not place RF module in Load state\n');
    return
end

return
end