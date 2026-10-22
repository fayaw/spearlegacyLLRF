% rfcfg             - A function to set up a virtual RF system
%
% function prm = rfcfg(ring, config, fill)
%
% ring   - Ring name, 'HER' or 'LER'
% config - Station voltages, phases, on/off info
% fill   - Fill name, e.g. '1702by2'

function prm = rfcfg(machine, config, fill);

prm           = sys_prm(machine);
prm.rf.fillnm = fill;

switch (machine)
  case {'pepii-HER', 'pepii-HER-afs'}
    % Nominal cavity parking frequencies
    wp1 = prm.accel.wrf+2.5*prm.accel.w0; % Parked cavity
    wp2 = prm.accel.wrf-2.5*prm.accel.w0; % Parked cavity
    switch (config)
      case '6station'
        % 6 stations running, 4-1 and 12-6 parked
        % Voltages:
        % 8-1  1750
        % 8-3  2100
	% 8-5  2100
        % 12-1 1950
        % 12-3 2000
        % 12-5 1300

        prm.rf.st(1).parked = 1;
        prm.rf.st(8).parked = 1;

        prm.rf.st(1).Vst = 0;     prm.rf.st(1).Pst = 0;
        prm.rf.st(2).Vst = 1.75e6; prm.rf.st(2).Pst = -6;
        prm.rf.st(3).Vst = 2.1e6; prm.rf.st(3).Pst = 0;
        prm.rf.st(4).Vst = 2.1e6; prm.rf.st(4).Pst = 0;
        prm.rf.st(5).Vst = 1.95e6; prm.rf.st(5).Pst = -6;
        prm.rf.st(6).Vst = 2.0e6; prm.rf.st(6).Pst = 0.7;
        prm.rf.st(7).Vst = 1.3e6; prm.rf.st(7).Pst = 7.5;
        prm.rf.st(8).Vst = 0; prm.rf.st(8).Pst = 0;

        prm.accel.Io = 1.125;
      case '7station'
        % 7 stations running, 4-1 parked
        % Voltages:
        % 8-1  1900
        % 8-3  2200
	% 8-5  2300
        % 12-1 1900
        % 12-3 2500
        % 12-5 1300
        % 12-6 1300

        prm.rf.st(1).parked = 1;

        prm.rf.st(1).Vst = 0;     prm.rf.st(1).Pst = 0;
        prm.rf.st(2).Vst = 1.9e6; prm.rf.st(2).Pst = -6;
        prm.rf.st(3).Vst = 2.2e6; prm.rf.st(3).Pst = -1;
        prm.rf.st(4).Vst = 2.3e6; prm.rf.st(4).Pst = -1.5;
        prm.rf.st(5).Vst = 1.9e6; prm.rf.st(5).Pst = -5;
        prm.rf.st(6).Vst = 2.5e6; prm.rf.st(6).Pst = -3;
        prm.rf.st(7).Vst = 1.3e6; prm.rf.st(7).Pst = 7;
        prm.rf.st(8).Vst = 1.3e6; prm.rf.st(8).Pst = 3;

        prm.accel.Io = 1.25;
      case '6station_13.4'
        % 6 stations running, 4-1 and 12-3 parked
        % Voltages:
        % 8-1  2500
        % 8-3  2800
	% 8-5  2800
        % 12-1 2400
        % 12-5 1450
        % 12-6 1450

        prm.rf.st(1).parked = 1;
	prm.rf.st(8).parked = 1;

        prm.rf.st(1).Vst = 0;     prm.rf.st(1).Pst = 0;
        prm.rf.st(2).Vst = 2.2e6; prm.rf.st(2).Pst = -4;
        prm.rf.st(3).Vst = 2.2e6; prm.rf.st(3).Pst = 5;
        prm.rf.st(4).Vst = 2.7e6; prm.rf.st(4).Pst = .5;
        prm.rf.st(5).Vst = 2.2e6; prm.rf.st(5).Pst = -1.3;
        prm.rf.st(6).Vst = 2.7e6; prm.rf.st(6).Pst = 0.5;
        prm.rf.st(7).Vst = 1.4e6; prm.rf.st(7).Pst = 14;
        prm.rf.st(8).Vst = 0; prm.rf.st(8).Pst = 0;
        
        prm.accel.Io = 1.075;
      case '8station'
        % 8 station running (from J. Seeman)
        % Voltages:
	% 4-1  1200
        % 8-1  2400
        % 8-3  2400
	% 8-5  2400
        % 12-1 2400
	% 12-3 2400
        % 12-5 1200
        % 12-6 1200

	pp = -10.8;
        prm.rf.st(1).Vst = 1.2e6; prm.rf.st(1).Pst = 0;
        prm.rf.st(2).Vst = 2.4e6; prm.rf.st(2).Pst = pp;
        prm.rf.st(3).Vst = 2.4e6; prm.rf.st(3).Pst = pp;
        prm.rf.st(4).Vst = 2.4e6; prm.rf.st(4).Pst = pp;
        prm.rf.st(5).Vst = 2.4e6; prm.rf.st(5).Pst = pp;
        prm.rf.st(6).Vst = 2.4e6; prm.rf.st(6).Pst = pp;
        prm.rf.st(7).Vst = 1.2e6; prm.rf.st(7).Pst = 0;
        prm.rf.st(8).Vst = 1.2e6; prm.rf.st(8).Pst = 0;
        
        prm.accel.Io = 1.6;
      case '9station'
        % 9 station running (from J. Seeman)
        % Voltages:
	% 4-1  1400
        % 8-1  1400
	% 8-2  1400
        % 8-3  2800
	% 8-5  2800
        % 12-1 2800
	% 12-3 2800
        % 12-5 1400
        % 12-6 1400

        % RF station setup
        prm.rf.st(1).name = 'HR41';
        prm.rf.st(1).Nc   = 2;
        prm.rf.st(2).name = 'HR81';
        prm.rf.st(2).Nc   = 2;
        prm.rf.st(3).name = 'HR82';
        prm.rf.st(3).Nc   = 2;
        prm.rf.st(4).name = 'HR83';
        prm.rf.st(4).Nc   = 4;
        prm.rf.st(5).name = 'HR85';
        prm.rf.st(5).Nc   = 4;
        prm.rf.st(6).name = 'HR21';
        prm.rf.st(6).Nc   = 4;
        prm.rf.st(7).name = 'HR23';
        prm.rf.st(7).Nc   = 4;
        prm.rf.st(8).name = 'HR25';
        prm.rf.st(8).Nc   = 2;
        prm.rf.st(9).name = 'HR26';
        prm.rf.st(9).Nc   = 2;
        for k=1:length(prm.rf.st)
          prm.rf.st(k).parked = 0;
        end

        prm.rf.st(1).Vst = 1.4e6; prm.rf.st(1).Pst = 0;
        prm.rf.st(2).Vst = 1.4e6; prm.rf.st(2).Pst = 0;
        prm.rf.st(3).Vst = 1.4e6; prm.rf.st(3).Pst = 0;
        prm.rf.st(4).Vst = 2.8e6; prm.rf.st(4).Pst = -9.5;
        prm.rf.st(5).Vst = 2.8e6; prm.rf.st(5).Pst = -9.5;
        prm.rf.st(6).Vst = 2.8e6; prm.rf.st(6).Pst = -9.5;
        prm.rf.st(7).Vst = 2.8e6; prm.rf.st(7).Pst = -9.5;
        prm.rf.st(8).Vst = 1.4e6; prm.rf.st(8).Pst = 0;
        prm.rf.st(9).Vst = 1.4e6; prm.rf.st(9).Pst = 0;
        
        prm.accel.Io = 1.8;
      case '10station'
        % 10 stations running (from J. Seeman)
        % Voltages:
	% 4-1  1600
        % 8-1  1600
	% 8-2  1600
        % 8-3  3200
	% 8-5  3200
        % 12-1 1600
	% 12-2 1600
	% 12-3 3200
        % 12-5 1600
        % 12-6 1600

        % RF station setup
        prm.rf.st(1).name = 'HR41';
        prm.rf.st(1).Nc   = 2;
        prm.rf.st(2).name = 'HR81';
        prm.rf.st(2).Nc   = 2;
        prm.rf.st(3).name = 'HR82';
        prm.rf.st(3).Nc   = 2;
        prm.rf.st(4).name = 'HR83';
        prm.rf.st(4).Nc   = 4;
        prm.rf.st(5).name = 'HR85';
        prm.rf.st(5).Nc   = 4;
        prm.rf.st(6).name = 'HR21';
        prm.rf.st(6).Nc   = 2;
        prm.rf.st(7).name = 'HR22';
        prm.rf.st(7).Nc   = 2;
        prm.rf.st(8).name = 'HR23';
        prm.rf.st(8).Nc   = 4;
        prm.rf.st(9).name = 'HR25';
        prm.rf.st(9).Nc   = 2;
        prm.rf.st(10).name = 'HR26';
        prm.rf.st(10).Nc   = 2;
        for k=1:length(prm.rf.st)
          prm.rf.st(k).parked = 0;
        end

        prm.rf.st(1).Vst = 1.6e6; prm.rf.st(1).Pst = 0;
        prm.rf.st(2).Vst = 1.6e6; prm.rf.st(2).Pst = 0;
        prm.rf.st(3).Vst = 1.6e6; prm.rf.st(3).Pst = 0;
        prm.rf.st(4).Vst = 3.2e6; prm.rf.st(4).Pst = -8.6;
        prm.rf.st(5).Vst = 3.2e6; prm.rf.st(5).Pst = -8.6;
        prm.rf.st(6).Vst = 1.6e6; prm.rf.st(6).Pst = 0;
        prm.rf.st(7).Vst = 1.6e6; prm.rf.st(7).Pst = 0;
        prm.rf.st(8).Vst = 3.2e6; prm.rf.st(8).Pst = -8.6;
        prm.rf.st(9).Vst = 1.6e6; prm.rf.st(9).Pst = 0;
        prm.rf.st(10).Vst = 1.6e6; prm.rf.st(10).Pst = 0;
        
        prm.accel.Io = 2;
      case '11station'
        % 11 stations running (from J. Seeman)
        % Voltages:
	% 4-1  1700
        % 8-1  1700
	% 8-2  1700
        % 8-3  1700
	% 8-4  1700
	% 8-5  3400
        % 12-1 1700
	% 12-2 1700
	% 12-3 3400
        % 12-5 1700
        % 12-6 1700

        % RF station setup
        prm.rf.st(1).name = 'HR41';
        prm.rf.st(1).Nc   = 2;
        prm.rf.st(2).name = 'HR81';
        prm.rf.st(2).Nc   = 2;
        prm.rf.st(3).name = 'HR82';
        prm.rf.st(3).Nc   = 2;
        prm.rf.st(4).name = 'HR83';
        prm.rf.st(4).Nc   = 2;
        prm.rf.st(5).name = 'HR84';
        prm.rf.st(5).Nc   = 2;
        prm.rf.st(6).name = 'HR85';
        prm.rf.st(6).Nc   = 4;
        prm.rf.st(7).name = 'HR21';
        prm.rf.st(7).Nc   = 2;
        prm.rf.st(8).name = 'HR22';
        prm.rf.st(8).Nc   = 2;
        prm.rf.st(9).name = 'HR23';
        prm.rf.st(9).Nc   = 4;
        prm.rf.st(10).name = 'HR25';
        prm.rf.st(10).Nc   = 2;
        prm.rf.st(11).name = 'HR26';
        prm.rf.st(11).Nc   = 2;
        for k=1:length(prm.rf.st)
          prm.rf.st(k).parked = 0;
        end

	pp = -7.8;
        prm.rf.st(1).Vst = 1.7e6; prm.rf.st(1).Pst = 0;
        prm.rf.st(2).Vst = 1.7e6; prm.rf.st(2).Pst = 0;
        prm.rf.st(3).Vst = 1.7e6; prm.rf.st(3).Pst = 0;
        prm.rf.st(4).Vst = 1.7e6; prm.rf.st(4).Pst = 0;
        prm.rf.st(5).Vst = 1.7e6; prm.rf.st(5).Pst = 0;
        prm.rf.st(6).Vst = 3.4e6; prm.rf.st(6).Pst = pp;
        prm.rf.st(7).Vst = 1.7e6; prm.rf.st(7).Pst = 0;
        prm.rf.st(8).Vst = 1.7e6; prm.rf.st(8).Pst = 0;
        prm.rf.st(9).Vst = 3.4e6; prm.rf.st(9).Pst = pp;
        prm.rf.st(10).Vst = 1.7e6; prm.rf.st(10).Pst = 0;
        prm.rf.st(11).Vst = 1.7e6; prm.rf.st(11).Pst = 0;
        
        prm.accel.Io = 2.2;
    end
  case {'pepii-LER', 'pepii-LER-afs'}
    switch (config)
      case '3station'
        % 3 stations running
        % Voltages:
        % 4-3 1000
        % 4-4 1000
        % 4-5 1200

        prm.rf.st(1).Vst = 1e6;   prm.rf.st(1).Pst = 0;
        prm.rf.st(2).Vst = 1e6;   prm.rf.st(2).Pst = 0;
        prm.rf.st(3).Vst = 1.2e6; prm.rf.st(3).Pst = 0;

        prm.accel.Io = 1.7;
      case '2station'
        % 2 stations running, 4-3 parked
        % Voltages:
        % 4-4 1650
        % 4-5 1650

	prm.rf.st(1).parked = 1;

        prm.rf.st(1).Vst = 0;     prm.rf.st(1).Pst = 0;
        prm.rf.st(2).Vst = 1.65e6; prm.rf.st(2).Pst = 0;
        prm.rf.st(3).Vst = 1.65e6; prm.rf.st(3).Pst = 0;

        prm.accel.Io = 1.7;
      case '3station_3.6'
        % 3 stations running (from J. Seeman)
        % Voltages:
        % 4-3 1200
        % 4-4 1200
        % 4-5 1200

        prm.rf.st(1).Vst = 1.2e6; prm.rf.st(1).Pst = 0;
        prm.rf.st(2).Vst = 1.2e6; prm.rf.st(2).Pst = 0;
        prm.rf.st(3).Vst = 1.2e6; prm.rf.st(3).Pst = 0;

        prm.accel.Io = 2.7;
      case '4station_5.6'
        % 4 stations running (from J. Seeman)
        % Voltages:
        % 4-3 1400
        % 4-4 1400
        % 4-5 1400
	% 4-6 1400

        prm.rf.st(4).name = 'LR46';
        prm.rf.st(4).Nc   = 2;
	prm.rf.st(4).parked = 0;

        prm.rf.st(1).Vst = 1.4e6; prm.rf.st(1).Pst = 0;
        prm.rf.st(2).Vst = 1.4e6; prm.rf.st(2).Pst = 0;
        prm.rf.st(3).Vst = 1.4e6; prm.rf.st(3).Pst = 0;
        prm.rf.st(4).Vst = 1.4e6; prm.rf.st(4).Pst = 0;

        prm.accel.Io = 3.6;
      case '4station_6.4'
        % 4 stations running (from J. Seeman)
        % Voltages:
        % 4-3 1600
        % 4-4 1600
        % 4-5 1600
	% 4-6 1600

        prm.rf.st(4).name = 'LR46';
        prm.rf.st(4).Nc   = 2;
	prm.rf.st(4).parked = 0;

        prm.rf.st(1).Vst = 1.6e6; prm.rf.st(1).Pst = 0;
        prm.rf.st(2).Vst = 1.6e6; prm.rf.st(2).Pst = 0;
        prm.rf.st(3).Vst = 1.6e6; prm.rf.st(3).Pst = 0;
        prm.rf.st(4).Vst = 1.6e6; prm.rf.st(4).Pst = 0;

        prm.accel.Io = 3.6;
      case '5station_8.5'
        % 5 stations running (from J. Seeman)
        % Voltages:
        % 4-3 1700
        % 4-4 1700
        % 4-5 1700
	% 4-6 1700
	% 4-7 1700

        prm.rf.st(4).name = 'LR46';
        prm.rf.st(4).Nc   = 2;
	prm.rf.st(4).parked = 0;
        prm.rf.st(5).name = 'LR47';
        prm.rf.st(5).Nc   = 2;
	prm.rf.st(5).parked = 0;

        prm.rf.st(1).Vst = 1.7e6; prm.rf.st(1).Pst = 0;
        prm.rf.st(2).Vst = 1.7e6; prm.rf.st(2).Pst = 0;
        prm.rf.st(3).Vst = 1.7e6; prm.rf.st(3).Pst = 0;
        prm.rf.st(4).Vst = 1.7e6; prm.rf.st(4).Pst = 0;
        prm.rf.st(5).Vst = 1.7e6; prm.rf.st(5).Pst = 0;

        prm.accel.Io = 4.5;
    end
end

prm.rf.Nc = 0; prm.rf.Np = 0; prm.rf.Vg = 0;
for k=1:length(prm.rf.st)
  if prm.rf.st(k).parked
    prm.rf.Np = prm.rf.Np + prm.rf.st(k).Nc;
    for m=1:2:prm.rf.st(k).Nc
      prm.rf.st(k).wr(m)   = wp1;
      prm.rf.st(k).wr(m+1) = wp2;
    end
  else
    prm.rf.Nc = prm.rf.Nc + prm.rf.st(k).Nc;
  end
  prm.rf.st(k).Vstc = prm.rf.st(k).Vst*exp(i*prm.rf.st(k).Pst/180*pi);
  prm.rf.Vg = prm.rf.Vg + prm.rf.st(k).Vstc;
end

Vg = 0;
for k=1:length(prm.rf.st)
  prm.rf.st(k).Vstc = prm.rf.st(k).Vstc * exp(-i*angle(prm.rf.Vg));
  prm.rf.st(k).Vc = prm.rf.st(k).Vstc/prm.rf.st(k).Nc*ones(prm.rf.st(k).Nc, 1);
  Vg = Vg + prm.rf.st(k).Vstc;
end
prm.rf.Vg = Vg;
