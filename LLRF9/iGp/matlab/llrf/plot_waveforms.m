% plot_waveforms    - Plot 4 acquisition channels
%
% data = plot_waveforms(data, flag)
%
% data - Waveform readout from read_waveforms() or ddc_waveforms()
% flag - Set to 1 for downconverted waveforms to plot the reference amp/phase

% Copyright (c) 2012-2019 Dimtel, Inc., All Rights Reserved
%
% $Id: plot_waveforms.m,v 1.1 2021/11/05 07:56:39 dim Exp $
% $Date: 2021/11/05 07:56:39 $
% $Author: dim $
% $Revision: 1.1 $
% $Log: plot_waveforms.m,v $
% Revision 1.1  2021/11/05 07:56:39  dim
% Initial commit
%
%


function data = plot_waveforms(data, flag)

if nargin == 1
  flag = 0;
end

if isfield(data, 'labels')
  names = data.labels;
else
  names = {'ADC0'; 'ADC1'; 'ADC2'};
end

tit{1} = names{1};
tit{2} = names{2};

switch(data.sel)
  case 0
    tit{3} = names{3};
    tit{4} = 'ADC3';
  case 1
    tit{3} = 'CAV_SUM';
    tit{4} = 'ERR';
  case 2
    tit{3} = 'ERR';
    tit{4} = 'KLY';
  case 3
    tit{3} = 'ERR';
    tit{4} = 'ADC3';
end

for k=1:4
  data.title{k} = tit{k};
end

clf
if isfield(data, 'iq')
  % After I/Q processing
  if flag == 1
    ch_max = 4;
    data.amp(:,4) = abs(data.iq(:,4));
    data.ph(:,4)  = angle(data.iq(:,4))/pi*180;
    data.units{4} = 'ADC counts';
  else
    ch_max = 3;
  end

  for k=1:ch_max
    subplot(ch_max, 2, 2*k-1);
    plot(data.t_iq, data.amp(:,k), 'linewidth', 2); grid;
    xlabel('Time (\mus)');
    ylabel(data.units{k});
    title(data.title{k});
    subplot(ch_max, 2, 2*k);
    plot(data.t_iq, data.ph(:,k), 'r', 'linewidth', 2); grid;
    xlabel('Time (\mus)');
    ylabel('Degrees');
    title(data.title{k});
  end
else
  for k=1:4
    subplot(2, 2, k);
    plot(data.t, data.chan(:,k)); grid
    xlabel('Time (\mus)');
    ylabel('Counts');
    title(data.title{k});
  end
end
