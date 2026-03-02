% ph_trim           - Get the phase into -180 to +180 range

function y = ph_trim(x)

y = mod(x, 360);
if (y > 180)
  y = y - 360;
end
