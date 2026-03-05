% sb_read           - Read out single-bunch data from iGp2
%
% prm = sb_read(device);
%
% Arguments:
%  device    - Device ID
%
% Outputs:
%  prm.freq     - Frequency axis
%  prm.mag      - Magnitude (gain or spectrum)
%  prm.phase    - Phase (valid only for transfer function mode)
%  prm.t        - Time scale (ms)
%  prm.data     - Bunch data vector
%  prm.drive    - Excitation vector (valid only for transfer function mode
%  prm.samples  - Number of samples in the above two vectors
%  prm.bunch    - Bunch number
%  prm.nfft     - Window and FFT length
%  prm.noverlap - Overlap

%
% Copyright (c) 2013-2014 Dimtel, Inc., All Rights Reserved
%
% $Id: sb_read.m,v 1.4 2014/03/28 04:36:37 dim Exp $
% $Date: 2014/03/28 04:36:37 $
% $Author: dim $
% $Revision: 1.4 $
% $Log: sb_read.m,v $
% Revision 1.4  2014/03/28 04:36:37  dim
% Minor changes to comments
%
% Revision 1.3  2014/03/28 00:04:06  dim
% Fixed extra NaNs in FFT data, added readout of the reconstructed drive signal
%
% Revision 1.2  2014/01/13 09:28:59  dim
% Trailing point removal fixed
%
% Revision 1.1  2013/11/04 19:06:26  dim
% A function to read out single bunch data
%

function prm = sb_read(device);

prm = iGp_local();

pvnm = [prm.root, ':', device, ':SB:'];

pvs = { 'FREQ'; 'MAG'; 'PHASE'; 'RAW'; 'TSC'; 'DRIVE'; ...
        'RAW:SAMPLES'; 'RAW:BUNCH_ID'};

for k=1:length(pvs)
  pvs{k} = [pvnm, pvs{k}];
end

vals = lcaGet(pvs);

N2 = lcaGetNelem(pvs{1});

prm.freq     = vals(1,1:N2);
prm.mag      = vals(2,1:N2);
prm.phase    = vals(3,1:N2);
prm.samples  = vals(7,1);
prm.data     = vals(4,1:prm.samples);
prm.t        = vals(5,1:prm.samples);
prm.drive    = vals(6,1:prm.samples);
prm.bunch    = vals(8,1);
prm.nfft     = lcaGet([pvnm, 'NFFT']); prm.nfft = str2num(prm.nfft{1});
prm.noverlap = lcaGet([pvnm, 'NOVERLAP']); prm.noverlap = str2num(prm.noverlap{1});

% Get rid of repeated values
u = find(prm.freq == prm.freq(end)); u = 1:u(1);
prm.freq  = prm.freq(u);
prm.mag   = prm.mag(u);
prm.phase = prm.phase(u);
