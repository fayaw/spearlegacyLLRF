% adctest           - Fit a sine wave to the iGp data
%
% Copyright (c) 2006 Dimtel, Inc., All Rights Reserved
%
% $Id: adctest.m,v 1.5 2020/02/11 18:13:37 dim Exp $
% $Date: 2020/02/11 18:13:37 $
% $Author: dim $
% $Revision: 1.5 $
% $Log: adctest.m,v $
% Revision 1.5  2020/02/11 18:13:37  dim
% Plot cleanup
%
% Revision 1.4  2018/08/08 21:44:51  dim
% Added Xavg to return list
%
% Revision 1.3  2014/03/28 00:03:09  dim
% Added iGp_local() call
%
% Revision 1.2  2012/03/08 03:57:55  dim
% Added ENOB computation, proper SNR and signal harmonics folding
%
% Revision 1.1.1.1  2010/10/05 16:43:01  dim
% Initial import of iGp12
%
% Revision 1.3  2009/02/06 00:10:45  dim
% Sinewave fitting improvements, processing downsampling and beam current added
%
% Revision 1.2  2008/01/05 20:48:23  dim
% Bug fixes for better fitting
%
% Revision 1.1  2007/10/28 08:23:15  dim
% Tools to include in the distribution
%
% Revision 1.2  2007/05/14 17:22:04  dim
% Added stop condition on max error
%
% Revision 1.1  2007/03/14 08:35:58  dim
% Matlab tools for data acquisition and testing with file-based data exchange
%
%

function [sol, RMS, D, amp, fr, x, x_fit, SNR, SINAD, SFDR, ENOB, freq, X1, X2, Xavg] = adctest(sys, count, stop_max)

prm = iGp_local();

pvroot=[prm.root, ':', sys, ':'];

Ts = 1/lcaGet([pvroot, 'RF_FREQ'])/1e6;
opts=optimset('TolX', 1e-6, 'TolFun', 1e-6, 'LargeScale', 'off');

for k=1:count

  x = get_data(pvroot);

  N = length(x);
  t = [0:N-1]*Ts;

  % Do the fitting
  [sol, x_fit, X] = sinfit(Ts, x, opts);

  amp(k) = sol(1);
  fr(k) = sol(2);
  RMS(k) = std(x-x_fit, 1);

  % Compute SINAD
  X  = abs(X);
  X1 = X(2:N/2);
  [sig, idx] = max(X1);
  SINAD(k) = 10*log10(sig^2/sum(X1([1:idx-1 idx+1:end]).^2));
  [D(k), peak_idx(k)]   = max(abs(x-x_fit));

  % Compute ENOB
  ENOB(k) = (SINAD(k) - 1.76 + 20*log10(2047.5/amp(k)))/6.02;

  % Compute SNR
  % Original definition of SNR, fails for large harmonic distortion cases
  % SNR(k) = 20*log10(amp(k)/sqrt(2)/RMS(k));

  % Go up to the 20th harmonic
  nn = [1:20]*idx;
  nn = rem(nn, N); u = find(nn >= N/2); nn(u) = N - nn(u);
  X2 = X1; X2(nn) = 0;
  SNR(k) = 10*log10(sig^2./sum(X2.^2));

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
  SFDR(k) = 20*log10(pk(end)/pk(v(end)));

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
        SFDR(k), freq(idx(ptr(end))), freq(idx(ptr(v(end))))));
  grid;

  figure(3); clf
  subplot(221);
  plot(1:k, RMS(1:k), 'ro-');
  xlabel('Acquisition');
  ylabel('ADC counts');
  title('RMS error');
  grid;
  subplot(223);
  plot(1:k, SFDR(1:k), '*-');
  xlabel('Acquisition');
  ylabel('SFDR (dB)');
  title('SFDR');
  grid;
  subplot(222);
  plot(1:k, amp(1:k), 'ro-');
  xlabel('Acquisition');
  ylabel('ADC counts');
  title('Amplitude');
  grid;
  subplot(224);
  plot(1:k, SNR, '*-', 1:k, SINAD, 'or-');
  xlabel('Acquisition');
  ylabel('SNR/SINAD (dB)');
  title('SNR (blue), SINAD (red)');
  grid;

  figure(4); clf
  if (k == 1)
    Xavg = X.^2;
  else
    Xavg = Xavg + X.^2;
  end
  S = 10*log10(Xavg/k);
  plot(freq, S, 'b', freq(nn+1), S(nn+1), 'or');
  xlabel('Frequency (MHz)');
  ylabel('Amplitude (dB)');
  grid;
 
  drawnow;
%  if (k ~= count)
%    pause(1);
%  end
  if (nargin == 3)
    if (D(k) > stop_max)
      break;
    end
  end
end
