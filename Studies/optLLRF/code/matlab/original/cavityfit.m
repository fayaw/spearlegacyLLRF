function [params, fitData] = cavityfit( w, data, wRf )
% function [params, fitData] = cavityfit( w, data, wRf )
% cavityfit fits the resonator with a delay length for llrf 
%  routines
% cavityfit first estimates the cavity amplitude parameters
%  the data near the center frequency is excluded, since it
%   can be rather noisy
%   the 2*excludeIndSize-1 center data points are excluded
%    currently excludeIndSize=8
%    this exclusion eliminates +/- 7.5kHz of data from the set
%    the single-sided 3dB points are about 35kHz from the center
%  the peak of the magnitude of the valid data points is the first
%   estimate of the center frequency
%   the function magParamEstimate fits the log of the magnitude
%    of 2*+1 data points around this peak
%    from the three parameters of a quadratic fit, an estimate
%     of w0, Q0, and R0 is made
% the phase offset is then estimated using phaParamEstimate
%  the same data points used to fit the magnitude are used to find
%   the phase
%  the angle of this data is unwrapped and fit with a line
%  the angle at the estimated center frequency is calculated from
%   this fit
% the linear phase delay is estimated with a fixed value
% the results of these fits are then the initial conditions for
%  the final fit of all five parameters
%
% w         radian frequency vector (1e6) corresponding to the data
% data      input complex data set to be fit
% wRf       station design radian center frequency (1e6)
% params    vector of cavity parameters
%           params(1) = w0 (1e6)
%           params(2) = Q
%           params(3) = R
%           params(4) = tauDelay (ns)
%           params(5) = phi (w.r.t. wRf) (degrees)
%           params(6) = resnorm
% fitData   vector of best fit data using params
%
% 2008-jul-29 jjs
%  scale residual norm from lsqcurvefit with fitted amplitude (xTot(3))
%  when determining goodness of fit

% disable/enable debugging
debugOn = 0;
% debugOn = 1;

filLen = 4;
b=ones(1,filLen)/filLen;
data = filtfilt(b,1,data);
% create vector of real and imaginary parts of data for lsqcurvefit
complexData = [real(data(:)); imag(data(:))];

% indices of data to exclude
excludeIndSize = 8;

% value of resnorm that indicates a bad fit
maxGoodResnorm = 200;

radToDeg = 180/pi;

% exclude outliers near center of plot
lenData = length(data);
midIndex = round( lenData/2 );
lowInd = 1:(midIndex-excludeIndSize);
highInd = (midIndex+excludeIndSize):lenData;
lenLowInd = length(lowInd);
lenHighInd = length(highInd);
dataInd = [lowInd highInd];
lenDataRed = lenLowInd + lenHighInd;

% reduced vectors
wRed = w(dataInd);
dataRed = data(dataInd);
realDataRed = real(dataRed);
imagDataRed = imag(dataRed);
complexDataRed = [realDataRed(:); imagDataRed(:)];

% use quadratic fit around peak to find w0,Q0,R0
[x0Mag, magEstInd] = magParamEstimate( wRed, dataRed );
% use linear fit around peak to find phase
x0Phi = phaParamEstimate( wRed(magEstInd), dataRed(magEstInd), x0Mag(1) );
% reasonable estimate
x0Tau = 550;

x0Tot = [x0Mag x0Tau x0Phi];

if (~isreal(x0Tot(2))),
    fprintf(1, '\nEstimated loaded cavity Q is %f', x0Tot(2));
    fprintf(1, '\nEstimated curvature is negative rather than positive\n');
    fprintf(1, 'data is unreliable  Q forced to 7000\n');
    x0Tot(2) = 7000;
end % if (~isreal(x0Tot(2)),

fprintf(1,'\n Estimated cavity frequency is %7.4f MHz\n',x0Tot(1)/(2*pi));
fprintf(1,' Estimated loaded cavity Q is %4.0f\n',x0Tot(2));
fprintf(1,' Estimated loop gain is %3.1f volts/volt\n',x0Tot(3));
fprintf(1,' Default system delay is %3.0f ns\n',x0Tot(4));
fprintf(1,' Estimated phase shift at resonance peak is %3.0f degrees\n', ...
    x0Tot(5)*(180/pi));

% set options for fitting
maxIter = 240;
if debugOn,
    options = optimset( 'Display' , 'iter', 'TolFun', 1e-6, ...
        'MaxIter', maxIter, 'MaxFunEvals', 6*maxIter);
else
    options = optimset( 'Display' , 'final', 'TolFun', 1e-6, ...
        'MaxIter', maxIter, 'MaxFunEvals', 6*maxIter);
end
% bounds on fit
wDel = 2*pi*0.1; % 1e6 rad/sec
qDel = 4000;
qMin = 4000;
rDelRatio = 2.0;
tauDel = 400;
phiDel = pi/4;

% fit total function
lb = [x0Tot(1)-wDel, min(qMin,x0Tot(2)-qDel), x0Tot(3)/rDelRatio, ...
    x0Tot(4)-tauDel, x0Tot(5)-phiDel];
ub = [x0Tot(1)+wDel, x0Tot(2)+qDel, x0Tot(3)*rDelRatio, ...
    x0Tot(4)+tauDel, x0Tot(5)+phiDel];
[xTot, resnorm, residual, exitflag, output] = ...
    lsqcurvefit(@cavityTotalFit, x0Tot, wRed, complexDataRed, ...
    lb, ub, options, x0Tot(1));
if ( exitflag == 0 ),
    warning( 'total fit did not converge' );
end % if ( exitflag == 0 ),
fprintf(1,'  total cavity fit\n');
fprintf(1,['   resnorm = %8.3f\n   iterations = %3d; funcCount = %4d;', ...
    ' cgiIter = %3d; firstOrderOpt = %f\n'], ...
    resnorm, output.iterations, output.funcCount, ...
    output.cgiterations, output.firstorderopt );
fprintf(1,' Fitted phase shift at resonance peak is %3.0f degrees\n', ...
    xTot(5)*(180/pi));
% retry fit if scaled resnorm too large by changing initial phase by pi
if resnorm/xTot(3) >= maxGoodResnorm,
    xTotOrig = xTot;
    resnormOrig = resnorm;
    if x0Tot(5) < 0,
        x0Tot(5) = x0Tot(5) + pi;
    else
        x0Tot(5) = x0Tot(5) - pi;
    end % if x0Tot(5) < 0,
    fprintf(1,'  Original fit is\n');
    fprintf(1,'  Fitted cavity frequency is %7.4f MHz\n',xTotOrig(1)/(2*pi));
    fprintf(1,'  Fitted loaded cavity Q is %4.0f\n',xTotOrig(2));
    fprintf(1,'  Fitted loop gain is %3.1f volts/volt\n',xTotOrig(3));
    fprintf(1,'  Fitted system delay is %3.0f ns\n',xTotOrig(4));
    fprintf(1,'  Fitted phase shift is %3.0f degrees\n',xTotOrig(5)*(180/pi));
    fprintf(1, 'rerunning fit with initial phase = %3.0f degrees\n', ...
        x0Tot(5)*(180/pi));
    lb = [x0Tot(1)-wDel, min(qMin,x0Tot(2)-qDel), x0Tot(3)/rDelRatio, ...
        x0Tot(4)-tauDel, x0Tot(5)-phiDel];
    ub = [x0Tot(1)+wDel, x0Tot(2)+qDel, x0Tot(3)*rDelRatio, ...
        x0Tot(4)+tauDel, x0Tot(5)+phiDel];
    [xTot, resnorm, residual, exitflag, output] = ...
        lsqcurvefit(@cavityTotalFit, x0Tot, wRed, complexDataRed, ...
        lb, ub, options, x0Tot(1));
    if ( exitflag == 0 ),
        warning( 'total fit did not converge' );
    end % if ( exitflag == 0 ),
    fprintf(1,'  second total cavity fit\n');
    fprintf(1,['   resnorm = %8.3f\n   iterations = %3d; funcCount = %4d;', ...
        ' cgiIter = %3d; firstOrderOpt = %f\n'], ...
        resnorm, output.iterations, output.funcCount, ...
        output.cgiterations, output.firstorderopt );
    fprintf(1,' Fitted phase shift at resonance peak is %3.0f degrees\n', ...
        xTot(5)*(180/pi));
    if (resnorm > resnormOrig),
        fprintf(1, 'first fit was better\n');
        xTot = xTotOrig;
        resnorm = resnormOrig;
    end % if (resnorm > resnormOrig),
end % if resnorm >= maxGoodResnorm,
    

% shift phase offset point to wRf
%  from cavitySysFun, phasor to add to phase of cavity is
%   exp(-j*(w-wRf)*Td*1e-3)*exp(j*offset)
%   offsetOld + wRfOld*Td*1e-3 = offsetNew + wRfNew*Td*1e-3
%   offsetNew = offsetOld + (wRfOld - wRfNew)*Td*1e-3
xTot(5) = xTot(5) + (x0Tot(1) - wRf)*xTot(4)*1e-3;

% output arguments
params = [xTot resnorm];
fitData = cavitySysFun( params, w, wRf );

if debugOn,
    % take log to get amplitude and phase
    cavMagnitude = 20*log10(abs(data));
    cavPhase = angle(data);

    % constants for filtering function
    [Bm,Am] = butter(3,0.025);
    % filter log(data)
    filteredCavMagnitude = filtfilt( Bm, Am, cavMagnitude );
    [maxMag, maxMagIndex] = max(filteredCavMagnitude);

    cavMagnitudeRed = cavMagnitude(dataInd);
    cavPhaseRed = cavPhase(dataInd);
    cavFitFull = cavityFun( x0Mag, w );

    figInd=100;
    figInd=figInd+1; figure(figInd); clf;
    fStart = (w(1)  - wRf)/(2*pi)*1e3;
    fStop  = (w(end)- wRf)/(2*pi)*1e3;
    subplot(2,1,1);
    plot((w-wRf)/(2*pi)*1e3, cavMagnitude, 'r', ...
        (wRed-wRf)/(2*pi)*1e3, cavMagnitudeRed, 'c.', ...
        (w-wRf)/(2*pi)*1e3, filteredCavMagnitude);
    v = axis; axis([fStart fStop v(3:4)]);
    title('cavity magnitude and first estimate');
    ylabel('log magnitude');
    grid on;
    subplot(2,1,2);
    plot((w-wRf)/(2*pi)*1e3, radToDeg*cavPhase, 'r', ...
        (wRed-wRf)/(2*pi)*1e3, radToDeg*cavPhaseRed, 'c.');
    v = axis; axis([fStart fStop v(3:4)]);
    title('cavity phase');
    xlabel('frequency (kHz)');
    ylabel('radians');
    grid on;

    figInd=figInd+1; figure(figInd); clf;
    subplot(2,1,1);
    plot((w-wRf)/(2*pi)*1e3, cavMagnitude, 'r', ...
        (w-wRf)/(2*pi)*1e3, 20*log10(abs(cavFitFull)), 'g', ...
        (w-wRf)/(2*pi)*1e3, 20*log10(abs(fitData)));
    v = axis; axis([fStart fStop v(3:4)]);
    title('cavity magnitude and final fit');
    ylabel('log magnitude');
    legend('raw data', 'magnitude fit', 'final fit');
    grid on;
    subplot(2,1,2);
    plot((w-wRf)/(2*pi)*1e3, cavPhase, 'r', ...
        (w-wRf)/(2*pi)*1e3, angle(cavFitFull.*exp(i*x0Phi)), 'g', ...
        (w-wRf)/(2*pi)*1e3, angle(cavitySysFun(x0Tot, w, x0Tot(1))), 'c', ...
        (w-wRf)/(2*pi)*1e3, angle(fitData));
    v = axis; axis([fStart fStop v(3:4)]);
    title('cavity phase and final fit');
    xlabel('frequency (kHz)');
    ylabel('radians');
    legend('raw data', 'constant phase offset', ...
        'constant and linear phase offsets', 'total fit');
    grid on;
end % if debugOn

return


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [magEstimate, dataInd] = magParamEstimate( w, data )
% estimate w,Q,R from quadratic fit of data using expansion
%  log(1+x) ~ x
magData = log(abs(data));
[maxData maxDataInd] = max(magData);
magEstIndSize = 30;
dataInd = max(1,maxDataInd-magEstIndSize): ...
    min(length(data),maxDataInd+magEstIndSize);
% use polyfit call that normalizes arguments xHat=(x-mu(1))/mu(2)
[pMu, S, mu] = polyfit( w(dataInd), magData(dataInd), 2 );
% recover original polynomial values
p = [
    pMu(1)/(mu(2)^2)
    pMu(2)/mu(2) - 2*pMu(1)/(mu(2)^2)*mu(1)
    pMu(1)/(mu(2)^2)*(mu(1)^2) - pMu(2)/mu(2)*mu(1) + pMu(3)
    ];
    
w0 = -p(2)/(2*p(1));
Q0 = w0*sqrt(-p(1)/2);
R0 = exp(p(3) + 2*Q0^2);
magEstimate = [w0 Q0 R0];

debugOn = 0;
if debugOn,
    figInd=300;
    figInd=figInd+1; figure(figInd); clf;
    plot( w(dataInd)/(2*pi)*1e3, magData(dataInd), 'rx' ); hold on;
    y = polyval( p, w(dataInd) );
    plot( w(dataInd)/(2*pi)*1e3, y, 'b' );
end % if debugOn
return


function [phaEstimate] = phaParamEstimate( w, data, w0 )
% estimate w,Q,R from linear phase fit of data
%  around the resonant frequency
p = polyfit( w, unwrap(angle(data)), 1 );
phaEstimate = p(1)*w0 + p(2);

debugOn = 0;
if debugOn,
    figInd=310;
    figInd=figInd+1; figure(figInd); clf;
    y = polyval( p, w );
    plot( w/(2*pi)*1e3, unwrap(angle(data)), 'gx', ...
        w/(2*pi)*1e3, y, 'b', ...
        w0/(2*pi)*1e3, phaEstimate, 'rs' );
end % if debugOn
return


function [complexOutput] = cavityTotalFit( x, w, wRf )
% fitting function for total cavity for lsqcurvefit
output = cavitySysFun( x, w, wRf );
complexOutput = [real(output(:)); imag(output(:))];
return


function [output] = cavityMagFit( x, w )
% fitting function for cavity magnitude for lsqcurvefit
cavOut = cavityFun( x, w );
output = abs( cavOut );
return


function [output] = cavityFun( x, w )
% generate complex cavity function
wC = x(1);
Q = x(2);
R = x(3);
s = i*w;
output = (R*wC/Q).*s ./ ( s.^2 + (wC/Q).*s + wC^2 );
return


function [complexOutput] = cavityPhaseFit( phi, w, xMag )
% fitting function for cavity phase for lsqcurvefit
output = cavityFun( xMag, w ).*exp(i*phi);
complexOutput = [real(output(:)); imag(output(:))];
return


function [complexOutput] = cavityLinPhaseFit( tau, w, cavFit, phiOffset, wRf )
% fitting function linear phase cavity term for lsqcurvefit
output = cavFit.*exp(i*(phiOffset - (w-wRf)*tau*1e-3));
complexOutput = [real(output(:)); imag(output(:))];
return


function [output] = cavitySysFun( x, w, wRf )
% cavity system response with constant and linear phase offset
Wc = x(1);		% radian frequency in 1e6 rad/sec
Ql = x(2);		% loaded Q of the cavity
Rl = x(3);		% gain constant for the cavity
Td = x(4);		% time delay - ns
offset = x(5);	% phase offset - radians

cavity_response = cavityFun( x, w );
delay_response  = exp(-j*(w-wRf)*Td*1e-3);
output  = cavity_response .* delay_response .* exp(j*offset);
return
