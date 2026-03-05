% direct_fit_ph    - Fit function for phase response through the cavity

function y = direct_fit_ph(x, data)

x1 = [data.fit.G data.fit.sigma data.fit.wr x];

H = direct_ol(x1, data);

ph = angle(H) - angle(data.H(data.u));
ph = mod(ph, 2*pi);
u = find(ph > pi); ph(u) = ph(u) - 2*pi;

y = sum(ph.^2);
