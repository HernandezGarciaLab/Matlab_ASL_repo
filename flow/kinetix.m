%

global rpenalty
% Typical values:
 Ttag =0.8  % seconds
 del = 0.02;	 %seconds
 crushers=1;
 R1t = 1/1.2;    % 1/sec.
 R1a = 1/1.6;    % 1/sec
 TR = Ttag + 0.2;
 xchange_time = 0.1;  % sec.
 alpha = 0.85; 
 dist = 12;   %cm
 V0 = 10;  %cm/sec


% adjust for the proton density
alpha=6000*0.7*0.85;


% Typical values:
parms = [ Ttag del crushers R1t R1a TR alpha dist V0];



%f = 0.1 * sin(0:0.1:pi)+ 1.5;
%Vart = 2 * sin(0:0.1:pi)+ 100;
SECONDS = 1; 
duration = 100;   % this is in seconds !!
art = ones(1,duration*SECONDS/TR);

f0=90/(60*100);
f = f0*ones(1,duration*SECONDS/TR);
paradigm = ones(size(art));
waveform = 'gamma';
switch waveform
    case 'flat'
        % ======= just the baseline
        paradigm = ones(size(art));
        
    case 'sinusoid'
        % ======= sinusoid after a baseline
        paradigm =ones(1, max(size(art)))+ 0.3*sin(freq *tvec );
        paradigm = [ones(1,15*SECONDS) paradigm];
        paradigm = paradigm(1:end-15*SECONDS);
        
    case 'gamma'
        % =======  set of gamma variate HRF's
        for delay=20:15:duration*0.5
            h = make_hrf(delay*SECONDS/TR,3*SECONDS/TR,max(size(art))) * 0.4;
            paradigm  = paradigm + h;
        end
        
    case 'step'
        % ======= step function
        paradigm(duration*SECONDS/2 : end) = 1 + f_change;
end
% Now scale the data to a baseline level:
f = f.* paradigm ;
%keyboard


%t = [0: TR: 100*length(f)];
t = [TR: TR: TR*(length(f))];

%estimates = [ f ; Vart ]';
estimates =f;

% generate the original signal:
signal = kinetix_lsq(f ,t, parms); 



% remove weird NaN's from the ends
%signal(1) = signal(2);
%signal(end) = signal(end-1);
% add noise
%noise = 0.01;
nvec = randn(size(signal));

signal = signal + noise*mean(signal)*nvec;


est0=zeros(size(estimates));
%est0(:,1)=1;
%est0(:,2)=100;
%est0(:) = mean(f);
est0(:) = f(1)*0.7;
%est0(1:end-1) = signal/mean(signal),;
%est0(end) = signal(end)/mean(signal);

LB = est0*0.5;
UB = est0*2.5;
%LB=0.8 * mean(f);
%UB = 1.2 * mean(f);

optvar=optimset('lsqnonlin');
optvar.TolFun = 1e-15;
optvar.TolX = 1e-10;
optvar.MaxIter = 8;
optvar.Diagnostics = 'off';
optvar.Display = 'iter';
optvar.DiffMinChange = 1.0e-6;



[est2 , resnorm, res, ex, output]  = lsqnonlin(@kinetix_lsq,...
	est0, LB, UB, ...
	optvar,...
	t,parms, ...
	signal);
%figure
subplot(211)
plot(f)
hold on,
plot(est2, 'r')
hold off
title(sprintf('Estiamted perfusion - Reg. = %f',rpenalty))
legend('True','Estimate')
subplot(212)
hold on
plot(signal/signal(5),'g')
plot(f/f(5))
plot(est2/est2(5), 'r')
hold off
legend('Signal', 'True','Estimate')
drawnow
rho = corrcoef(f, est2)
derivativeSum = sum(abs(diff(est2)))
