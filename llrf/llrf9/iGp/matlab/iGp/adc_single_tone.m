% adc_single_tone   - Single-tone ADC parameter calculation & plotting
%
% Copyright (c) 2006-2014 Dimtel, Inc., All Rights Reserved
%
% $Id$
% $Date$
% $Author$
% $Revision$
% $Log$
%

function [sol, RMS, D, amp, fr, x, x_fit, SNR, SINAD, SFDR, ENOB, freq, X1, X2] = adc_single_tone(Ts, x, amp_max, noplot)

opts=optimset('TolX', 1e-6, 'TolFun', 1e-6, 'LargeScale', 'off');

N = length(x);
t = [0:N-1]*Ts;

% Do the fitting
[sol, x_fit, X] = sinfit(Ts, x, opts);

amp = sol(1);
fr  = sol(2);
RMS = std(x-x_fit, 1);

% Compute SINAD
X  = abs(X);
X1 = X(2:N/2);
[sig, idx] = max(X1);
SINAD = 10*log10(sig^2/sum(X1([1:idx-1 idx+1:end]).^2));
[D, peak_idx]   = max(abs(x-x_fit));

% Compute ENOB
ENOB = (SINAD - 1.76 + 20*log10(amp_max/amp))/6.02;

% Compute SNR
% Original definition of SNR, fails for large harmonic distortion cases
% SNR(k) = 20*log10(amp(k)/sqrt(2)/RMS(k));

% Go up to the 20th harmonic
nn  = [1:20]*idx;
nn  = rem(nn, N); u = find(nn >= N/2); nn(u) = N - nn(u);
nn = nn(find(nn ~= 0));
X2  = X1; X2(nn) = 0;
SNR = 10*log10(sig^2./sum(X2.^2));

% Compute SFDR
freq = [0:N/2-1]/Ts/N/1e6;
X = X(1:N/2)/max(X);
% Now find the SFDR. Search for peaks
xd = diff(X);
idx = find(xd(1:end-1) > 0 & xd(2:end) < 0);
peaks = X(idx+1);
[pk, ptr] = sort(peaks);

v = find(abs(idx(ptr(end))-idx(ptr)) > 10);

% SFDR
SFDR = 20*log10(pk(end)/pk(v(end)));

if ~(nargin == 4 && noplot==1)
  figure(1); clf
  subplot(211)
  plot(t*1e6, x, t*1e6, x_fit, 'r');
  xlabel('Time ({\mu}s)');
  ylabel('Amplitude (counts)');
  subplot(212);
  %  hist(x-x_fit, 50);
  plot(x_fit, x-x_fit, '.');

  figure(2); clf
  plot(freq, 20*log10(X), 'b', freq(idx(ptr(v(end)))+1), 20*log10(pk(v(end))), 'ro');
  xlabel('Frequency (MHz)');
  ylabel('Amplitude (dB)');
  title(sprintf('SFDR %.1f dB, fundamental at %.1f MHz, spur at %.1f MHz', ...
          SFDR, freq(idx(ptr(end))), freq(idx(ptr(v(end))))));
  grid;
end
