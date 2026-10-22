% compute_comb     - Open comb-loop response model
%
% L = compute_comb(x, prm) computes comb open-loop transfer function
%
% Vector x (multiplied by prm.scale1 first) is interpreted as follows:
%
% x(1) - comb filter gain
% x(2) - comb loop delay
% x(3) - comb loop phase offset

function L = compute_comb(x, prm);

x = x.*prm.scale1;
G = x(1);
Td = x(2);
phase_off = x(3);

w_dig = exp(i*prm.w*prm.T0);
% Comb loop response
Hcomb = freqresp(prm.num*G, prm.den, w_dig).';

% Equalizer response
Heq = compute_eq(prm);

% Loop delay and offset
Hdel = exp(-i*(prm.w-prm.wrf)*Td + i *phase_off);

% SSB comb (if enabled)
if (isfield(prm, 'ssb') & prm.ssb==1)
%  Hssb = 1 - i*freqresp([prm.ssb_p -1], [1 -prm.ssb_p], w_dig).';
%  Hcomb = Hcomb.*Hssb/2;
%   Hcomb1 = freqresp([1 -2 1]*G*4, prm.den, w_dig).';
%   Hcomb = (Hcomb - i*Hcomb1)/2;
   Hssb = freqresp(prm.ssb_num, 1, w_dig).';
   Hcomb = Hcomb + i*Hssb.*Hcomb;
end

L = Hcomb.*Heq.*Hdel;
%L = Hcomb.*Hdel;
%L = Heq.*Hdel;
%L = Hssb;