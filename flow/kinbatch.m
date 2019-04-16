result=[];
for Ttag=0.5:0.02:4
	kineticsDE
	hold off
	drawnow
	result=[result [ma; mt ; m] ];
end
T=[0.5:0.02:4]

plot(T,result')
