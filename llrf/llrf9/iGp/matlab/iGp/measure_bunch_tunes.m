% measure_bunch_tunes - Acquire multiple measurements, average, fit
%
% Copyright (c) 2009 Dimtel, Inc., All Rights Reserved
%
% $Id: measure_bunch_tunes.m,v 1.2 2011/12/16 12:30:46 dim Exp $
% $Date: 2011/12/16 12:30:46 $
% $Author: dim $
% $Revision: 1.2 $
% $Log: measure_bunch_tunes.m,v $
% Revision 1.2  2011/12/16 12:30:46  dim
% Cleanup, support of 8/12 bit systems, bunch tunes measurement updates
%
% Revision 1.1.1.1  2010/10/05 16:43:02  dim
% Initial import of iGp12
%
%

clear;
acq.sys = input('iGp device name [TEST]: ', 's');
acq.count = input('Data sets to acquire [6]: ');
if (isempty(acq.count))
  acq.count=6;
end

sys = acq.sys;
acq_unit = 'SRAM';

for acq_cnt=1:acq.count
  iGp_read
  acq.dirs(acq_cnt, :) = prm.tm;
end
clear sys acq_cnt;

dirs = acq.dirs;

% Save the re-analysis script
cd(dirs(1,:));
save dirs acq;
fid = fopen('replot_bunch_tunes.m', 'w');
fprintf(fid, 'clear;\nload dirs;\ndirs=acq.dirs;\n[Md, Nd] = size(dirs);\n');
fprintf(fid, 'cd(''..'');\nproc_bunch_tunes;\ncd(dirs(1,:));\n');
fclose(fid);
cd('..');

[Md, Nd] = size(dirs);

% Do the processing
proc_bunch_tunes;
