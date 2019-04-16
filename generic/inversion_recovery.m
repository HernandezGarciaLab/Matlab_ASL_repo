function result = inversion_recovery(parms, ti)
% function result = inversion_recovery(parms [alpha, r1] , ti, s0)
% result = abs( (1- 2*exp(-r1*ti)));

alpha = parms(1);
r1 = parms(2);

result = abs((1- 2*alpha*exp(-r1*ti)));

end