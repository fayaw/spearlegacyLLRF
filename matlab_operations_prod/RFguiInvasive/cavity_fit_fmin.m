function [error] = cavity_fit_fmin(x,w,w_rf,data)

% The constraints will be put into the call to fmincon. 7/14/03, W. Colocho
%function [error,constraints] = cavity_fit(x,w,w_rf,data)


Wc = x(1)*2*pi;		% change frequency to radians & shift up 476 MHz
Ql = x(2);		% loaded Q of the cavity
Rl = x(3);		% gain constant for the cavity
Td = x(4);		% time delay - ns
offset = x(5)*(pi/180);	% phase offset - degrees to radians

s = j*w;		% make the s vector

cavity_response = ((Rl*Wc/Ql).*s) ./ (s.^2 + (Wc/Ql)*s + Wc^2);

delay_response  = exp(-j*(w-w_rf)*Td*1e-3);

total_response  = cavity_response .* delay_response .* exp(j*offset);

if(0)	% set to 1 to allow plotting
  figure(2)
  subplot(211),plot(w/(2*pi),20*log10(abs(total_response)),'g', ...
                    w/(2*pi),20*log10(abs(data)),'r')
  subplot(212),plot(w/(2*pi),(180/pi)*angle(total_response),'g', ...
                    w/(2*pi),(180/pi)*angle(data),'r')
end
if(0)	% set to 1 to allow plotting
  figure(2)
  plot(total_response,'g')
  axis([-2 2 -2 2])
  hold on
  plot(data,'r')
end

error = sum(abs(total_response - data));	% think about giving this a sense of sign

% define the constraints

%constraints(1) =  x(1) - 476.7;	% upper bound of frequency
%constraints(2) = -x(1) + 475.3;	% lower bound of frequency

%constraints(3) =  x(2) - 8000;	% upper bound of Ql
%constraints(4) = -x(2) + 4000;	% lower bound of Ql

%constraints(5) =  x(3) - 50;	% upper bound of gain term
%constraints(6) = -x(3) + .1;	% lower bound of gain term

%constraints(7) =  x(4) - 550;	% upper bound of system delay
%constraints(8) = -x(4) + 350;	% lower bound of system delay

%constraints(9) =  x(5) - 400;	% upper bound of phase offset
%constraints(10)= -x(5) - 400;	% lower bound of phase offset

