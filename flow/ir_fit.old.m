function result=IR_fit(points, TR)
% function result=IR_fit(data, TR)
% fits the parameters Mo and T1 to the function
%
%	M(t) = abs [ Mo(1-2exp(-t/T1) + exp(-TR/T1) ) ]
%
% data is a two column matrix containing [t M(t)]
% the output is a matrix containing
% result = [Mo  T1]


	Mo_guess = 1.2*max(points(:,2));
     T1_guess = 0.8;
     
	
     guess0 = [Mo_guess; T1_guess];
     
	guess = leastsq('IR_func', guess0, [], [], points, TR);
	result = abs(guess);
	    
        
          
return



















