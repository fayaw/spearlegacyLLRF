% get_data          - Save IOC buffer to file, copy over and read in
%
% Copyright (c) 2006 Dimtel, Inc., All Rights Reserved
%
% $Id: get_data.m,v 1.8 2019/05/30 00:44:15 dim Exp $
% $Date: 2019/05/30 00:44:15 $
% $Author: dim $
% $Revision: 1.8 $
% $Log: get_data.m,v $
% Revision 1.8  2019/05/30 00:44:15  dim
% Debugging
%
% Revision 1.7  2019/05/14 23:52:29  dim
% Updated readout logic to avoid hangs with repeat readouts, added duplicate warning
%
% Revision 1.6  2019/04/26 16:52:46  dim
% Modified data readout to succeed even when reading out stale data (with warning)
%
% Revision 1.5  2018/08/08 21:41:02  dim
% Fixed a bug with stale monitors causing the function to time out
%
% Revision 1.4  2017/05/07 09:25:35  dim
% Updated to better avoid race conditions in waiting for new waveforms
%
% Revision 1.3  2011/11/02 21:25:07  dim
% Optimized data PV retrieval, fixed gden bit for FPGA rev. 3.04+
%
% Revision 1.2  2011/10/20 16:59:40  dim
% Support for new data acquisition (FPGA rev. 3.04)
%
% Revision 1.1.1.1  2010/10/05 16:43:01  dim
% Initial import of iGp12
%
% Revision 1.2  2008/04/29 19:54:53  dim
% Transitioned from wget to urlwrite(), DCCT support, added FE/BE channels
% to saved parameters list.
%
% Revision 1.1  2007/10/28 08:23:15  dim
% Tools to include in the distribution
%
% Revision 1.1  2007/03/14 08:35:58  dim
% Matlab tools for data acquisition and testing with file-based data exchange
%
%

function x = get_data(pvroot, acq_unit)

fpga_rev = lcaGet([pvroot, 'REVISION']);

if (nargin == 1)
  acq_unit = 'BRAM'; % Default to BRAM for quicker transfers
end

if (fpga_rev > 10)
  % iGp12HF
  lcaPut([pvroot, acq_unit, ':DUMP'], 1);
  while (1)
    x = lcaGet([pvroot, acq_unit, ':DUMP'], 1, 'int');
    if (x == 0)
      break;
    end
  end
  n = lcaGet([pvroot, acq_unit, ':RAW:SAMPLES']);
  x = lcaGet([pvroot, acq_unit, ':RAW'], n);
elseif (fpga_rev >= 3.04)
  % Completely new model!!!

  % Redone in 2017 to monitor ACQ_ID
  aid = [pvroot, acq_unit, ':RAW:ACQ_ID'];

  if (0)
    % Make sure old monitors are cleared
    lcaSetMonitor(aid); lcaClear(aid);

    % Set a monitor on acquisition ID
    lcaSetMonitor(aid);
    % Wait for the monitor (old ID)
    lcaNewMonitorWait(aid);
    % Read out stale ID
    lcaGet(aid);

    % Trigger dump
    lcaPut([pvroot, acq_unit, ':DUMP'], 1);
    % Wait for acquisition ID to update
    lcaNewMonitorWait(aid);
    [id, ts_id] = lcaGet(aid);
    lcaClear(aid);
  else
    % Acquisition ID monitor fails in one case. If we have single
    % acquisition enabled and try to read out the same data twice, it will
    % time out. Need to read out in any case, but warn the user that AID did
    % not change
    dmp = [pvroot, acq_unit, ':DUMP'];
%    disp('In get_data, starting lcaSetMonitor(dmp)');
    lcaSetMonitor(dmp); lcaClear(dmp);
%    disp('In get_data, second lcaSetMonitor(dmp)');
    % Set up the monitor, read out old value
    lcaSetMonitor(dmp); lcaNewMonitorWait(dmp); lcaGet(dmp);

%    disp('In get_data, after initial lcaNewMonitorWait(dmp)');
    % Read out old ID, trigger data dump
    [id(1) ts_id(1)] = lcaGet(aid);
    lcaPut(dmp, 1);
%    disp('In get_data, before lcaNewMonitorWait(dmp)');
    % Wait for DUMP channel to update
    lcaNewMonitorWait(dmp); dval = lcaGet(dmp, 1, 'int');
%    disp('In get_data, after lcaNewMonitorWait(dmp)');
    if (dval == 0)
      warning('Dump readback is 0');
    end
    while (dval == 1)
      lcaNewMonitorWait(dmp); dval = lcaGet(dmp, 1, 'int');
      pause(0.01);
    end
%    disp('In get_data, after lcaNewMonitorWait(dmp) loop');
    lcaClear(dmp);
%    disp('In get_data, after lcaClear(dmp)');
    [id(2) ts_id(2)] = lcaGet(aid);
    if (id(1) == id(2))
      warning(sprintf( ...
'Stale data: no change in acquisition ID (%d), timestamps %.6f/%.6f seconds', ...
          id(1), ts_id(1)/1e9, ts_id(2)/1e9));
    end
  end
%  disp('In get_data, before lcaGet(SAMPLES)');
  [n, ts_n]   = lcaGet([pvroot, acq_unit, ':RAW:SAMPLES']);
%  disp('In get_data, before lcaGet(RAW)');
  [x, ts_x]   = lcaGet([pvroot, acq_unit, ':RAW'], n);
%  disp('In get_data, after lcaGet(RAW)');
%  fprintf('id = %d, ts_id = %.4f, ts_n = %.4f, ts_x = %.4f\n', id, ...
%          imag(ts_id)/1e9, imag(ts_n)/1e9, imag(ts_x)/1e9);
else
  % Save the data
  lcaPut([pvroot, 'DATARD'], 1);
  lcaPut([pvroot, 'DATARD'], 0);
  ip = lcaGet([pvroot, 'IP_ADDR']);

  urlwrite(['http://', ip{1}, '/acq.dat'], 'acq.dat');
  fid = fopen('acq.dat');
  if (fpga_rev < 3)
    [x, count] = fread(fid, inf, 'int8');
  else
    [x, count] = fread(fid, inf, 'int16');
  end
  fclose(fid);
  x = x';
  system('rm acq.dat');
end

%disp('Out of get_data');
