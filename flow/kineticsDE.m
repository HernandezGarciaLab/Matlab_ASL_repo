SECONDS = 100;  % step size =10 points / second
duration=10; % seconds
t = [0:1/SECONDS:duration];
sampl=zeros(size(t));


%Ttag=1.0;
TR=Ttag+0.2;

alpha = 0.85; 
Mao = 1;
Mssa = 0.1;

f = 90 / 60; ;% ml/sec.ml
lambda = 0.9;
R1t = 1/1.2;   % 1/sec.
R1a = 1/1.5;   % 1/sec
Ka = 1.2  ;% 1/sec
Ttransit=1.2;  % seconds

a = f/ lambda  + R1t ;
b = R1a + Ka ;
c = Ka ;

% make and arterial input function (inversion tag function)
cycles = duration/TR;
input = zeros(size(t));
for n=0:2:cycles-1
	input(n*TR*SECONDS+1: (n*TR +Ttag)*SECONDS) = alpha;
end

art=zeros(size(input));
tis = art;

% get the units right:
R1t = R1t/SECONDS;
R1a = R1a/SECONDS;
Ka = Ka/SECONDS;
f = f/SECONDS;

Adiff=[]; Tdiff=[]; Tsignal=[]; Asignal=[];
sampl(TR*SECONDS:TR*SECONDS:end)=1;

for k=Ttransit*SECONDS +1 :max(size(t))
	% here's the kinetics for the arterial compartment:
	dart = -art(k-1)* R1a ...			% T1 decay
		+ Ka* input(k-Ttransit*SECONDS)  ...   	% inflow
		- (Ka-f) * art(k-1) ...			% flow  thru 
		- f * art(k-1); 			% tissue perfusion 
	
	art(k) = art(k-1) + dart;
	
	% here's the kinetics for the tissue compartment:
	dtis = -tis(k-1)*R1t ...	% T1 decay
		+ f*art(k-1) ... 	% inflow
		- f*tis(k-1); 		% outflow

	tis(k) = tis(k-1) + dtis;
	
	% effect of crushing the tissue and arterial components:
	if sampl(k)==1 
		% sample the signal
		Tsignal= [Tsignal tis(k)];
		Asignal= [Asignal art(k)];

		% now crush the signal
		tis(k)=0;
		art(k)=0;
	end	
end

Tdiff = diff(Tsignal);
Tdiff = Tdiff(1:2:end);

mt=mean(Tdiff);

Adiff = diff(Asignal);
Adiff = Adiff(1:2:end);

ma=mean(Adiff);

m=ma+mt;

%close all
plot(t,input);
hold on
plot(t,art,'g')
plot(t,tis,'r')

plot(t(find(sampl)-1), tis(find(sampl)-1),'*')
title(sprintf('Ttag=%f',Ttag));
%stem(t,sampl);
%fatlines
