% iGp_read          - Script to read out data and plot mean/RMS/spectrum
%
% Copyright (c) 2006 Dimtel, Inc., All Rights Reserved
%
% $Id: iGp_read.m,v 1.4 2014/03/28 00:02:03 dim Exp $
% $Date: 2014/03/28 00:02:03 $
% $Author: dim $
% $Revision: 1.4 $
% $Log: iGp_read.m,v $
% Revision 1.4  2014/03/28 00:02:03  dim
% Root must be defined by iGp_local()
%
% Revision 1.3  2014/03/27 23:40:39  dim
% Modified to read local settings config first, eliminating machine-specific scripts
%
% Revision 1.2  2011/10/20 16:59:40  dim
% Support for new data acquisition (FPGA rev. 3.04)
%
% Revision 1.1.1.1  2010/10/05 16:43:02  dim
% Initial import of iGp12
%
% Revision 1.1  2008/01/05 19:53:38  dim
% Changes to avoid reliance on sort_bunches and rms() from the LFB suite
%
% Revision 1.1  2007/03/14 08:35:58  dim
% Matlab tools for data acquisition and testing with file-based data exchange
%
%

vars=who;
for k=1:length(vars)
  if (~strcmp(vars{k}, 'sys') && ~strcmp(vars{k}, 'acq') && ...
      ~strcmp(vars{k}, 'acq_cnt') && ~strcmp(vars{k}, 'acq_unit'))
    clear(vars{k});
  end
end

prm = iGp_local;

prm.debug = 1;
if (exist('sys', 'var'))
  prm.sys = sys;
else
  prm.sys = input('iGp12 device name [TEST]: ', 's');
end
if (isempty(prm.sys))
  prm.sys = 'TEST';
end

prm.fpga_rev = lcaGet([prm.root, ':', prm.sys, ':REVISION']);

if (prm.fpga_rev >= 3.04)
  if(exist('acq_unit', 'var'))
    prm.acq_unit = acq_unit;
  else
    prm.acq_unit = input('Acquisition subsystem (BRAM or SRAM) [SRAM]: ', 's');
  end
  if (isempty(prm.acq_unit))
    prm.acq_unit = 'SRAM';
  end
end

% Figure out the directory
prm.tm = datestr(now, 'HH:MM:SS');
prm.tm(3:4)=prm.tm(4:5); prm.tm(5:6)=prm.tm(7:8); prm.tm = prm.tm(1:6);
unix(['mkdir ', prm.tm]);

[status, prm] = iGp_gd(prm);

if (status && ~exist('acq_cnt', 'var'))
  disp(['Created data set [', prm.tm, ']. Plotting...']);
  eval(['cd ', prm.tm]);
  iGp_plt
  cd ..
end
