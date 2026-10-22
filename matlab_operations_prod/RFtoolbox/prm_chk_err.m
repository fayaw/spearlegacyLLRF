% prm_chk_err       - Check the structure for errors and return the string
%
% function [ok, string] = prm_chk_err(prm);
%

function [ok, string] = prm_chk_err(prm);

if (isfield(prm, 'error'))
  ok = 0;
  string = prm.error;
else
  ok = 1;
  string = '';
end
