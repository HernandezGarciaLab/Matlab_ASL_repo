TI = [ 0.2 :0.1 : 1.9];
T = [];
A= [];

for count=1:length(TI)
	Ttag = TI(count);
	disc_kinetics_FAIR
	T = [T mean(Tsignal)];
	A = [A mean(Asignal)];
end

plot(TI,T,'r', TI,A,'b')	
