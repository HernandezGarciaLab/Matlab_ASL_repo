  Hb = 1.99 % mM
  PO = 4
  alpha = 1.39e-3 %mM/mmHg
  P50 = 38 %mmHg
  h = 2.73
  PS = 7900  %ml/min/100g
  F = 203 %ml/min/100g
  Pa = 89 %mmHg = Cp(1)/alpha % (con esto puedes usar eq3 para saber C(1))
  %Pt = Ct/alpha = 42.5mmHg
  Pt = 42.5 %mmHg

  
  NSTEPS = 1000;
  dx = 0.001;
  
  Ct = Pt*alpha;
  
  Cp = zeros(NSTEPS,1);
  C = zeros(NSTEPS,1);
  dCdx = zeros(NSTEPS,1);

  % initialize
  Cp(1) = Pa*alpha;
  C(1) = Cp(1) + PO*Hb / (1 + (alpha*P50/Cp(1))^h);
  C(1) =  PO*Hb / (1 + (alpha*P50/Cp(1))^h);
  
  for x=2:length(C)
           
      dCdx(x-1) = -(PS/F) * (Cp(x-1) - Ct);
      
      C(x) = C(x-1) + dCdx(x-1) *dx ;

      Cp(x) = (alpha*P50) / ( (C(x-1)/(Hb*PO))^(-h) -1);
      
  end

  subplot(311), plot(Cp);
  subplot(312), plot(C);
  subplot(313), plot(dCdx);
  
  CMRO2 = PS*(mean(Cp) - Ct)
  
  CMR02 = CMRO2 *0.0224