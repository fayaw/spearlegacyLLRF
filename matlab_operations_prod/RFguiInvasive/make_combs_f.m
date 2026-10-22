function [A_1] = make_combs_f(f_rf,h,f_sync,hcomb)

% make_combs.m - file to generate discrete comb filter coefficients
%                Paul 1/7/97
% changed to function make_combs.f.m  7/28/04 - can be called by other programs and/or
% compiled
% 02-08-2007 Modified to calculate A1 coeff for the new Comb filter module
% removed the "/2" around the line # 25.
%                                         Vojtech Pacak
format compact

%*********INPUT PARAMETERS************
% f_rf   = machine RF frequency
% h      = machine harmonic number
% f_sync = synchrotron frequency
% hcomb    = sampling clock frequency per revolution

gain = .25;		% gain coefficient for the comb filter
k = 15/16;		% loss term for the comb filter

Q_sync = f_sync/(f_rf/h);	% synchrotron tune
Ts = 1/(hcomb*(f_rf/h));	% calculate the sample time

num = gain*[1 -1];
den = [1, -2*k*cos(2*pi*Q_sync), k^2];  %/2	% DIVIDE BY 2 REMOVED FOR CF2 MODULES

% fprintf(1,'\n\ndenominator Z-144 coefficient = %1.5f \n',-den(3))
% fprintf(1,'denominator Z-72  coefficient = %1.5f \n',-den(2))
% fprintf(1,'numerator   Z-72  coefficient = %1.5f \n',num(2))
% fprintf(1,'numerator   Z0    coefficient = %1.5f \n',num(1))

A_1 = -den(2);


% calculate Bode frequency response of thecomb filter
%freq = linspace(0,1/(Ts*72),1000);
%w = 2*pi*freq;
%[mag,phase,w] = dbode(num,den,Ts*72,w);
%mag(1)=mag(2)/2; % avoid log(0) error when plotting the bode

% %display the Bode plot of the comb filter 
% figure(1)
% clf
% 
% subplot(211)
% plot(freq/1e3,20*log10(abs(mag)))
% junk = axis;
% axis([junk(1:2) -20 30]);
% grid on
% title('Response of Comb Filters')
% xlabel('frequency - kHz')
% ylabel('magnitude - dB')
% hold on
% 
% subplot(212)
% plot(freq/1e3,phase)
% grid on
% xlabel('frequency - kHz')
% ylabel('phase - degrees')
% hold on

return
