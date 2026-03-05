% proc_bunch_tunes - Acquire multiple measurements, average, fit
%
% Copyright (c) 2009 Dimtel, Inc., All Rights Reserved
%
% $Id: proc_bunch_tunes.m,v 1.4 2017/06/27 21:17:00 dim Exp $
% $Date: 2017/06/27 21:17:00 $
% $Author: dim $
% $Revision: 1.4 $
% $Log: proc_bunch_tunes.m,v $
% Revision 1.4  2017/06/27 21:17:00  dim
% Added a mechanism to vary FFT length
%
% Revision 1.3  2011/12/16 12:42:18  dim
% Removed fitting
%
% Revision 1.2  2011/12/16 12:30:46  dim
% Cleanup, support of 8/12 bit systems, bunch tunes measurement updates
%
% Revision 1.1.1.1  2010/10/05 16:43:01  dim
% Initial import of iGp12
%
%

nb = input('Bunches to process [1:100]: ');
if (isempty(nb))
  nb    = 1:100;
end

% FFT length - very sensitive
if ~exist('Ns', 'var')
  Ns    = 2048;
end

% Perform the averaging
tune_avg;

% Plot one spectrum, ask for limits
clf;
plot(prm.freq/1e3, 10*log10(S(:,1)));
xlabel('Frequency (kHz)');
ylabel('Power spectral density (dB)');

f1 = input('Lower fitting limit, kHz: ')*1e3;
f2 = input('Upper fitting limit, kHz: ')*1e3;

% Simple tune plots, without fitting
tune_plots;
