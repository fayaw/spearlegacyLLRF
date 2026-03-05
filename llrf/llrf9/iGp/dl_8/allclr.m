% A script for generating the colors.list content
%
% Copyright (c) 2006 Dimtel, Inc., All Rights Reserved
%
% $Id: allclr.m,v 1.1 2006/12/06 19:38:03 dim Exp $
% $Date: 2006/12/06 19:38:03 $
% $Author: dim $
% $Revision: 1.1 $
% $Log: allclr.m,v $
% Revision 1.1  2006/12/06 19:38:03  dim
% Added EDM displays and colors.list as well as Octave tools for generating
% colors.list
%
%

clear

fid = fopen("allclr.out", "w");
xxx = [1 1 1];
idx = colorgen(fid, 74*xxx, 255*xxx, 15, 1, "gray");
xxx = [1 0 0];
idx = colorgen(fid, 95*xxx, 255*xxx, 8, idx + 1, "red");
xxx = [0 1 0];
idx = colorgen(fid, 95*xxx, 255*xxx, 8, idx + 1, "green");
xxx = [0 0 1];
idx = colorgen(fid, 95*xxx, 255*xxx, 4, idx + 1, "blue");
xxx = [1 1 0];
idx = colorgen(fid, 95*xxx, 255*xxx, 4, idx + 1, "yellow");
xxx = [0 1 1];
idx = colorgen(fid, 95*xxx, 255*xxx, 4, idx + 1, "cyan");
xxx = [1 0 1];
idx = colorgen(fid, 95*xxx, 255*xxx, 4, idx + 1, "purple");
xxx = [1 .86 .86];
idx = colorgen(fid, 95*xxx, 255*xxx, 8, idx + 1, "rose");
xxx = [.86 1 .86];
idx = colorgen(fid, 95*xxx, 255*xxx, 8, idx + 1, "pastel");
xxx = [.86 .86 1];
idx = colorgen(fid, 95*xxx, 255*xxx, 8, idx + 1, "lilac");
xxx = [1 1 .86];
idx = colorgen(fid, 95*xxx, 255*xxx, 8, idx + 1, "beige");

fclose(fid);
