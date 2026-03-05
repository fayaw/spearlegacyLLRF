% direct_fit_all    - Fit function for response through the cavity

function y = direct_fit_all(x, data)

H = direct_ol(x, data);

y = sum(abs(H - data.H(data.u)).^2);
