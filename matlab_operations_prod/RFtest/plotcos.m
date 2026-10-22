function plotcos
v = lcaGet('SRF1:STN:VOLT');
x = (0:.01:1)*2*pi;
y = hanning(101)';

figInd=0;
figInd=figInd+1;figure(figInd);clf;
plot(x,cos(x))
xlabel( 'angle' )
ylabel( 'amplitude' )
title( ['cos(\Theta)  V = ', num2str(v), ' MV'] )

figInd=figInd+1;figure(figInd);clf;
subplot(2,1,1);
plot(x,y);
xlabel( 'angle' )
ylabel( 'amplitude' )
title('hanning window')
subplot(2,1,2);
plot(x,cos(x).*y)
xlabel( 'angle' )
ylabel( 'amplitude' )
title( 'cos(\Theta) with a hanning window' )

return
end
