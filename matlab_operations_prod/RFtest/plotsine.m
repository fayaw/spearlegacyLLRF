function plotcos
%beamcurrpv = 'SPEAR:BeamCurrAvg'
%id=mcaopen(beamcurrpv)
%beamcurr=mcaget(id)
x = (0:.01:1)*2*pi;
figure
plot(x,sin(x))
xlabel( 'angle' )
ylabel( 'amplitude' )
title( 'cos(\Theta)' )
%mcaclose(id)
return
