function result=washIn(guess, TI)%, DATA)
%
% function result=washIn(guess, TI [,DATA])
%
% this fuction is used for fitting the wash in
% of a tracer through tissue
% using first order kinetics
%
%
global debug
debug=1;
	to=guess(1);
	k=guess(2);
	Mss=guess(3);

	for count=1:size(TI,2)
		if TI(count) <= to
			DATAFit(count)=0;
		else
			DATAFit(count) = Mss*(1 - exp(-(TI(count)-to)*k ) );
		end
	end


	result=DATAFit;

return


