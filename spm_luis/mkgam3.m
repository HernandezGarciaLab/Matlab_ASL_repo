function f = mkgam(etimes,stimes,parm)
% usage .. mkgam(etimes,stimes,parm)
% etimes - vector of event times
% stimes - vector or scan times
% parm - parameters for gamma function ([amp delta tau])

out = zeros(size(stimes));
et2 = sort(etimes);
ne = sum(et2<max(stimes));
for lp = 1:ne
    gam = parm(1).*(stimes-et2(lp)).^parm(2).*exp(-(stimes-et2(lp))./parm(3)).*((stimes-et2(lp)) > 0);
    out = out+gam;
end
f = out;
