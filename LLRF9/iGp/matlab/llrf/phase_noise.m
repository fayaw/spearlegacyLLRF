% phase_noise       - Compute and (optionally) plot phase noise spectra

function [L, freq] = phase_noise(phase, Fs, Nfft)

if (nargin == 2)
  Nfft = 1024;
end

% Remove DC
phase = phase - mean(phase);

M = floor(length(phase)/Nfft);
  
x = reshape(phase(1:M*Nfft), Nfft, M);

% Math from HP phase noise seminar, page 52
% http://www.thegleam.com/ke5fx/HP_PN_seminar.pdf
% S_phi(f) = phi_rms^2(f)
% L(f) = 1/2 S_phi(f) (dBc)
% Normalize by frequency bin size to get dBc/Hz
% Results are the same as pwelch()/2 with proper sampling
% frequency.

X = 2*abs(fft(x))/Nfft;

avg_vec = ones(M, 1)/M;
S_phi = (X.^2*avg_vec)/2; % Divide by 2 to go to RMS
S_phi = S_phi(1:Nfft/2);
freq = [0:(Nfft/2-1)]*Fs/Nfft;

% Now scale per frequency bin, adjust for SSB
bin = Fs/Nfft;
L = S_phi / bin / 2;

% Drop DC and first two (leaky) points
freq = freq(4:end);
L    = L(4:end);

if (nargout == 0)
  clf;
  semilogx(freq, 10*log10(L));
  xlabel('Frequency (Hz)');
  ylabel('dBc/Hz)');
end
