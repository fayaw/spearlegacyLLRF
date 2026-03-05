% iGp_local         - Local configuration information
%
% Edit this file to configure PV root and DCCT channel, 
%
%
% Copyright (c) 2014 Dimtel, Inc., All Rights Reserved
%
% $Id: iGp_local.m,v 1.8 2020/02/11 18:13:29 dim Exp $
% $Date: 2020/02/11 18:13:29 $
% $Author: dim $
% $Revision: 1.8 $
% $Log: iGp_local.m,v $
% Revision 1.8  2020/02/11 18:13:29  dim
% Added SSRF DCCT
%
% Revision 1.7  2018/12/07 08:30:08  dim
% Added Aichi DCCT
%
% Revision 1.6  2018/08/08 21:43:41  dim
% Labeled DCCT channels
%
% Revision 1.5  2017/06/27 21:17:25  dim
% A few accumulated DCCT channels
%
% Revision 1.4  2015/12/01 19:53:27  dim
% Standard lab setup
%
% Revision 1.3  2015/12/01 19:52:46  dim
% *** empty log message ***
%
% Revision 1.2  2014/03/28 00:01:36  dim
% Root definition is mandatory now
%
% Revision 1.1  2014/03/27 23:33:45  dim
% Initial commit
%

function prm = iGp_local

prm.root = 'IGPF';

%prm.dcct = 'cmm:beam_current'; % ALS
%prm.dcct = 'MDIZ3T5G:current'; % BESSY-II
%prm.dcct = 'SR11BCM01:CURRENT_MONITOR'; % ASLS
%prm.dcct = 'BBQB:Z:AD5644:V:CH7'; % BESSY booster
%prm.dcct = 'R3O:BI:DCCT:current'; % BEPC-II
%prm.dcct = 'SRC01-DI-DCCT1:getDcctCurrent'; % SESAME
%prm.dcct = 'NUSR:S_DCM_MON'; % Aichi SR
%prm.dcct = 'SR-BI:DCCT:CURRENT'; % SSRF
