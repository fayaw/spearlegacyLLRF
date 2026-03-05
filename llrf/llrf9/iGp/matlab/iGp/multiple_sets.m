% multiple_sets     - Acquire multiple measurements
%
% Copyright (c) 2012 Dimtel, Inc., All Rights Reserved
%
% $Id: multiple_sets.m,v 1.2 2016/03/24 07:04:12 dim Exp $
% $Date: 2016/03/24 07:04:12 $
% $Author: dim $
% $Revision: 1.2 $
% $Log: multiple_sets.m,v $
% Revision 1.2  2016/03/24 07:04:12  dim
% Converted to function, adjustable delay
%
% Revision 1.1  2014/03/28 04:35:59  dim
% Initial import
%
%

function acq = multiple_sets(sys, acq_unit, count, delay)

acq.sys = sys;
acq.count = count;
acq.delay = delay;

sys = acq.sys;

for acq_cnt=1:acq.count
  iGp_read
  acq.dirs(acq_cnt, :) = prm.tm;
  pause(acq.delay);
end
