function result = sr_lsq(guess, TR, data)
% result = sr_lsq(guess,  TR [, data])
%
% to be used with leasq squares fit or alone.
%
% defines the relaxation in an saturation recovery experiment.
% Note: uses the magnitude images (no phase)
% Mo = guess(1);
% T1 = guess(2);
%   result = abs( Mo * (1 - exp(-TR / T1)  ) );
%

    Mo = guess(1);
    T1 = guess(2);
    FlipFactor = guess(3);
    
    
    M_guess =  abs(Mo*(1 - FlipFactor*exp(-TR/T1) ) );
    
    if nargin==2
        result = M_guess;
    else
        M = data;
        result = (M - M_guess);
    end
               
return

