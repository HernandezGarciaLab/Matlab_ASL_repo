function result = FAIR_curve(t, params, alpha,Mob, T1b)
%function result = FAIR_curve(t, params,alpha, Mob, T1b )

Tau =params(1);
f = params(2);
dt = params(3);

for n=1:size(t,2) 
    
    
    if t(n) <= dt
        result(n) = 0;
    end
    
    if (t(n)>dt) & (t(n)< Tau + dt)
        result(n) = 2 * Mob* f * alpha * (t(n) - dt) * exp(-t(n)/T1b );
    end
    
    
    if t(n) >= Tau +dt
        result(n) = 2 * Mob* f * alpha * Tau * exp(-t(n)/T1b );
    end
    
end

plot(t, result,'r');

%write_mat(d, 'FAIRcurve.dat')

return
