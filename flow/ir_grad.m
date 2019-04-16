function S = IR_grad(t,S0, T1, Mo, TR)

dS_dMo = 1 - exp(-t/T1) + exp(-TR/T1);
dS_dT1 = Mo(2*exp(-t/T1)/(T1^2) - exp(-TR/T1)/(T1^2))

return
