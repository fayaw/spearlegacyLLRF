% proc_bunch_tunes1 - Plot a single closed-loop measurement
%
% Copyright (c) 2011 Dimtel, Inc., All Rights Reserved
%
% $Id: proc_bunch_tunes1.m,v 1.1 2011/12/16 12:30:46 dim Exp $
% $Date: 2011/12/16 12:30:46 $
% $Author: dim $
% $Revision: 1.1 $
% $Log: proc_bunch_tunes1.m,v $
% Revision 1.1  2011/12/16 12:30:46  dim
% Cleanup, support of 8/12 bit systems, bunch tunes measurement updates
%
%

clear

nb = input('Bunches to process [1:100]: ');
if (isempty(nb))
  nb    = 1:100;
end

% FFT length - very sensitive
Ns    = 2048;

wd = pwd; idx=strfind(wd, '/');
dirs = wd(idx(end)+1:end);
[Md Nd] = size(dirs);
cd ..

% Perform the averaging
tune_avg;

% Feedback delay in turns - zero seems to work best
delay = 0;

% Plot one spectrum, ask for limits
clf;
plot(prm.freq/1e3, 10*log10(S(:,1)));
xlabel('Frequency (kHz)');
ylabel('Power spectral density (dB)');

f1 = input('Lower plotting limit, kHz: ')*1e3;
f2 = input('Upper plotting limit, kHz: ')*1e3;

% Simple tune plots, without fitting
tune_plots;

cd(dirs)
