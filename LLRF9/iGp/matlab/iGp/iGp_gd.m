% iGp_gd            - Acquires iGp/iGp12 data and attendant variables
%
% Copyright (c) 2006-2010 Dimtel, Inc., All Rights Reserved
%
% $Id: iGp_gd.m,v 1.13 2019/04/26 16:53:01 dim Exp $
% $Date: 2019/04/26 16:53:01 $
% $Author: dim $
% $Revision: 1.13 $
% $Log: iGp_gd.m,v $
% Revision 1.13  2019/04/26 16:53:01  dim
% Bug fix for no DCCT configs
%
% Revision 1.12  2018/12/07 08:29:18  dim
% Added gateware type parameter
%
% Revision 1.11  2018/08/08 21:44:27  dim
% Added handling of multiple trigger sources, HWTEN instead of EXTEN
%
% Revision 1.10  2017/06/27 21:15:46  dim
% Moved gd.mat generation to prm2gd()
%
% Revision 1.9  2016/12/20 23:47:30  dim
% Support for iGp8 FBE-LT and late FBE code
%
% Revision 1.8  2016/03/24 07:03:06  dim
% Fixed time units handling for BRAM and SRAM
%
% Revision 1.7  2014/03/27 23:41:18  dim
% Now prm.root is always defined on entry, no need to check
%
% Revision 1.6  2013/09/05 06:15:15  dim
% Removed old filter coefficient formats, thus getting rid of control toolbox
% requirement
%
% Revision 1.5  2013/01/04 09:56:35  dim
% Added optional PV system (prm.root) selection
%
% Revision 1.4  2011/12/16 12:30:46  dim
% Cleanup, support of 8/12 bit systems, bunch tunes measurement updates
%
% Revision 1.3  2011/11/02 21:25:07  dim
% Optimized data PV retrieval, fixed gden bit for FPGA rev. 3.04+
%
% Revision 1.2  2011/10/20 16:59:40  dim
% Support for new data acquisition (FPGA rev. 3.04)
%
% Revision 1.1.1.1  2010/10/05 16:43:02  dim
% Initial import of iGp12
%
%

function [status, prm] = iGp_gd(prm)

t00 = clock;

pvnm = [prm.root, ':', prm.sys, ':'];

prm.gpio_sel = lcaGet([pvnm, 'GPIO_SEL'], 1, 'long');

% Read out various parameters
prm.when = now;

pvl     = {[pvnm, 'CSET0']; [pvnm, 'CSET1']};
pvl{3}  = [pvnm, 'CR256'];
pvl{4}  = [pvnm, 'DELAY'];
pvl{7}  = [pvnm, 'RF_FREQ'];
pvl{8}  = [pvnm, 'HARM_NUM'];
pvl{10} = [pvnm, 'PROC_DS'];
pvl{11} = [pvnm, 'GW_TYPE'];
if (prm.gpio_sel == 1)
  pvl{12} = [pvnm, 'FE_ATTEN'];
  pvl{13} = [pvnm, 'BE_ATTEN'];
end

if (prm.fpga_rev < 3)
  pvl{5}  = [pvnm, 'GDLEN'];
  pvl{6}  = [pvnm, 'WRT:HOLDOFF'];
  pvl{9}  = [pvnm, 'REC_DS'];
elseif (prm.fpga_rev < 3.04)
  pvl{5}  = [pvnm, 'GDTIME'];
  pvl{6}  = [pvnm, 'HOLDTIME'];
  pvl{9}  = [pvnm, 'REC_DS'];
else
  pvl{5}  = [pvnm, prm.acq_unit, ':GDTIME'];
  pvl{6}  = [pvnm, prm.acq_unit, ':HOLDTIME'];
  pvl{9}  = [pvnm, prm.acq_unit, ':REC_DS'];
end

% Front-back end handling, separated from normal code
if (prm.fpga_rev < 2.04) % iGp8 before FBE-LT support
  if (prm.gpio_sel == 1)
    pvl{14} = [pvnm, 'WRT:FE_PHASE'];
    pvl{15} = [pvnm, 'WRT:BE_PHASE'];
  end
elseif (prm.fpga_rev >= 3.00 & prm.fpga_rev < 3.04) % Early iGp12
  if (prm.gpio_sel == 1)
    pvl{14} = [pvnm, 'FE_PHASE'];
    pvl{15} = [pvnm, 'BE_PHASE'];
  elseif (prm.gpio_sel == 2)
    pvl{12} = [pvnm, 'FBE:Z_ATT'];
    pvl{13} = [pvnm, 'FBE:BE_ATT'];
    pvl{14} = [pvnm, 'FBE:Z_PHASE'];
    pvl{15} = [pvnm, 'FBE:BE_PHASE'];
    pvl{16} = [pvnm, 'FBE:X_ATT'];
    pvl{17} = [pvnm, 'FBE:Y_ATT'];
    pvl{18} = [pvnm, 'FBE:X_PHASE'];
    pvl{19} = [pvnm, 'FBE:Y_PHASE'];
  end
else % iGp12 and late iGp8 with FBE-LT support
  if (prm.gpio_sel == 1)
    pvl{14} = [pvnm, 'FE_PHASE'];
    pvl{15} = [pvnm, 'BE_PHASE'];
  elseif (prm.gpio_sel == 2)
    pvl{12} = [pvnm, 'FBE:Z_ATT'];
    pvl{13} = [pvnm, 'FBE:BE_ATT'];
    pvl{14} = [pvnm, 'FBE:Z_PHASE'];
    pvl{15} = [pvnm, 'FBE:BE_PHASE'];
    pvl{16} = [pvnm, 'FBE:X_ATT'];
    pvl{17} = [pvnm, 'FBE:Y_ATT'];
    pvl{18} = [pvnm, 'FBE:X_PHASE'];
    pvl{19} = [pvnm, 'FBE:Y_PHASE'];
  end
end

if (prm.fpga_rev >= 3.04)
  pvl{end+1} = [pvnm, prm.acq_unit, ':POSTTIME'];
  post_idx   = length(pvl);
end

% If dcct field is defined, use it as beam current PV
if isfield(prm, 'dcct')
 pvl{end+1} = prm.dcct;
end

% Read the channels
data = lcaGet(pvl, 0);

% Parse the data
prm.coeff0     = data(1,:)/32768;
prm.coeff1     = data(2,:)/32768;
prm.Nc         = length(prm.coeff0);
prm.shift_gain = bitand(bitshift(data(3,1), -4), 7);
prm.delay      = data(4,1);
prm.setsel     = bitand(bitshift(data(3,1), -2), 1);
prm.rf_freq    = data(7,1);
prm.ring_size  = data(8,1);
prm.ds         = data(9,1);
prm.proc_ds    = data(10,1);
prm.gw_type    = data(11,1);

if (prm.fpga_rev >= 3.04)
  if strcmp(prm.acq_unit, 'SRAM')
    time_unit = 1e3;
  else
    time_unit = 1;
  end
end

if (prm.fpga_rev < 3)
  prm.gdlen    = data(5,1);
  prm.holdoff  = data(6,1);
else
  prm.gdlen    = data(5,1)/(prm.ds/prm.rf_freq)*time_unit;
  prm.holdoff  = data(6,1)/(prm.ds/prm.rf_freq)*time_unit;
end

% New data acquisition code, pre/post trigger
if (prm.fpga_rev >= 3.04)
  prm.post_trigger = data(post_idx,1)/(prm.ds/prm.rf_freq)*time_unit;
  gden = lcaGet([pvnm, 'GDEN']);
  if (strcmp(prm.acq_unit, gden))
    prm.gden = 1;
  else
    prm.gden = 0;
  end
else
  prm.gden       = bitand(bitshift(data(3,1), -8), 1);
end

if (prm.gpio_sel == 1)
  prm.fe_atten = data(12,1);
  prm.be_atten = data(13,1);
  prm.fe_phase = data(14,1);
  prm.be_phase = data(15,1);
elseif (prm.gpio_sel == 2)
  prm.fe_atten = data(12,1); % Z
  prm.be_atten = data(13,1);
  prm.fe_phase = data(14,1);
  prm.be_phase = data(15,1);
  prm.x_atten  = data(16,1);
  prm.y_atten  = data(17,1);
  prm.x_phase  = data(18,1);
  prm.y_phase  = data(19,1);
end

% If beam current PV is defined above, read out the current
if isfield(prm, 'dcct')
  prm.Io = data(end,1);
else
  prm.Io = 0;
end

clear pvl;
pvl = {[pvnm, 'DESC:CSET0']; [pvnm, 'DESC:CSET1']};
if (prm.fpga_rev >= 3.04)
  if (prm.fpga_rev >= 3.15)
    pvl{3} = [pvnm, prm.acq_unit, ':HWTEN'];
  else
    pvl{3} = [pvnm, prm.acq_unit, ':EXTEN'];
  end
  if (prm.fpga_rev >= 3.05)
    pvl{4} = [pvnm, prm.acq_unit, ':POSTSEL'];
  end
else
  pvl{3} = [pvnm, 'EXTEN'];
end
if (prm.fpga_rev >= 3.15)
  pvl{5} = [pvnm, prm.acq_unit, ':TRIG_IN_SEL'];
end
desc = lcaGet(pvl);

prm.cset0 = desc{1};
prm.cset1 = desc{2};
prm.exten = desc{3};
if (prm.fpga_rev >= 3.05)
  prm.postsel = desc{4};
end
if (prm.fpga_rev >= 3.15)
  prm.trig_src = desc{5};
end

if (prm.debug)
  t01 = clock;
  disp(['Parameters acquired after ', num2str(etime(t01, t00)), ' seconds']);
end

if (isfield(prm, 'acq_unit'))
  prm.data = get_data(pvnm, prm.acq_unit);
else
  prm.data = get_data(pvnm);
end

if isfield(prm, 'postsel')
  if (prm.postsel == 1)
    prm.post_trigger = length(prm.data);
  end
end

if (prm.debug)
  t02 = clock;
  disp(['Data transferred after ', num2str(etime(t02, t00)), ' seconds']);
end

prm.st = [prm.sys, '; I_0 = ', num2str(prm.Io), ' mA; ', ...
          datestr(prm.when)];


% Save gd.mat file
prm2gd(prm);

% Save prm.mat file
eval(['save ', prm.tm, '/prm prm']);
status = 1;
