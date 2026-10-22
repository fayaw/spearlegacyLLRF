% compute_loop     - This function computes direct loop transfer function
%
% function L = compute_loop(x, prm)
%
% Computed TF includes
%
% 1. Direct loop gain and phase
% 2. Cavity TF
% 3. Lead compensation (controlled by prm.lead)
% 4. Lag compensation (controlled by prm.lag)

function L = compute_loop(x, prm)

x = x.*prm.scale;
wr = x(1);
Ql = x(2);
Rl = x(3);
Td = x(4);
phase_off = x(5);

s = i*prm.w;
% Cavity response (includes klystron gain)
Hc = (Rl*wr/Ql*s)./(s.^2 + (wr/Ql)*s + wr^2);

% Loop delay and offset
Hdel = exp(-i*(prm.w-prm.wrf)*Td + i *phase_off);

% Lead compensation
s = (prm.w-prm.wrf)*i;
if (isfield(prm, 'lead') && prm.lead == 0)
  Hlead=1;
else
  Hlead = 499*(1+s*301*560e-12)./(497+301*196*560e-12*s);
end

if (isfield(prm, 'lag') && prm.lag == 1)
  Rp = 5.11e3;
  Rs = 499;
  C2 = 0.1e-6;
  Hlead = Hlead/499*Rp.*(1+s*C2*Rs)./(1+(Rp+Rs)*s*C2);
end

L = Hc.*Hdel.*Hlead;
