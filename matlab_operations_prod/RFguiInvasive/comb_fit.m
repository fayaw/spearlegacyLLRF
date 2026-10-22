function [error] = comb_fit(x,w,combdata,T0,w_rf,den1,den2)

Gc = x(1);		% gain term for the filter volts/volt
Td = x(2);		% time delay (1-turn) - ns
offset = x(3);		% phase offset for the filter

num = [Gc -Gc 0];
den = [1 den1 den2];	

combresp   = freqresp(num,den,exp(sqrt(-1)*w*T0)).'; 
delay_resp = exp(-j*(w-w_rf)*Td*1e-9);
combmodel  = combresp.* delay_resp.* exp(j*offset) ;

error = sum(abs(combmodel - combdata));

if 0
  figure(1)
  subplot(211)
  hold on
  plot(((w/(2*pi))-476e6)/1e3, 20*log10(abs(combmodel)),'g')
  subplot(212)
  hold on
  plot(((w/(2*pi))-476e6)/1e3, 180/pi*angle(combmodel),'g')
end