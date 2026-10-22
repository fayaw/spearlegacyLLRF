function loadrfstates( rf_module )
% function loadrfstates( rf_module )
% loadrfstates resets and loads the rf state with the necessary delays
% to insure both states are recognized
%
% rf_module    prefix before state, such as SRF1:STN:RFP

pauseTime = 0.1;

% place the module in Reset mode
try
    lcaPut([rf_module,':STATE'], 0);
    % force a wait to insure module goes through this state
    pause(pauseTime);
catch
    fprintf(1,'Error - can not place RF module in Reset state\n');
    return
end

% place the module in Load mode
try
    lcaPut([rf_module,':STATE'], 1);
    % force a wait to insure module goes through this state
    pause(pauseTime);
catch
    fprintf(1,'Error - can not place RF module in Load state\n');
    return
end

return
end