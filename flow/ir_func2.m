function result = IR_func2( guess, data)
% result = IR_func(guess, data, TR)
% defines the relaxation in an IR experiment.
% Note: uses the magnitude images (no phase)
% Mo = guess(1);
% T1 = guess(2);
%   result = abs( Mo * (1 - 2*exp(-t / T1) + exp(-TR/T1) ) );

	Mo = guess(1);
    T1 = guess(2);
    TR = 2;
    
     t = data(:,1);
     M = data(:,2);
     %t = data;
     
     M_guess =  abs(Mo*(1 - 2*exp(-t/T1) + exp(-TR/T1) ));
     result = M_guess;
     result = (M - M_guess).^2 ;
     
               
return



















