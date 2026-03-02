% direct_fit_mag    - Fit function for magnitude response through the cavity

function y = direct_fit_mag(x, data)

H = direct_ol([x 0 0], data);

y = sum((abs(H) - abs(data.H(data.u))).^2);
