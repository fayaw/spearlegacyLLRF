% tune_plots        - Plot some simple (crude) tune plots
%
% Copyright (c) 2009 Dimtel, Inc., All Rights Reserved
%
% $Id: tune_plots.m,v 1.3 2013/09/05 06:13:54 dim Exp $
% $Date: 2013/09/05 06:13:54 $
% $Author: dim $
% $Revision: 1.3 $
% $Log: tune_plots.m,v $
% Revision 1.3  2013/09/05 06:13:54  dim
% Updated to blank out empty bunches in the plot
%
% Revision 1.2  2011/12/16 12:30:47  dim
% Cleanup, support of 8/12 bit systems, bunch tunes measurement updates
%
% Revision 1.1.1.1  2010/10/05 16:43:01  dim
% Initial import of iGp12
%
%

frev = rf_freq*1e3/ring_size;

% Define frequency selection index
u = find(prm.freq > f1 & prm.freq < f2);

% Search for minima
[foo, midx] = min(S(u,:));

% Plot the results
figure(2); clf
subplot(211);
h = plot(nb, prm.freq(u(midx))/1e3/frev, '-o');
set(h, 'linewidth', 2, 'markersize', 7);
set(gca, 'fontsize', 14);
xlabel('Bunch number');
ylabel('Fractional tune');
grid;

nn = 1:ring_size;
S1=nan*zeros(length(prm.freq), ring_size);
S1(:, nb) = log(S);
subplot(212);
set(gca, 'fontsize', 14);
pcolor(nn, prm.freq(u)/1e3/frev, S1(u,:)); shading('flat');
xlabel('Bunch number');
ylabel('Fractional tune');
grid;
colorbar
set(gca, 'fontsize', 14);
