% This function prints color definitions in colors.list format
% at a requested number of step between two colors
%
% Copyright (c) 2006 Dimtel, Inc., All Rights Reserved
%
% $Id: colorgen.m,v 1.1.1.1 2010/10/05 16:42:44 dim Exp $
% $Date: 2010/10/05 16:42:44 $
% $Author: dim $
% $Revision: 1.1.1.1 $
% $Log: colorgen.m,v $
% Revision 1.1.1.1  2010/10/05 16:42:44  dim
% Initial import of iGp12
%
% Revision 1.1  2006/12/06 19:38:03  dim
% Added EDM displays and colors.list as well as Octave tools for generating
% colors.list
%
%

function maxidx = colorgen(fid, dark, bright, steps, start, name);

steps = steps - 1;
for k=0:steps;
  clr = (bright-dark)*k/steps + dark;
  fprintf(fid, "static %3d ""%s-%d""\t{ 0x%02x 0x%02x 0x%02x }\n", k + start, ...
         name, k+1, round(clr(1)), round(clr(2)), round(clr(3)));
end
maxidx = k + start;
