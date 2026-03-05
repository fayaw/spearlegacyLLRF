% adc_params        - Extract ADC parameters from a single tone signal
%
% Copyright (c) 2014 Dimtel, Inc., All Rights Reserved
%
% $Id$
% $Date$
% $Author$
% $Revision$
% $Log$
%

function [SNR, SINAD, SFDR, SFDR_plt] = adctest(freq, X)

N = length(freq);

% Compute SINAD
X  = abs(X);
X1 = X(2:N/2);
[sig, idx] = max(X1);
SINAD = 10*log10(sig^2/sum(X1([1:idx-1 idx+1:end]).^2));

% Compute SNR
% Original definition of SNR, fails for large harmonic distortion cases
% SNR(k) = 20*log10(amp(k)/sqrt(2)/RMS(k));

% Go up to the 20th harmonic
nn = [1:20]*idx;
nn = rem(nn, N); u = find(nn >= N/2); nn(u) = N - nn(u);
X2 = X1; X2(nn) = 0;
SNR = 10*log10(sig^2./sum(X2.^2));

% Compute SFDR
X = X(1:N/2)/max(X);

% Now find the SFDR. Search for peaks
xd = diff(X);
idx = find(xd(1:end-1) > 0 & xd(2:end) < 0);
peaks = X(idx+1);
[pk, ptr] = sort(peaks);
v = find(abs(idx(ptr(end))-idx(ptr)) > 10);

% SFDR
SFDR = 20*log10(pk(end)/pk(v(end)));
SFDR_plt.f1   = freq(idx(ptr(end))+1);
SFDR_plt.f2   = freq(idx(ptr(v(end)))+1);
SFDR_plt.peak = pk(v(end));
