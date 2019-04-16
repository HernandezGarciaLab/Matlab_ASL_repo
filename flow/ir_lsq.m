function result = ir_lsq(guess, TI, TR, data)
% result = ir_lsq(guess,  TI, TR, data)
%
% defines the relaxation in an IR experiment.
% Note: uses the magnitude images (no phase)
% Mo = guess(1);
% T1 = guess(2);
%   result = abs( Mo * (1 - 2*exp(-t / T1) + exp(-TR/T1) ) );

    Mo = guess(1);
    T1 = guess(2);
    
    t = TI;
    %t = data;
    
%    M_guess =  abs(Mo*(1 - 2*exp(-t/T1) )+ exp(-TR/T1) );
    M_guess =  (Mo*(1 - 2*exp(-t/T1) )+ exp(-TR/T1) );
    
    if nargin==3
        result = M_guess;
    else
        M = data;
        result = (M - M_guess);
    end
               
return
