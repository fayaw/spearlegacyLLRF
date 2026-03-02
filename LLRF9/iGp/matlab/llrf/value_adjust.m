% value_adjust      - Read the setting, add an offset, write back
%
% function val = value_adjust(pv, delta, flag)
%
%   pv		- Channel to adjust
%   delta	- Offset value
%   flag	- Phase flag, trim to -180 to +180 degree range

function val = value_adjust(pv, delta, flag)

val = lcaGet(pv);
if (nargin == 3 && flag == 1)
  val = ph_trim(val + delta);
else
  val = val + delta;
end
lcaPut(pv, val);
