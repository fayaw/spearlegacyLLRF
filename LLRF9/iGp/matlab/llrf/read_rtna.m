% read_rtna         - Read out real-time network analyzer

function data = read_rtna(sys, dev)

base=[sys, ':', dev, ':'];

pvs  = {'REF:DDS:FREQ'; 'FSAMP'; ...
        'ROT:P_OL:GAIN'; 'ROT:P_OL:PHASE'; 'ROT:P_CL:GAIN'; 'ROT:P_CL:PHASE'; ...
        'ROT:I_OL:GAIN'; 'ROT:I_OL:PHASE'; 'ROT:I_CL:GAIN'; 'ROT:I_CL:PHASE'; ...
        'FB:P_SHIFT'; 'FB:I_SHIFT'};
pvs  = strcat(base, pvs);
vals = lcaGet(pvs);

data.f_if = 1e3*vals(1);
data.f_s  = 1e6*vals(2);
data.f_lo = 4*data.f_s;
data.wrf  = (data.f_if + data.f_lo)*2*pi;
data.rot.gn = vals(3);    data.rot.ph = vals(4);
data.rot_cl.gn = vals(5); data.rot_cl.ph = vals(6);
data.roti.gn = vals(7);    data.roti.ph = vals(8);
data.roti_cl.gn = vals(9); data.roti_cl.ph = vals(10);
data.shift.prop = vals(11);
data.shift.int  = vals(12);

pvs={'RTNA:MAG1'; 'RTNA:MAG2'; 'RTNA:PHASE1'; 'RTNA:PHASE2';
     'RTNA:FREQ1'; 'RTNA:FREQ2'};
pvs = strcat(base, pvs);
data.to   = lcaGet([base, 'RTNA:INPUT']);
vals = lcaGet(pvs);

data.mag   = [vals(1,:) vals(2,:)];
data.phase = [vals(3,:) vals(4,:)];
data.freq  = [vals(5,:) vals(6,:)]*1e3 + data.wrf/2/pi;
data.cycles = lcaGet([base, 'RTNA:ASUB.VALO']);

data.H = 10.^(data.mag/20).*exp(i*data.phase*pi/180);

% Figure out conversion scale from measured magnitudes to dB/Hz
bw_factor = 0.4425*2; % CIC 3 dB bandwidth, double sided
data.bw = data.f_s/2./data.cycles*bw_factor;
data.mag_corr = data.mag - 20*log10(data.bw);

% Plot
if (nargout == 0)
  plot_rtna(data);
end
