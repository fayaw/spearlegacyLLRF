% rf_prm            - Generates RF configuration parameters

function rf = rf_prm(machine)

switch (machine)
  case 'als'
    rf = [];
  case 'dafne+'
    rf = [];
  case 'dafne-'
    rf = [];
  case 'dafne1+'
    rf = [];
  case 'dafne1-'
    rf = [];
  % DAFNE with strong RF focusing: 10 MV gap voltage
  case 'dafne_strong'
    rf = [];
  case 'bessy'
    rf = [];
  case {'pepii-HER', 'pepii-HER-afs', 'pepii-LAB'}
    rf.Rs   = 3.73e6;	        % Shunt impedance, Ohms
    rf.Q    = 32e3;	        % Cavity Q
    rf.NN   = 3318;	        % Last bucket before the gap
    rf.Beta = 3.6;		% Coupling factor changed from 3.9 04-19-2007
    rf.hcomb = 72;		% Comb filter sampling harmonic

    rf.Vg = 13.4e6;	  % Gap voltage, V
    rf.Uo = 3.55e6;	  % Energy loss per turn, V
    rf.ws = 2*pi*5.95e3;  % Synchrotron frequency, rad/s
    rf.Nc = 28;	          % Number of active cavities
    rf.Np = 0;		  % Number of parked cavities
    rf.C  = 1.875e5;	  % HOM loss factor, V

    % RF station setup
    rf.st(1).name = 'HR41';
    rf.st(1).Nc   = 2;
    rf.st(2).name = 'HR46';
    rf.st(2).Nc   = 2;
    rf.st(3).name = 'HR81';
    rf.st(3).Nc   = 4;
    rf.st(4).name = 'HR83';
    rf.st(4).Nc   = 4;
    rf.st(5).name = 'HR85';
    rf.st(5).Nc   = 4;
    rf.st(6).name = 'HR21';
    rf.st(6).Nc   = 2;
    rf.st(7).name = 'HR22';
    rf.st(7).Nc   = 2;
    rf.st(8).name = 'HR23';
    rf.st(8).Nc   = 2;
    rf.st(9).name = 'HR24';
    rf.st(9).Nc   = 2;
    rf.st(10).name = 'HR25';
    rf.st(10).Nc   = 2;
    rf.st(11).name = 'HR26';
    rf.st(11).Nc   = 2;
    for k=1:length(rf.st)
      rf.st(k).parked = 0;
    end

    rf.timestamp = '24-nov-2003';
  case {'pepii-LER', 'pepii-LER-afs'}
    rf.Rs   = 3.73e6;	        % Shunt impedance, Ohms
    rf.Q    = 32e3;	        % Cavity Q
    rf.NN   = 3318;	        % Last bucket before the gap
    rf.Beta = 3.6;		% Coupling factor changed from 3.9 04-19-2007
    rf.hcomb = 72;		% Comb filter sampling harmonic

    rf.Vg = 3e6;	% Gap voltage, V
    rf.Uo = 0.65e6;	% Energy loss per turn, V
    rf.ws = 2*pi*3.5e3; % Synchrotron frequency, rad/s
    rf.C  = 117900;	% HOM loss factor, V

    % RF station setup
    rf.st(1).name = 'LR42';
    rf.st(1).Nc   = 2;
    rf.st(2).name = 'LR43';
    rf.st(2).Nc   = 2;
    rf.st(3).name = 'LR44';
    rf.st(3).Nc   = 2;
    rf.st(4).name = 'LR45';
    rf.st(4).Nc   = 2;
    for k=1:length(rf.st)
      rf.st(k).parked = 0;
    end

    rf.timestamp = '24-nov-2003';
  case {'spear3'}
      % entered 03-dec-2003  jjs
      % data taken either from CDR
      %  or extrapolated from pepii data
    rf.Rs   = 3.73e6;	        % Shunt impedance, Ohms (pepii)
    rf.Q    = 32e3;	        % Cavity Q (pepii)
    rf.NN   = 279;	        % Last bucket before the gap
    rf.Beta = 3.6;		% Coupling factor changed from 3.9 04-19-2007
    % rf.hcomb in pepii is a multiple of the revolution harmonic
    %  fs = rf.hcomb*(fRf/h)
    %  for spear3, this multiple is 8
    rf.hcomb = 8;		% Comb filter sampling harmonic

    rf.Vg = 3.2e6;	% Gap voltage, V
    rf.Uo = 0.912e6;	% Energy loss per turn, V
    rf.ws = 2*pi*.008*(476.3e6)/372; % Synchrotron frequency, rad/s
    rf.C  = 117900;	% HOM loss factor, V (pepii)

    % RF station setup
    rf.st(1).name = 'SRF1';
    rf.st(1).Nc   = 4;
    for k=1:length(rf.st)
      rf.st(k).parked = 0;
    end

    rf.timestamp = '03-dec-2003';
  otherwise
    rf.error = ['Unknown machine: ', machine];
    return;
end



