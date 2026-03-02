% iGp_plt           - Plot acquired data
%
% Copyright (c) 2006-2007 Dimtel, Inc., All Rights Reserved
%
% $Id: iGp_plt.m,v 1.1.1.1 2010/10/05 16:43:01 dim Exp $
% $Date: 2010/10/05 16:43:01 $
% $Author: dim $
% $Revision: 1.1.1.1 $
% $Log: iGp_plt.m,v $
% Revision 1.1.1.1  2010/10/05 16:43:01  dim
% Initial import of iGp12
%
% Revision 1.2  2008/01/05 19:53:38  dim
% Changes to avoid reliance on sort_bunches and rms() from the LFB suite
%
% Revision 1.1  2007/10/28 08:23:15  dim
% Tools to include in the distribution
%
% Revision 1.1  2007/03/14 08:35:58  dim
% Matlab tools for data acquisition and testing with file-based data exchange
%
%

iGp_load_data;
[N, M]=size(data);
bkt = 0:M-1;
figure(1); clf;
subplot(211);
plot(bkt, mean(data)); xlabel('RF bucket number');
ylabel('ADC counts');
title(['Mean of the recorded signal: ', prm.st]);

Nf = 10;
b = [1-1/Nf -ones(1, Nf-1)/Nf];
df = filter(b, 1, data);
RMS=std(df(Nf:end,:), 1);

subplot(212);
plot(bkt, RMS); xlabel('RF bucket number');
ylabel('ADC counts');
title(['RMS of the recorded signal: ', prm.st]);

fsamp = rf_freq*1e6/ring_size/downsamp;
bf = abs(fft(data));
avg_vec = 1/ring_size*ones(ring_size, 1);
bff = ((bf.^2*avg_vec).^0.5)*2/M;
bff(1) = mean(bff);
fr = (0:N-1)/N*fsamp/1e3;
figure(2); clf
semilogy(fr,bff),grid on
axis([0 fsamp/2e3 min(bff)*3/4 max(bff)])
xlabel('Freq (kHz)')
ylabel('Counts')
title([prm.tm ': Signal spectrum averaged (quadratic) over all bunches'])
