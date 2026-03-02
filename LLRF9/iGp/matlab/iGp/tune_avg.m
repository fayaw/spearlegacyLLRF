% tune_avg          - Average multiple closed-loop records for tune fitting
%
% Copyright (c) 2009 Dimtel, Inc., All Rights Reserved
%
% $Id: tune_avg.m,v 1.2 2011/12/16 12:30:47 dim Exp $
% $Date: 2011/12/16 12:30:47 $
% $Author: dim $
% $Revision: 1.2 $
% $Log: tune_avg.m,v $
% Revision 1.2  2011/12/16 12:30:47  dim
% Cleanup, support of 8/12 bit systems, bunch tunes measurement updates
%
% Revision 1.1.1.1  2010/10/05 16:43:01  dim
% Initial import of iGp12
%
%

h = spectrum.welch('hamming', Ns);

for k=1:Md
  cd(dirs(k,:));
  disp(['Processing ', dirs(k,:)]);
  iGp_load_data
  n = 1;
  if (k == 1)
    Fs = rf_freq*1e6/ring_size/downsamp;
  end
  for m=nb;
    Hpsd = msspectrum(h, data(:,m) - mean(data(:,m)), 'Fs', Fs);
    if (k == 1)
      S(:,n) = Hpsd.Data;
    else
      S(:,n) = S(:,n) + Hpsd.Data;
    end
    n = n + 1;
  end
  mv(k,:) = mean(data);
  if (k == Md)
    disp('Loading prm');
    load prm
    prm.freq = Hpsd.Frequencies;
  end
  cd('..');
end
n = n - 1;
mv = mean(mv);
