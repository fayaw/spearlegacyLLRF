function [hTot] = rftfresponse( x, prm )
% function [hTot] = rftfresponse( x, prm )
% rftfresponse plots the calculated transfer function response of the llrf
% system including klystron and cavity
% this function is based on compute_loop
% x       five element array that contains the relevant cavity parameters
%          of the system
% x(1)    cavity radian center frequency (rad/sec)
% x(2)    cavity loaded Q
% x(3)    effective cavity resistance
% x(4)    system delay (s)
% x(5)    phase offset
% prm     parameter structure returned by plot_TFC2
%         all that is required are
%         prm.wrf        rf frequency vector (rad/sec)
%         prm.w          frequency vector (rad/sec) with respect to wrf
%         prm.leadComp   logical to tell if lead compensation was used
%         prm.intComp    logical to tell if integral loop was used
% hTot    complex output vector of transfer function

% fRf determined by 'SPEAR:RFFreqSetpt' or 'SPEAR:RFFreq'

% radian frequency vectors
sRf = i*prm.w;
% baseband
s = sRf - i*prm.wrf;
sArr = [
    s.^3;
    s.^2;
    s;
    ones(size(s));
    ];
[m,n] = size(sArr);

% extract cavity and waveguide parameters from input array
wR = x(1);              % cavity center frequency
qL = x(2);              % cavity loaded Q
rL = x(3);              % cavity effective impedance
tD = x(4);              % system phase delay
phaseOffset = x(5);     % phase offset introduced into the system

% component values of analog feedback loop
r1 = 499;
r2 = 5.62e3;
r3 = 196;
r4 = 301;
c1 = 560e-12;
c2 = 10e-12;
c3 = 0.1e-6;

% cavity response
hC = ((rL*wR/qL)*sRf)./(sRf.^2 + (wR/qL)*sRf + wR^2);

% Loop delay and offset
hDel = exp(-i*(prm.w-prm.wrf)*tD + i*phaseOffset);

% direct loop parameters
% note that this is an inverting amplifier, but the inversion is assumed
% later
% select depending on lead compensation switch
if prm.leadComp,
    zInMag = r3;
    zInNum = [1 (r3 + r4)/(r3*r4*c1)];
    zInDen = [1 1/(r4*c1)];
else
    zInMag = r3;
    zInNum = (r3 + r4)/r3;
    zInDen = 1;
end % if prm.leadComp,

% select depending on integral loop switch
if prm.intComp,
    zFbMag = 1/c2;
    zFbNum = [1 1/(r1*c3)];
    zFbDen = [1 (1/(r2*c2) + 1/(r1*c2) + 1/(r1*c3)) 1/(r1*r2*c2*c3)];
else
    zFbMag = 1/c2;
    zFbNum = 1;
    zFbDen = [1 (1/(r2*c2) + 1/(r1*c2))];
end % if prm.intComp,

zTotMag = zFbMag/zInMag;
zTotNum = conv( zFbNum, zInDen );
zTotDen = conv( zFbDen, zInNum );
lenNum = length(zTotNum);
lenDen = length(zTotDen);

hDir = zTotMag*(zTotNum*sArr((m-lenNum+1):end,:))./ ...
    (zTotDen*sArr((m-lenDen+1):end,:));

hTot = hC.*hDel.*hDir;

return
end