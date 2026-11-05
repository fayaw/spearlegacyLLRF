function bpf60( q, c, h0 )
% function bpf60( q, c, h0 )
% bpf60 plots the frequency response of a 60 hz filter with quality factor
% q
% c   capacitance of both capacitors
% ho  magnitude of gain
%         . - - - -. - - - - - .
%         |        |           |  
%        c2       r6           |
%         |        |   |>      |
%  - r1 - . - c3 - . - |  >    |
%         |            |    > -.
%        r5            |  >
%         |        . - |>
%         _        _


f0 = 60;
w0 = 2*pi*f0;

r1 = q/(w0*c*h0);
r5 = q/((2*q^2 - h0)*w0*c);
r6 = 2*q/(w0*c);
fprintf(1, 'c = %e F; h0 = %d;  r1 = %e;  r5 = %e;  r6 = %e ohms\n', ...
    c, h0, r1, r5, r6);

sys = tf([w0/q 0], [1 w0/q w0^2]);
win = 2*pi*(10:200);
[mag, phase, wout] = bode(sys, win);
fout = wout/2/pi;
figInd=0;
figInd=figInd+1;figure(figInd);clf;
subplot(2,1,1)
loglog(fout,squeeze(mag))
grid;
ylabel('magnitude (dB)')
title(['magnitude for ', num2str(f0), ' Hz BPF with Q = ', num2str(q)]);
subplot(2,1,2)
semilogx(fout,squeeze(phase))
title(['phase for ', num2str(f0), ' Hz BPF with Q = ', num2str(q)]);
ylabel('angle (degree)')
xlabel('frequency (Hz)')
grid;


return
end