% iGp_postmortem_read_arm - Reads out postmortem data, arms acquisition
%
% Copyright (c) 2018 Dimtel, Inc., All Rights Reserved
%
% $Id: iGp_postmortem_read_arm.m,v 1.1 2018/08/08 21:43:27 dim Exp $
% $Date: 2018/08/08 21:43:27 $
% $Author: dim $
% $Revision: 1.1 $
% $Log: iGp_postmortem_read_arm.m,v $
% Revision 1.1  2018/08/08 21:43:27  dim
% Initial commit
%
%

function prm = iGp_postmortem_read_arm(sys, acq_unit)

acq_cnt = 1;
iGp_read;
disp(['Data saved in directory [', prm.tm, '], re-arming']);
lcaPut([prm.root, ':', sys, ':', acq_unit, ':ARM'], 1);

