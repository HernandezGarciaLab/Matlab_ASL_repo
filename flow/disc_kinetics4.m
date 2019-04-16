% Euler simulation of flow experiment:
% 
% use this diff. eq. for the arterial: 
% da(t,x)/dt  = Vart * da(t,x)/dx - R1*a(t,x)

warning off


% Put sequence parameters here:
Ttag =3;     % seconds
del = 0.8;	 %seconds
TR = 4;  % seconds
doFigs=1; 
show_uptake=0;
crushers=0;
if turbo==1
	Ttag = 1.06;
	del = 0.02;
	TR = 1.26;
end

waveform='block'
% frequency of sinusoidal activation paradigm:
freqHz = 0.05;      % hz
freq = freqHz*2*pi ; % change to rads/ sec.
phase = 0;

% Physiological constants
f = 90 / 60; ;  % ml/sec.ml
lambda = 0.9;   % unitless
R1t = 1/1.2;    % 1/sec.
R1a = 1/1.6;    % 1/sec
xchange_time = 0.1;  % sec.


% human
Vart = 160/1.5; 	% mm/sec
dist = 160;	% mm
transit_time = dist/Vart

SECONDS = 500;  % steps per second
MM = 1;  % steps per milimeter
dx = 1/MM;
dt = 1/SECONDS;

duration = 100;  % seconds
Length = 165;   % mm
xvec = [0:dx:Length];
tvec = [0:dt:duration];


% some constants
alpha = 0.85; 
Mao = 1;
Mssa = 0.1;


% Max.fractional changes during activation:
f_change = 0.4;  
Vart_change  = 0.07;

% sampling functions (image and subtraction)
sampl = zeros(size(tvec));
samplASL = sampl;
sampl((Ttag+del)*SECONDS:TR*SECONDS:end)=1;
sampleTimes = (Ttag+del):TR:duration;

% put some phase on it (if desired):
% sampl = [zeros(1,phase*SECONDS) sampl(1:end-phase*SECONDS)];
% samplASL( 1.5*TR*SECONDS:TR*SECONDS:end)=1;
% samplASL = sampl;

% make an arterial input function (inversion tag function)
cycles = duration/TR;
input = zeros(size(tvec));
for n=0:2:cycles-1
	input(n*TR*SECONDS+1: (n*TR+Ttag)*SECONDS+1) = alpha;
end
% put some phase on it (if desired):
% input = [zeros(1,phase*SECONDS) input(1:end-phase*SECONDS)];
% g = make_gaussian(0,20*SECONDS,1*SECONDS);
% input = conv(input,g);
% input= input(1:max(size(tvec)));

% temporal profile of arterial compartment's signal
art=zeros(size(tvec));
% spatial profile of arterial network.
artX=zeros(size(xvec));

art_tmp = art;
tis = art;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Let's make things  dynamic by altering both the flow and transit time
% dynamically.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% flow changes:

f= f *ones(size(art));  % define a baseline flow
Vart= Vart *ones(size(art));  % define a baseline flow
paradigm = ones(size(art));




% Vart_changes
% override the paradigm: waveform = 'flat'
switch waveform
    case 'flat'
        % ======= just the baseline
        paradigm = ones(size(art));
        
    case 'sinusoid'
        % ======= sinusoid after a baseline
        paradigm =ones(1, max(size(art))) + Vart_change*sin(freq *tvec );
        paradigm = [ones(1,15*SECONDS) paradigm];
        paradigm = paradigm(1:end-15*SECONDS);
        
    case 'gamma'
        % =======  set of gamma variate HRF's
        for delay=25:80:duration
            h = make_hrf(delay*SECONDS,3*SECONDS,max(size(art))) * Vart_change ;
            paradigm  = paradigm + h;
        end
        
    case 'block'
        % ======= block activaion function
        paradigm(duration*SECONDS/3 : end) = 1 + Vart_change;
        paradigm(duration*SECONDS*2/3 : end) = 1 ;
 	g = make_gaussian(0,20*SECONDS,1*SECONDS);
 	tmp = conv(paradigm,g);
 	paradigm= tmp(1:length(paradigm));

    case 'step'
        % ======= step function
        paradigm(duration*SECONDS/2 : end) = 1 + Vart_change;
end
Vart = Vart .* paradigm;

paradigm = ones(size(art));

% f_changes
% override the paradigm: waveform = 'gamma'
switch waveform
    case 'flat'
        % ======= just the baseline
        paradigm = ones(size(art));
        
    case 'sinusoid'
        % ======= sinusoid after a baseline
        paradigm =ones(1, max(size(art)))+f_change*sin(freq *tvec );
        paradigm = [ones(1,15*SECONDS) paradigm];
        paradigm = paradigm(1:end-15*SECONDS);
        
    case 'gamma'
        % =======  set of gamma variate HRF's
        for delay=25:80:duration
            h = make_hrf(delay*SECONDS,3*SECONDS,max(size(art))) * f_change;
            paradigm  = paradigm + h;
        end

    case 'block'
        % ======= block activaion function
        paradigm(duration*SECONDS/3 : end) = 1 + f_change;
        paradigm(duration*SECONDS*2/3 : end) = 1 ;
 	g = make_gaussian(0,20*SECONDS,1*SECONDS);
 	tmp = conv(paradigm,g);
 	paradigm= tmp(1:length(paradigm));

        
    case 'step'
        % ======= step function
        paradigm(duration*SECONDS/2 : end) = 1 + f_change;
end


% Now scale the data to a baseline level:
f = f.* paradigm ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Adiff=[]; Tdiff=[]; Tsignal=[]; Asignal=[];

%%%%%%%%%%%%%% ** Diff eq.  **  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


for t = 2 :max(size(tvec))
   
    % here's the kinetics for the arterial compartment 
    % update the whole length X at each iteration:
    artX(1) = input(t);     
    dAdx = diff(artX) / dx; 
    
%     artX(2:end) = artX(2:end)  ... 
%          - artX(2:end)  * Vart(t) * dt / dx ...
%          + artX(1:end-1) * Vart(t) * dt / dx ...
%          - artX(2:end) * R1a * dt / dx; 
%     
      artX(2:end) = artX(2:end) ...
          - Vart(t) * dAdx * dt ...
          - artX(2:end) * R1a * dt ;

      
    % the tissue compartment is only this one element at 20 mm.
    art(t) = artX(dist*MM);
    artX(dist*MM:end) = artX(dist*MM:end) -  f(t) * artX(dist*MM:end) * dt;  

    % here's the kinetics for the tissue compartment:  
    if ( t >= xchange_time*SECONDS + 1)
        dtis = ...
            - tis(t-1)*R1t ...	    % T1 decay
            + f(t) * art(t - xchange_time*SECONDS)  ... 	% inflow
            ;%- tis(t-1)*f(t); 		% outflow
        
        tis(t) = tis(t-1) + dtis * dt;
    end
    
    % effect of crushing the tissue and arterial components:
    if sampl(t)==1
        fprintf('*');
        % now crush the signal
        tis(t)=0;
        art(t)=0;
    end	
    
    
    if show_uptake==1
        subplot(211)
        hold off, plot(xvec,artX,'r'); 
        %hold on, plot(dAdx,'g') , hold off
        title(sprintf('t= %2.2f  INPUT= %2.2f  Vart=%2.2f',...
            t*dt, input(t),  Vart(t))); 
        axis([0 150 -1 1])
        
        subplot(212)
        plot(tvec,art), hold on, plot(tvec, input,'g')
        plot(tvec, tis,'r') 
        hold off
        %plot(dAdx)
        
        drawnow
    end

end

% subsample the signal to the TR
tASL = tvec(find(sampl)-1);

Tsignal = tis(find(sampl)-1);
Asignal = art(find(sampl)-1);
whole_signal = Tsignal + Asignal;
if crushers==1
    whole_signal = Tsignal;
end

% split the signal into control and tag channels (then interpolate)
control = whole_signal(1:2:end);
t_control = tASL(1:2:end);
control = interp1(t_control, control, tASL, 'linear');

tag = whole_signal(2:2:end);
t_tag = tASL(2:2:end);
tag = interp1(t_tag, tag, tASL, 'linear');

%ASL = abs(tag-control);
ASL = (tag-control);

% go back to normal units before plotting
% f = f*SECONDS;

% subsample the parameters to match the ASL samples.
f_sub = f(find(sampl));
Vart_sub = Vart(find(sampl));
ratio = ((ASL/ASL(3) ./ (f_sub /f_sub(3) )));
%ratio = (f_sub ) ./ (ASL);

%%% Making the figures:
%close all
if doFigs==1
    % plot the input, arterial and tissue contents
    figure
    subplot(221)
    plot(tvec,input);
    hold on
    plot(tvec,art,'g')
    plot(tvec,tis,'r')
    % overlay the sampling function
    plot(tvec(find(sampl)-1), tis(find(sampl)-1),'r*')
    plot(tvec(find(sampl)-1), art(find(sampl)-1),'g*')
    axis([0 50 -0.20 1])
    title(sprintf('ASL kinetics, phase=%2.2f',phase),'FontWeight','bold');
%     legend ('Tag', 'Arterial' , 'Tissue',4)
    xlabel('Time (sec.)')
%     fatlines;
%     dofontsize(13);
    
    hold off
    
    % Plot the true perfusion function with the overlayed ASL signal
    % Normalized to the baseline level)
    subplot(222)
    plot(tvec,f/f(5*SECONDS))
    hold on
    plot(tvec,Vart / Vart(5),'g')
    plot( tASL , ASL / ASL(3) , 'r' )
    axis tight
    hold off
    xlabel('Time (sec.)')
    
%     legend('True Perfusion','Arterial Velocity','ASL signal',4)
    title ('ASL tracking perfusion (Normalized)','FontWeight','bold')
%     fatlines;
%     dofontsize(13);
    
    % Plot the correlation between the ASL signal and the true perfusion
    subplot(223)
    plot(f_sub/f_sub(3),ASL/ASL(3),'*') , axis([ 0.7 1.3 0.7 1.3]) , axis square
    title('Correlation Plot','FontWeight','bold')
    xlabel('Flow')
    ylabel('Signal')
    
%     fatlines;
%     dofontsize(13);
    
    
    % Plot 
    subplot(224)
    plot(tASL, ratio), 
    title('Perfusion/Signal ratio','FontWeight','bold')
    xlabel('Time (scans)')
    hold on, plot(tvec,f/f(5*SECONDS),'--')
    axis tight
%     fatlines;
%     dofontsize(13);
%     
    hold off
end
