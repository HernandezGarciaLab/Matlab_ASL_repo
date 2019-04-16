

% Runge-Kutta simulation of flow experiment:
warning off

% frequency of sinusoidal activation paradigm:
freqHz = 0.1;      % hz
Ttag = 0.9;     % seconds
phase = 0;
doFigs=1;
waveform='sinusoid'
freq = freqHz*2*pi ; % change to rads/ sec.

SECONDS = 1000;  % step size =10 points / second
dt = 1/SECONDS;
duration = 50; % seconds
t = [0:1/SECONDS:duration];

% sequence parameters:

TR = Ttag+0.2;  % seconds

% some constants
alpha = 0.85; 
Mao = 1;
Mssa = 0.1;

f = 90 / 60; ;  % ml/sec.ml
lambda = 0.9;   % unitless
R1t = 1/1.2;    % 1/sec.
R1a = 1/1.5;    % 1/sec
Ka = 0.5*SECONDS ;     % 1/sec  based on inspection of the curves in the Ye paper.
Ttransit = 1.2;   % seconds
Ttransit2 = 0.4; % (this is the delaty between the arterial and tissue) sec


% Max.fractional changes during activation:
f_change = 0.3;  
k_change  = 0.3;
Ttransit_change = 0.1; 
Ttransit2_change = 0.1; 

% measured constants (average of 4 subjects)
empirical=1;
if empirical
    f = 0.76 *SECONDS;  % ml/sec.ml
    lambda = 0.9;   % unitless
    R1t = 1/1.2;    % 1/sec.
    R1a = 1/1.6;    % 1/sec
    Ka =  1.48 * SECONDS;     % 1/sec .
    Ttransit = 1.06;   % seconds
    Ttransit2 = 1.58 -Ttransit ; % (this is the delay between the arterial and tissue) sec

    % Max.fractional changes during activation:
    f_change = 0.33;  
    ka_change = 0.75;
    Ttransit_change = 0.07;  
    Ttransit2_change = 0.11; 
end


% some constants
a = f/ lambda  + R1t ;
b = R1a + Ka ;
c = Ka ;

% sampling functions (image and subtraction)
sampl = zeros(size(t));
samplASL = sampl;
sampl(TR*SECONDS:TR*SECONDS:end)=1;
% put some phase on it:
sampl = [zeros(1,phase*SECONDS) sampl(1:end-phase*SECONDS)];

samplASL( 1.5*TR*SECONDS:TR*SECONDS:end)=1;

% make an arterial input function (inversion tag function)
cycles = duration/TR;
input = zeros(size(t));
for n=0:2:cycles-1
	input(n*TR*SECONDS+1: (n*TR +Ttag)*SECONDS) = alpha;
end
% put some phase on it:
input = [zeros(1,phase*SECONDS) input(1:end-phase*SECONDS)];

% temporal profile of arterial compartment's signal
art=zeros(size(t));
% spatial profile of arterial network.
art0=zeros(1,2*SECONDS);

art_tmp = art;
tis = art;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Let's make things  dynamic by altering both the flow and transit time
% dynamically.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% flow changes:

f= f *ones(size(art));  % define a baseline flow
Ka= Ka *ones(size(art));  % define a baseline flow
paradigm = ones(size(art));

% ka_changes
switch waveform
    case 'flat'
        % ======= just the baseline
        paradigm = ones(size(art));
        
    case 'sinusoid'
        % ======= sinusoid after a baseline
        paradigm =ones(1, max(size(art)))+ka_change*sin(freq *t );
        paradigm = [ones(1,10*SECONDS) paradigm];
        paradigm = paradigm(1:end-10*SECONDS);
        
    case 'gamma'
        % =======  set of gamma variate HRF's
        for delay=5:20:duration
            h = make_hrf(delay*SECONDS,3*SECONDS,max(size(art))) * ka_change;
            paradigm  = paradigm + h';
        end
        
    case 'step'
        % ======= step function
        paradigm(duration*SECONDS/2 : end) = 1 + ka_change;
end

% f_changes
switch waveform
    case 'flat'
        % ======= just the baseline
        paradigm = ones(size(art));
        
    case 'sinusoid'
        % ======= sinusoid after a baseline
        paradigm =ones(1, max(size(art)))+f_change*sin(freq *t );
        paradigm = [ones(1,10*SECONDS) paradigm];
        paradigm = paradigm(1:end-10*SECONDS);
        
    case 'gamma'
        % =======  set of gamma variate HRF's
        for delay=5:20:duration
            h = make_hrf(delay*SECONDS,3*SECONDS,max(size(art))) * f_change;
            paradigm  = paradigm + h';
        end
        
    case 'step'
        % ======= step function
        paradigm(duration*SECONDS/2 : end) = 1 + f_change;
end


% Now scale the data to a baseline level:
f = f.* paradigm ;
Ka = Ka .* paradigm;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% transit time changes with the paradigm:

Ttransit = Ttransit * ones(size(art));  % define a baseline transit time
Ttransit2 = Ttransit2 * ones(size(art));
paradigm = ones(size(art));

switch waveform
    case 'flat'
        % ======= just a baseline
        paradigm = ones(size(art));
        
    case 'sinusoid'
        % ======= sinusoid after a baseline
        paradigm =ones(1, max(size(art)))-0.1*sin(freq *t );
        paradigm = [ones(1,10*SECONDS) paradigm];
        paradigm = paradigm(1:end-10*SECONDS);
        
    case 'gamma'
        % ======= set of gamma variate HRF's
        for delay=5:20:duration
            h = make_hrf(delay*SECONDS,3*SECONDS,max(size(art))) * 0.1;
            paradigm  = paradigm - h';
        end
        
    case 'step'
        % ======= step function
        paradigm(duration*SECONDS/2 : end) = 0.9;
end

% ======= clooge to test just the flow and not the transit time
% paradigm(:)=1;

Ttransit2 = Ttransit2 .* paradigm;
%Ttransit = Ttransit .* paradigm;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



Adiff=[]; Tdiff=[]; Tsignal=[]; Asignal=[];

% adjust the units to the sampling rate:
R1t = R1t/SECONDS;
R1a = R1a/SECONDS;

for k=1 +1 :max(size(t))
    
	% here's the kinetics for the arterial compartment:
    
    % spatial effect of dispersion:
    % one spatial x increment is equivalent to 
    % the distance traveled in one temporal increment    
    % so x = Ttransit means the distance to the tagging plane
    dart0(1) = input(k)*Ka(k)...
        -art0(1)*Ka(k) ...
        -art0(1)*R1a;
 
    art0(1) = art0(1) + dart0(1) *dt;    

    for x=2:max(size(art0))
        
        dart0(x) = art0(x-1)*Ka(k) ...
            -art0(x)*Ka(k) ...
            -art0(x)*R1a;
        
        art0(x) = art0(x) + dart0(x) * dt;    
    end
    % the tissue compartment is only this one element.
    art(k) = art0(Ttransit(k)*SECONDS);
    
    
    % here's the kinetics for the tissue compartment:
    
    if k > Ttransit2(k)
        dtis = -tis(k-1)*R1t ...	% T1 decay
            + f(k) * art(round(k - Ttransit2(k) ))  ... 	% inflow
            - tis(k-1)*f(k); 		% outflow
        
        tis(k) = tis(k-1) + dtis * dt;
        
        % effect of crushing the tissue and arterial components:
        if sampl(k)==1
            
            % now crush the signal
            tis(k)=0;
            art(k)=0;
            % Maybbe we should crush the entire arterial 
            % compartment at the local level
            art0(Ttransit(k)*SECONDS)=0;
        end	
    end

    subplot(211)
    plot(art0); title(sprintf('t= %2.2f  INPUT= %2.2f dart0(1)=%2.2f Ttransit=%2.2f',...
        k/SECONDS, input(k), dart0(1), Ttransit(k))); 
    axis([0 2*SECONDS 0 1]); 
    
    subplot(212)
    plot(art)
    
    subplot(212), hold on
    plot(tis,'r'), hold off
    drawnow
    
end

% subsample the signal to the TR
tASL = t(find(sampl)-1);

Tsignal = tis(find(sampl)-1);
Asignal = art(find(sampl)-1);
whole_signal = Tsignal + Asignal;
% whole_signal = Tsignal;

% split the signal into control and tag channels (interpolate)
control = whole_signal(1:2:end);
t_control = tASL(1:2:end);
control = interp1(t_control, control, tASL, 'spline');

tag = whole_signal(2:2:end);
t_tag = tASL(2:2:end);
tag = interp1(t_tag, tag, tASL, 'spline');

ASL = tag-control;

% go back to normal units before plotting
f = f*SECONDS;
Ttransit = Ttransit / SECONDS;
Ttransit2 = Ttransit2 / SECONDS;

% subsample the parameters to match the ASL samples.
f_sub = f(find(sampl));
Ka_sub = Ka(find(sampl));
ratio = (f_sub /f_sub(5) ) ./ (ASL/ASL(5));

%%% Making the figures:
%close all
if doFigs==1
    % plot the input, arterial and tissue contents
    figure
    subplot(221)
    plot(t,input/5);
    hold on
    plot(t,art,'g')
    plot(t,tis,'r')
    % overlay the sampling function
    plot(t(find(sampl)-1), tis(find(sampl)-1),'r*')
    plot(t(find(sampl)-1), art(find(sampl)-1),'g*')
    axis([0 50 -0.20 0.2])
    title(sprintf('ASL kinetics, phase=%2.2f',phase),'FontWeight','bold');
    legend ('Tag', 'Arterial' , 'Tissue',4)
    xlabel('Time (sec.)')
    fatlines;
    dofontsize(13);
    
    hold off
    
    %  Plot the true perfusion function with the overlayed ASL signal
    % Normalized to the baseline level)
    subplot(222)
    plot(t,f/f(5*SECONDS))
    hold on
    plot(t,Ttransit2 / Ttransit2(1),'g')
    plot( tASL , ASL / ASL(5) , 'r' )
    axis([0 50 0 1.5])
    hold off
    xlabel('Time (sec.)')
    
    legend('Perfusion','Tissue transit time','ASL signal',4)
    title ('ASL tracking perfusion (Normalized)','FontWeight','bold')
    fatlines;
    dofontsize(13);
    
    % Plot the correlation between the ASL signal and the true perfusion
    subplot(223)
    plot(f_sub/f_sub(5),ASL/ASL(5),'*') , axis([ 0.7 1.3 0.7 1.3]) , axis square
    title('Correlation Plot','FontWeight','bold')
    xlabel('Flow')
    ylabel('Signal')
    
    fatlines;
    dofontsize(13);
    
    
    % Plot 
    subplot(224)
    plot(ratio), axis tight
    title('Perfusion/Signal ratio','FontWeight','bold')
    xlabel('Time (scans)')
    
    fatlines;
    dofontsize(13);
    
    hold off
end