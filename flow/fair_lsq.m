function result = FAIR_lsq(guess, t, alpha, T1b, dM )
% function result = FAIR_lsq(guess, t, alpha, T1b [,dM])
%
% defines the tissue response function for 
% fitting purposes
%
%        if t(i) < dt
%           M(i) = 0;
%        
%        
%        if (t(i)>=dt) & (t(i)< Tau + dt)
%          M(i) = 2 * Mob* f * alpha * (t(i) - dt) * exp(-t(i)/T1b )
%        
%           
%        if t(i) >= Tau +dt
%           M(i) = 2 * Mob* f * alpha * Tau * exp(-t(i)/T1b )
% 
% ref:  MRM 40, 383-396, 1998 (buxton, frank, wong ....)


   
    Tau= 	guess(1);
    Mob_f = guess(2);
    dt =	guess(3);
     
   
    dM_guess=zeros(size(t));

    for n=1:size(t,2) 
        
        
        if t(n) <= dt
            dM_guess(n) = 0;
        end
        
        if (t(n)>dt) & (t(n)< Tau + dt)
            dM_guess(n) = 2 * Mob_f * alpha * (t(n) - dt) * exp(-t(n)/T1b );
        end
        
        
        if t(n) >= Tau +dt
            dM_guess(n) = 2 * Mob_f * alpha * Tau * exp(-t(n)/T1b );
        end
        
    end
    
    if nargin==5
        result = (dM - dM_guess) ;
    else
        result=dM_guess;        
    end
    

return
