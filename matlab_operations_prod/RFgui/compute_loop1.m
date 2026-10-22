% compute_loop1    - Direct loop response using fixed Ql
%
%   L = compute_loop1(x, prm) calculates direct loop open-loop transfer
%   function using fixed Ql

function L = compute_loop1(x, prm);

prm.scale=[prm.scale(1) 1 prm.scale(2:end)];
L = compute_loop([x(1) prm.Ql x(2:end)], prm);
