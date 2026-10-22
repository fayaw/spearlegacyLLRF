function cavphasval = ph_margin(f,Ql,Wc,Td,desired_margin)

w = 2*pi*f;


cavphasval = (Wc-w)*Td/1000 + ...
             atan((Ql.*(-w.^2 + Wc^2))./(w*Wc)) - ...
             pi/180*(180-desired_margin);

