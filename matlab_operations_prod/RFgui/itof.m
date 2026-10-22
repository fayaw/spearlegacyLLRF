function y = itof(i16, q16)

id = (((double(i16)/16)*2.0) + 1.0)/4095;
qd = (((double(q16)/16)*2.0) + 1.0)/4095;
y = id + i*qd;
y = fliplr(y);
