% make the simulation plots for the paper
%
% Typical values:
 Ttag =3.5% seconds
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

t = [TR: TR: TR*(length(f))];

%estimates = [ f ; Vart ]';
estimates =f;

% generate the original signal:
signal = kinetix_lsq(f ,t, parms); 
subplot (221), axis([40 50 -0.3 4])
subplot (222), axis([0 100 1 2.1])
subplot (223), axis([1 1.7 1 1.7]), axis square,
subplot (224)




figure
[ax h1 h2] = plotyy(t,abs(signal), t,f), axis tight
title('flow') ; grid
ylabel('ASL signal (a.u.)')
fatlines, dofontsize(16)
axes(ax(2)), hold on
ylabel('Perfusion (ml/s*g)')
xlabel('Time (sec)')
fatlines, dofontsize(12)