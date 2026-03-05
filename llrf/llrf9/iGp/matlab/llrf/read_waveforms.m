% read_waveforms    - Read out 4 acquisition channels

function data = read_waveforms(sys, dev)

base=[sys, ':', dev, ':'];

pvs={'ACQ:ADC0'; 'ACQ:ADC1'; 'ACQ:ADC2'; 'ACQ:ADC3'; 'ACQ:TSC'};
pvs = strcat(base, pvs);
vals = lcaGet(pvs);

for k=1:4
  data.chan(:,k) = vals(k,:)';
end
data.t = vals(5,:)';
data.sel = lcaGet([base, 'ACQ:SEL'], 1, 'byte');
data.sys = sys;
data.dev = dev;

% Collect calibration information
pvs = {'FSAMP'; 'REF:DDS:FREQ'; 'ACQ:POSTLEN'};

k = 1;
for ch=0:2
  pvs = [pvs; sprintf('CH%d:SCALE', ch)];
  pvs = [pvs; sprintf('CH%d:PH_OFFSET', ch)];
  pvs = [pvs; sprintf('CH%d:HWPH', ch)];
  pvc{k}   = sprintf('CH%d:PWRSW', ch);
  pvc{k+1} = sprintf('CH%d:UNITS', ch);
  pvc{k+2} = sprintf('CH%d:LABEL', ch);
  k = k + 3;
end
pvs = strcat(base, pvs);
vals = lcaGet(pvs);

data.fs      = vals(1)*1e6;
data.fif     = vals(2)*1e3;
data.postlen = vals(3);
data.theta = data.fif / data.fs * 2 * pi;
[M N] = rat(data.fif/data.fs);
data.nfilt = N;

data.scale     = vals(4:3:12);
data.ph_offset = vals(5:3:12);
data.hwph      = vals(6:3:12);

strings = lcaGet(strcat(base, pvc(:)));
data.pwrsw=strings(1:3:end);
data.units=strings(2:3:end);
data.labels=strings(3:3:end);

% Place trigger point at 0
data.t = data.t - data.t(end-data.postlen);

% Plot
if (nargout == 0)
  plot_waveforms(data);
end
