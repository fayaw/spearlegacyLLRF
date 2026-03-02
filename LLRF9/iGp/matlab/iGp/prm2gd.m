% prm2gd - Convert parameter structure to gd.mat
%
% prm2gd(prm) saves gd.mat in subdirectory, defined by prm.tm string

% Copyright (c) 2017 Dimtel, Inc., All Rights Reserved
%
% $Id: prm2gd.m,v 1.1 2017/06/27 21:15:14 dim Exp $
% $Date: 2017/06/27 21:15:14 $
% $Author: dim $
% $Revision: 1.1 $
% $Log: prm2gd.m,v $
% Revision 1.1  2017/06/27 21:15:14  dim
% Initial import
%

function prm2gd(prm)

M = floor(length(prm.data)/prm.ring_size);
bunches(1,:) = 1:prm.ring_size;
bunches(2:M+1,:) = zeros(M, prm.ring_size);
bunches(2:M+1,:) = reshape(prm.data(1:M*prm.ring_size), prm.ring_size, M)';

bunches(1,:) = 1:prm.ring_size;

ring_size = prm.ring_size;
rf_freq = prm.rf_freq;
shift_gain = prm.shift_gain;
downsamp = prm.ds;
if (prm.gden == 1)
  damp_brkpt = round(prm.gdlen/length(prm.data)*63);
else
  damp_brkpt = 1;
end
beamCurrent = prm.Io;
turn_offsets = zeros(ring_size, 1);

scope = 2;
eval(['save ', prm.tm, '/gd bunches damp_brkpt ' ...
      'turn_offsets beamCurrent downsamp shift_gain rf_freq ring_size ' ...
      'scope']);
