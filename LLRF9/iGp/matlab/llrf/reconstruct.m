% reconstruct       - Implement Doolittle I/Q reconstruction algorithm
%
%
%
%

function [I, Q] = reconstruct(x, theta);

n=0:length(x)-1; n=n(:);
x = x(:);

refi=sin(n*theta);
refq=cos(n*theta);
D = sin(theta);

Idet = [refi(2:end) -refi(1:end-1)];
Qdet = [-refq(2:end) refq(1:end-1)];

I = sum(Idet.*[x(1:end-1) x(2:end)], 2)/D;
Q = sum(Qdet.*[x(1:end-1) x(2:end)], 2)/D;
