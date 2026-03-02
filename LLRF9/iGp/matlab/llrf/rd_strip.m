% rd_strip          - Read StripTool data dump
%
% data = rd_strip(file, skip)
%
%   file - input file name
%   skip - optional number of lines to skip. Set to -1 to autoskip BadVal
%
% Copyright (c) 2008-2021 Dimtel, Inc., All Rights Reserved
%
% $Id: rd_strip.m,v 1.1 2021/11/05 07:56:39 dim Exp $
% $Date: 2021/11/05 07:56:39 $
% $Author: dim $
% $Revision: 1.1 $
% $Log: rd_strip.m,v $
% Revision 1.1  2021/11/05 07:56:39  dim
% Initial commit
%

function data = rd_strip(file, skip)

data.type = 'strip';

[fid, msg] = fopen(file, 'r');
if (fid == -1)
  error(['File ', file, ' cannot be opened: ', msg]);
end
data.header = fgetl(fid);

% Parse the header
u = strfind(data.header, 9); % Look for tabs
for k=1:length(u)-1
  data.chan{k} = data.header(u(k)+1:u(k+1)-1);
end
fclose(fid);

if (nargin == 1)
  skip = -1;
end

if skip == -1
  [stat, res] = system(sprintf('grep -n BadVal %s|tail -1|cut -f1 -d:', file));
  if isempty(res)
    skip=0;
  else
    skip = str2num(res)-1; % Account for the header
  end
  disp(sprintf('Skipping %d lines', skip));
end

% Cut data section out
tmpf = tempname;
system(sprintf('tail -n +%d %s > %s', skip+2, file, tmpf));

% Now separate into timestamps and signals
tmp_ts  = tempname;
tmp_sig = tempname;
system(sprintf('cut -f1 %s > %s', tmpf, tmp_ts));
system(sprintf('cut -f2- %s > %s', tmpf, tmp_sig));

data.val = load(tmp_sig);
fid = fopen(tmp_ts, 'r');
ts  = fread(fid, inf, 'uchar');
fclose(fid);
x = char(ts);
u = find(ts==10, 1);
xx = reshape(x, u, length(x)/u)';
xx = xx(:,1:end-1);
data.ts = xx;

data.t_raw = datenum(xx, 'mm/dd/yyyy HH:MM:SS.FFF');
data.t = (data.t_raw-data.t_raw(end))*3600*24;

% Remove temporary files
system(sprintf('rm %s %s %s', tmpf, tmp_ts, tmp_sig));

% Compute sampling rate
data.Ts = mean(diff(data.t));
