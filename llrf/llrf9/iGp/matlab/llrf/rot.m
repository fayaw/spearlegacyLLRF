function vec = set_rot(gain, phase, theta)

% Follows the IOC calculation
gain_scale_inv=1/sin(theta);

vec = [1 -cos(theta) * gain_scale_inv; 0 gain_scale_inv] * gain * ...
      [cos(-phase/180*pi); sin(-phase/180*pi)];
