% plot_rtna         - Plot real-time network analyzer data

function [freq mag phase] = plot_rtna(data)

% Find the gap
u=512;

freq = data.freq(:); mag = data.mag(:); phase = data.phase(:);
freq  = [freq(1:u); NaN; freq(u+1:end)] - data.wrf/2/pi;
mag   = [mag(1:u); NaN; data.mag(u+1:end)];
phase = [phase(1:u); NaN; data.phase(u+1:end)];

if any(isfinite(phase)) == 0
  phase_on = 1;
else
  phase_on = 2;
end

clf
subplot(phase_on, 1, 1);
set(gca, 'fontsize', 14);
plot(freq/1e3, mag, '-', 'linewidth', 2);
xlabel('Frequency offset (kHz)');
ylabel('Magnitude (dB)');
grid;

if phase_on==2
  ylabel('Gain (dB)');
  subplot(2, 1, 2);
  set(gca, 'fontsize', 14);
  plot(freq/1e3, phase, 'r', 'linewidth', 2);
  xlabel('Frequency offset (kHz)');
  ylabel('Phase (degrees)');
  grid;
end

if (nargout == 0)
  clear freq mag phase
end
