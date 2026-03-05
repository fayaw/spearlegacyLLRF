% tune_fit          - Fit notches in the averaged spectra (from tune_avg)
%
% Copyright (c) 2009 Dimtel, Inc., All Rights Reserved
%
% $Id: tune_fit.m,v 1.1.1.1 2010/10/05 16:43:01 dim Exp $
% $Date: 2010/10/05 16:43:01 $
% $Author: dim $
% $Revision: 1.1.1.1 $
% $Log: tune_fit.m,v $
% Revision 1.1.1.1  2010/10/05 16:43:01  dim
% Initial import of iGp12
%
%

frev = rf_freq*1e3/ring_size;

% Do the fitting
clear XX SXX f Sm y;
for k=1:n
  if (rem(k, 10) == 0)
    disp(['Processing vector ', num2str(k), ' of ', num2str(n)]);
  end
  [XX(k,:), SXX(k,:), f, Sm(:,k), y(k)] = fit_notch1(S(:,k), prm, f1, f2, delay);
end

% Compute beam currents
base = mean(mv(300:end));
bc = mv(nb)-base;
bc = Ib*bc/sum(bc);

% Ignore invalid data
v = find((XX(:,4)<0) | (XX(:,4) > frev*pi*1e3));
XX(v,4)  = NaN;
SXX(v,4) = NaN;

% Plot the results
figure(1); clf
subplot(211);
h = errorbar(1:n, frev-XX(:,4)/2e3/pi, SXX(:,4)/2e3/pi, 'o');
set(h, 'linewidth', 2, 'markersize', 7);
set(gca, 'fontsize', 14);
xlabel('Bunch number (4 ns)');
ylabel('Tune (kHz)');
grid;
subplot(212);
set(gca, 'fontsize', 14);
bar(1:n, bc);
xlabel('Bunch number (4 ns)');
ylabel('Bunch current (mA)');
title(['Beam current ', num2str(Ib), ' mA']);
grid;