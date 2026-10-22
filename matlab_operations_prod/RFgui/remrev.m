% Remove revolution harmonics
function dat = remrev(out_data, Tsample,frev);

%frev = 238e6/1746;
N = round(1/Tsample/frev);
M = floor(length(out_data)/N);

dat = reshape(out_data(1:M*N), N, M);

for k=1:N;
  dat(k, :) = dat(k,:) - mean(dat(k,:));
end
dat = dat(:);
