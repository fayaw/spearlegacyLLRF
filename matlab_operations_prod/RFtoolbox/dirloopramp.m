function dirloopramp(station, gain, phase)
% function dirloopramp(station, gain, phase)
% dirloopramp ramps the direct loop configuration to a destination,
% it ramps the amplitude in steps of 0.1dB, with 1 second pauses, and ramps
% the phase in equally spaced increments.
% it returns when the phase is within tolerance
% if the gain is already within 0.1dB of its final value, and only the
% phase needs to be changed, then the move is made in one step and the
% phase ramp is taken care of by the llrf
% station rf station
% gain    final direct loop gain
% phase   final direct loop phase

pvNamesDirLoop = {
    [station, ':STNDIRECT:LOOP:COUNTS.A']  % loop gain
    [station, ':STNDIRECT:LOOP:PHASE.C']   % loop phase
    };
pvNameDirLoopPhaseReadbacks = {
    [station, ':STNDIRECT:LOOP:PHASE']     % total phase
    [station, ':STNDIRECT:LOOP:PHASE.K']   % freq offs del phase
    };

% get current values
initValues = lcaGet( pvNamesDirLoop );
currGain = initValues(1);
currPhase = initValues(2);
% maximum allowable step sizes
gainStep = 0.1;
phaseStep = 5;
% find the axis with the larger movement
relGainDiff = (gain - currGain)/gainStep;
relPhaseDiff = (phase - currPhase)/phaseStep;
if ((abs(relGainDiff) <= 1) && (abs(relPhaseDiff) <= 1)),
    % if the total motion is within the step size, move immediately
    lcaPut(pvNamesDirLoop,[gain; phase]);
else
    if (abs(relGainDiff) > abs(relPhaseDiff)),
        % delta gain sets the number of steps
        [gainRamp, phaseRamp] = ...
            buildRamps( gain, currGain, gainStep, ...
            phase, currPhase);
    else
        % delta phase sets the number of steps
        [phaseRamp, gainRamp] = ...
            buildRamps( phase, currPhase, phaseStep, ...
            gain, currGain);
    end % (abs(relGainDiff) > abs(relPhaseDiff)),
    % output ramp of values
    for i1 = 1:length(gainRamp),
        lcaPut(pvNamesDirLoop,[gainRamp(i1); phaseRamp(i1)]);
        pause(1);
    end % for i1 = length(gainRamp),
end % if ((abs(relGainDiff) <= 1) && (abs(relPhaseDiff) <= 1)),

% pause until phase is within 1 degree of goal
fprintf(1,'waiting for total system phase\n');
phaseReadbacks = lcaGet(pvNameDirLoopPhaseReadbacks);
while (abs(phaseReadbacks(1)-phaseReadbacks(2) - phase) >= 1)
    pause(1);
    phaseReadbacks = lcaGet(pvNameDirLoopPhaseReadbacks);
end % while (abs(phaseReadbacks(1)-phaseReadbacks(2) - phase) >= 1)

return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [xRamp, yRamp] = buildRamps( x, x0, dx, y, y0 )
% buildRamps builds two equally sized ramps
% the length of the ramps is determined by the x argument
% the y vector is created to be the same size

% create x ramp based on the size of dx
lenRamp = ceil(abs(x - x0)/dx);
delX = (x - x0)/lenRamp;
xRamp = (x0 + delX):delX:x;
lenRamp = length(xRamp);
if y ~= y0,
    delY = (y - y0)/lenRamp;
    yRamp = (y0 + delY):delY:y;
else
    yRamp = y*ones(1,lenRamp);
end % if y ~= y0,
return
end
