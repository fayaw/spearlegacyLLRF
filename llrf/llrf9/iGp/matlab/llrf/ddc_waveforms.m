% ddc_waveforms     - Downconvert waveforms given phase advance per sample, filter

function data = ddc_waveforms(data);

[M, N] = size(data.chan);

for k=1:N
  [I, Q] = reconstruct(data.chan(:,k), data.theta);
  baseband = filter(ones(data.nfilt, 1), data.nfilt, I - Q*i);
  data.iq(:,k) = baseband(data.nfilt:end);
end
data.t_iq = data.t(1:end-data.nfilt);

% Apply calibrations and phase offsets
ph_ref  = angle(data.iq(:,4)); % reference channel

if isfield(data, 'hwph')
  ph_off = data.ph_offset + data.hwph;
else
  ph_off = data.ph_offset;
end

for ch=1:3
  data.ph(:, ch) = (angle(data.iq(:, ch)) - ph_ref)/pi*180 + ph_off(ch);
  data.amp(:, ch) = abs(data.iq(:, ch));
  if strcmp(data.pwrsw{ch}, 'Power')
    data.amp(:, ch) = data.amp(:,ch).^2;
  end
  data.amp(:, ch) = data.amp(:, ch) * data.scale(ch);

  if (min(data.ph(:, ch)) > 180) data.ph(:,ch) = data.ph(:,ch) - 360; end
  if (max(data.ph(:, ch)) < -180) data.ph(:,ch) = data.ph(:,ch) + 360; end
end
