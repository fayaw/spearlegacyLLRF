% direct_ol_mag     - Calculate open-loop magnitude response through the cavity

function H = direct_ol_mag(x, data)

G     = x(1);
sigma = x(2);
wr    = x(3);

w = data.w;

H = abs(-2*i*sigma*G*w./(w.^2 - 2*i*sigma*w - wr^2));
