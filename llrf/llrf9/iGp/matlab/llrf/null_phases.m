% null_phases       - Null I/Q readbacks for a given module

function null_phases(sys, brd);

base=[sys, ':', brd, ':'];

phase_pvs = {'CH0:PHASE'; 'CH1:PHASE'; 'CH2:PHASE'};
offset_pvs = {'CH0:PH_OFFSET'; 'CH1:PH_OFFSET'; 'CH2:PH_OFFSET'};

% Read out phases
phases = lcaGet(strcat(base, phase_pvs));

% Read out offsets
offsets = lcaGet(strcat(base, offset_pvs));

offsets = offsets - phases;

u=find(offsets > 180); offsets(u) = offsets(u) - 360;
u=find(offsets <= -180); offsets(u) = offsets(u) + 360;

lcaPut(strcat(base, offset_pvs), offsets);
