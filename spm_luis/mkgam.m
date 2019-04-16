function f = mkgam(etimes,stimes,parm)
% usage .. mkgam(etimes,stimes,parm)
% etimes - vector of event times
% stimes - vector or scan times
% parm - parameters for gamma function ([amp delta tau])

out = zeros(size(stimes));
for lp = 1:length(etimes)
  if etimes(lp) >= 0
    gam = parm(1).*((stimes-parm(2)-etimes(lp))./parm(3)).^2.*exp(-(stimes-parm(2)-etimes(lp))./parm(3)).*((stimes-parm(2)-etimes(lp)) > 0);
    out = out+gam;
  end
end
f = out;
