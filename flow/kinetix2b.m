%

global rpenalty
% Typical values:
 Ttag =0.8;  % seconds
 %Ttag =3.8  % seconds
 del = 0.02;	 %seconds
 crushers=1;
 R1t = 1/1.2;    % 1/sec.
 R1a = 1/1.6;    % 1/sec
 TR = Ttag + 0.2;
 xchange_time = 0.1;  % sec.
 alpha = 0.85; 
 dist = 12;   %cm
 V0 = 10;  %cm/sec

Ttransit=dist/V0

% adjust for the proton density
alpha=6000*0.7*0.85;


% Typical values:
parms = [ Ttag del crushers R1t R1a TR alpha dist V0];

SECONDS = 1; 
duration = 100;   % this is in seconds !!
doPlots=1;

art = ones(1,duration*SECONDS/TR);

f0=90/(60*100);
f = f0*ones(1,duration*SECONDS/TR);
paradigm = ones(size(art));
waveform = 'gamma';


%waveform = 'flat';
%noise=0
%rpenalty=100


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

%f_est = [ f ; Vart ]';
f_est =f;

% Adding the Additional Mean parameter to estimate....
% f_est is the function to estimate
% f is the TRUE perfusion fucntion
%f_est = [f_est-mean(f_est)   mean(f_est)];
%whos

%%%%
% generate the original signal:
signal = kinetix_lsqb( f_est, t, parms); 


% add noise
%noise = 0.01;
%nvec = randn(size(signal));
nvec = noise*randn(size(signal));

signal = signal + nvec;
if doPlots==1
	plot(signal)
end

%%%%%%%% estimate the mean perfusion assuming steady state

optvar=optimset('lsqnonlin');
optvar.TolFun = 1e-15;
optvar.TolX = 1e-10;
optvar.MaxIter = 10;
optvar.Diagnostics = 'off';
optvar.Display = 'iter';
optvar.DiffMinChange = 1.0e-6;
LB=0.005;
UB=0.03;
[mean_est , resnorm, res, ex, output]  = lsqnonlin(@kinetix_ss_lsq,...
	0.01 ,LB ,UB, ...
	optvar,...
	t,parms, ...
	signal);
%%%%%%%%
mean_est
est0=zeros(size(f_est));
est0(:) = f(1)*0.7;
est0(:)= mean_est*ones(size(f));

% adjust the boundaries to include the mean flow estimate
LB = 0.005*ones(size(f));
UB = 0.03*ones(size(f));

optvar=optimset('lsqnonlin');
optvar.TolFun = 1e-15;
optvar.TolX = 1e-10;
optvar.MaxIter = 10;
optvar.Diagnostics = 'off';
optvar.Display = 'iter';
optvar.DiffMinChange = 1.0e-6;

[est2 , resnorm, res, ex, output]  = lsqnonlin(@kinetix_lsqb,...
	est0,LB ,UB, ...
	optvar,...
	t,parms, ...
	signal);

f_est2=est2;

if doPlots==1
	figure
	subplot(211)
	plot(f)
	hold on,
	plot(f_est2, 'r')
	plot(est0,'k')
	axis([1 length(f) 0.007 0.025])
	hold off
	title(sprintf('Estimated perfusion - Reg. = %f',rpenalty))
	legend('True','Estimate','Initial estimate')
	fatlines, dofontsize(14)
	subplot(212)
	hold on
	plot(signal/signal(5),'g')
	plot(f/f(5))
	plot(f_est2/f_est2(5), 'r')
	hold off
	legend('Signal', 'True','Estimate')
	title('Normalized to baseline')
	fatlines, dofontsize(14)
	drawnow
	rho = corrcoef(f_est2, f)
	derivativeSum = sum(abs(diff(f_est2)))
end
