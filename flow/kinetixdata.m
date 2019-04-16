%
% AQ. parameters :
 Ttag =1.5;     % seconds
 del = 0.02;	 %seconds
 crushers=0;
 R1t = 1/1.2;    % 1/sec.
 R1a = 1/1.6;    % 1/sec
 xchange_time = 0.01;  % sec.
 alpha = 0.85; 
 dist = 12;   %cm
 V0 = 12/1.5;  %cm/sec

% adjust for the proton density
alpha=5000*0.7*0.85;

% Typical values:
parms = [ Ttag del crushers R1t R1a xchange_time alpha dist V0]

TR = parms(1) + 0.2;

load activepix1700e.mat
signal=[tcC2 tcC3];
signal=mean(signal,2);
signal=smoothdata(signal,1.7,0.1,5,1);
signal=signal';

% do only a little bit of the time series for testing...
ev=event_avg(signal,[18/TR:20/TR:354], 20/TR ,10);
drawnow
signal=signal(1:100);
%%%


f0=90/(60*100);
t = [TR: TR: TR*length(signal)];

est0=zeros(size(signal));
est0(:) = f0;

LB = est0*0.1;
UB = est0*5;

optvar=optimset('lsqnonlin');
optvar.TolFun = 1e-15;
optvar.TolX = 1e-10;
optvar.MaxIter = 8;
optvar.Diagnostics = 'off';
optvar.Display = 'iter';
optvar.DiffMinChange = 1.0e-6;

global rpenalty
rpenalty=0.05;

tic
%t = [0: TR: TR*length(signal)];
[est2 , resnorm, res, ex, output]  = lsqnonlin(@kinetix_lsq,...
	est0, LB, UB, ...
	optvar,...
	t,parms, ...
	signal);
toc
figure
plot(t, est2, 'r')
hold on
plot(t, signal,'g')
hold off
legend('Estimate', 'signal')
drawnow

