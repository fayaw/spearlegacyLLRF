% iGp_load_data     - Load iGp data file
%
% Copyright (c) 2008 Dimtel, Inc., All Rights Reserved
%
% $Id: iGp_load_data.m,v 1.1.1.1 2010/10/05 16:43:02 dim Exp $
% $Date: 2010/10/05 16:43:02 $
% $Author: dim $
% $Revision: 1.1.1.1 $
% $Log: iGp_load_data.m,v $
% Revision 1.1.1.1  2010/10/05 16:43:02  dim
% Initial import of iGp12
%
% Revision 1.1  2008/01/05 19:53:38  dim
% Changes to avoid reliance on sort_bunches and rms() from the LFB suite
%
%

%
% This is a replacement for sort_bunches from the standard LFB tools suite.
% This script skips bunch sorting and data trimming which is unnecessary for
% the iGp data.
%
load gd
data=bunches(2:end, :);
[M, N]=size(data);
