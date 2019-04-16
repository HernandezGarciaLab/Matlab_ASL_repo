function result=FAIR_fit(points)
% function result=FAIR_fit(data)

%global data Mob T1b alpha

alpha = 0.97
T1b = 1.3
Mob = 1;


	%data = points;

	f_guess = 0.8;
     dt_guess = 0.2;
     Tau_guess = 1.2;

	guess0 = [ dt_guess; Tau_guess; f_guess;];

     guess = leastsq('FAIR_func', guess0, [],[], ...
        points,alpha,Mob, T1b);

	     
     result = guess;
          
     %clear data
     
return







