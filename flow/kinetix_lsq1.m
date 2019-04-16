function result = kinetix_func(estimates,time,parms, data)
%function result = kinetix_func(estimates,time, parms, [data] )
%
% Lax-Wendroff simulation of flow experiment:
% for use with lsqnonlin
%
% use this diff. eq. for the arterial: 
% da(t,x)/dt  = V * da(t,x)/dx - R1*a(t,x)
%
% f = estimates(:,1);
% V = estimates(:,2);
%
% Ttag = parms(1);     % seconds
% del =  parms(2);	 %seconds
% crushers= parms(3);   % boolean
% R1t =  parms(4);    % 1/sec.
% R1a =   parms(5)   % 1/sec
% xchange_time =  parms(6);  % sec.
% alpha =  parms(7); % no units
% dist = parms(8);   % cm
%
% Typical values:
% Ttag =3.8;     % seconds
% del = 0.02;	 %seconds
% crushers=0;
% R1t = 1/1.2;    % 1/sec.
% R1a = 1/1.6;    % 1/sec
% xchange_time = 0.1;  % sec.
% alpha = 0.85; 
% dist = 120 ;   % cm
% V0 = 100 %cm/sec 
%
% transit_time = dist/V
% TR = Ttag + 0.2;  % seconds
% f = 90 / 60; ;  % ml/sec.ml
% lambda = 0.9;   % unitless
%
% original version - first draft of paper uses this...
% Does not accurately estimate the baseline unless the 
% initial guess is the baseline itself.
% it does estimate the rest reasonably well...


global residue rpenalty

doFigs=0; 
show_uptake=0;

warning off

f = estimates;

% Put sequence parameters here:
Ttag = parms(1);     % seconds
del =  parms(2);	 %seconds
crushers= parms(3);
R1t =  parms(4);    % 1/sec.
R1a =   parms(5);   % 1/sec
TR =  parms(6);  % sec.
alpha =  parms(7); 
dist = parms(8);
V0 = parms(9);


% assume that the change in mean V is 1/4 of the change in f
df = (f-f(1))/f(1);
dV = 0.2*df;
%dV = 0*df;
V = V0 + V0 * dV;

%SECONDS = 50;  % steps per second
%CM = 2;  % steps per cm
SECONDS = 25;  % steps per second
CM = 1;  % steps per cm
dx = 1/CM;
dt = 1/SECONDS;
% Note that this term   must be  less than 1 for all t :  
%        V(t) * dAdx * dt
% otherwise the system becomes unstable

Length = 25;   % cm
duration = length(f)*TR;  % seconds
duration = time(end);
xvec = [0:dx:Length];
%tvec = [TR:dt:duration];
tvec = [0:dt:duration];


lambda = 0.9;   % unitless
transit_time = dist./V;

tt=time;

% upsample the V anf f functions to match the simulation.
f = interp1(tt, f, tvec,'spline','extrap');
V = interp1(tt, V, tvec,'spline','extrap');

% sampling functions (image and subtraction)
sampl = zeros(size(tvec));
samplASL = sampl;
sampl((Ttag+del)*SECONDS : TR*SECONDS:end)=1;
sampleTimes = (Ttag+del):TR:duration;

% make an arterial input function (inversion tag function)
cycles = duration/TR;
input = zeros(size(tvec));
for n=0:2:cycles-1
	input(n*TR*SECONDS+1: (n*TR+Ttag)*SECONDS+1) = alpha;
end

 

% pad the signal to avoid problems at the ends...
padsize = 4*TR*SECONDS;
f = [ones(1,padsize)*f(1) f  ones(1,padsize)*f(end) ];
V = [ones(1,padsize)*V(1) V  ones(1,padsize)*V(end) ];
%input = [zeros(1,padsize) input  zeros(1,padsize) ];
%input(1:Ttag*SECONDS) = alpha;
%input(2*TR*SECONDS+1:(2*TR+Ttag)*SECONDS) = alpha;
input = [input(1:padsize) input zeros(1,padsize)];

sampl = [zeros(1,padsize) sampl  zeros(1,padsize) ];
samplASL = [zeros(1,padsize) samplASL  zeros(1,padsize) ];
tvec = [tvec   tvec(end)+tvec(2:padsize*2+1)];
tvec = tvec(1:length(f));

%smooth the input a little bit
%g = make_gaussian(0.5*SECONDS,0.25*SECONDS,1*SECONDS);
%input = conv(input,g);
%input = input(length(g)/2:length(tvec)+length(g)/2-1);

% temporal profile of arterial compartment's signal
art = zeros(size(tvec));
% spatial profile of arterial network.
artX = zeros(size(xvec));

% arterial compartment in time and space:
A = zeros(length(xvec),length(tvec));

art_tmp = art;
tis = art;

%%%%%%%%%%%%%% ** Diff eq.  **  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% input into the system in to the x=1 compartment:
A(1,:) = input;
A(2,:) = A(1,:);

for t = 2 :length(tvec)-1
    % first time derivative of V and f:
    Vt = ( V(t+1) - V(t-1) ) / (2*dt);
    ft = ( f(t+1) - f(t-1) ) / (2*dt);

    %Vtt = (V(t+1) -2*V(t) + V(t+1) / (dt*dt)
 
    for x=2:length(xvec)-1
        % first derivatives in space and time
        Ax = ( A(x+1,t) - A(x-1,t) ) / (2*dx);
        At = -V(t)*Ax - R1a*A(x,t);
        % second derivative in space and time
        Axx = (A(x-1,t) - 2*A(x,t) + A(x+1,t)) / (dx*dx);
        Att = -V(t)*(-V(t)*Axx - R1a*Ax) - Vt*Ax - R1a*At;

%	    Axt = -V(t)*Axx - R1a*Ax;
%   	Axxt =         
%	    Attt = 2*V(t)*Vt*Axx + V(t)*V(t)*Axxt + R1a*Vt*Ax + R1a*V(t)*Axt ...
%		    -Vtt*Ax - Vt*Axt - R1a*Att;

        % compute the next step (Taylor):
        A(x,t+1) = A(x,t) + dt*At + (dt^2)*Att/2 ;%+ ...

%		(dt^3)*Attt/6;
%       A(x,t+1) = A(x,t) + (dt-R1a*dt*dt/2)*At + dt*dt*V(t)*V(t)*Axx/2 + (dt*dt*V(t)*R1a/2 - dt*dt*Vt/2)*Ax;
  
    end   
    % to reduce error, extrapolate the second to last onto the last ones
    %A(x+1,t)=A(x,t)+ Ax*dx;

    % the tissue compartment is only this one element at "dist" cm.
    A(dist*CM,t) = A(dist*CM,t) - f(t) * A(dist*CM,t);
    art(t) = A(dist*CM,t) - f(t) * A(dist*CM,t);;
    
    
    % the tissue compartment using same method....
    artt = (art(t)-art(t-1))/dt;    % backward difference
    Tt = f(t)*art(t) - R1t*tis(t);% - (f(t)/lambda)*tis(t-xchange_time);
    Ttt = ft*art(t) + f(t)*artt - R1t*Tt;% - (ft*tis(t-xchange_time) + f(t)*Tt)/lambda;
    
    tis(t+1) = tis(t) + dt*Tt +(dt^2)*Ttt/2;
    
    % effect of crushing the tissue and arterial components:
    if sampl(t)==1
        %fprintf('*');
        % now crush the signal
        %tis(t)=0;
        %art(t)=0;
    	%A(dist*CM,t) = 0;
    end	
    
    
    if show_uptake==1
        subplot(211)
        hold off, plot(xvec,A(:,t),'r'); 
        %hold on, plot(dAdx,'g') , hold off
        title(sprintf('t= %2.2f  INPUT= %2.2f  V=%2.2f',...
            t*dt, input(t),  V(t))); 
        axis([0 Length -0.1*alpha 1.1*alpha])
        grid
        
        subplot(212)
        plot(tvec,art), hold on, plot(tvec, input,'g')
        plot(tvec, tis,'r') 
        hold off
        %plot(dAdx)
        
        drawnow
    end

end

% imagesc([dt:dt:dt*length(tvec)],[dx:dx:dx*length(xvec)],A);    
% colorbar;
% xlabel('time (seconds)');
% ylabel('space (cm)');
% result=A;
% return

 
%% remove the padding 
f = f(padsize+1:end-padsize);
V = V(padsize+1:end-padsize);

input = input(padsize+1:end-padsize);
tis = tis(padsize+1:end-padsize);
art = art(padsize+1:end-padsize);

sampl=sampl(padsize+1:end-padsize);
tvec = tvec(1:end-2*padsize);

% subsample the signal to the TR
tASL = tvec(find(sampl));
Tsignal = tis(find(sampl));
Asignal = art(find(sampl));

whole_signal = Tsignal + Asignal;
if crushers==1
    whole_signal = Tsignal;
end

% split the signal into control and tag channels (then interpolate)
control = whole_signal(1:2:end);
t_control = tASL(1:2:end);
control = interp1(t_control, control, tASL, 'spline','extrap');

tag = whole_signal(2:2:end);
t_tag = tASL(2:2:end);
tag = interp1(t_tag, tag, tASL, 'spline','extrap');

%ASL = abs(tag-control);
ASL = (tag-control);
% there could be a problem with NaN
if isnan(ASL(1))
	ASL(1) = ASL(5);
end
if isnan(ASL(end))
	ASL(end) = ASL(end-4);
end

% subsample the parameters to match the ASL samples.
f_sub = f(find(sampl));
V_sub = V(find(sampl));
%ratio = (f_sub ) ./ (ASL);

%%% Making the figures:
%close all
if doFigs==1
    
    % plot the input, arterial and tissue contents
    figure
    subplot(221)
    plot(tvec,input/mean(input));
    hold on
    plot(tvec,art/mean(art),'g')
    plot(tvec,tis/mean(tis),'r')
    % overlay the sampling function
    plot(tvec(find(sampl)), tis(find(sampl))/mean(tis),'r*')
    plot(tvec(find(sampl)), art(find(sampl))/mean(art),'g*')
    %axis([0 duration 0 alpha])
    title(sprintf('ASL kinetics (Normalized)'),'FontWeight','bold');
    legend ('Tag', 'Arterial' , 'Tissue',4)
    xlabel('Time (sec.)')
    fatlines;
    dofontsize(10);
    
    hold off
    % Plot the true perfusion function with the overlayed ASL signal
    % Normalized to the baseline level)
    subplot(222)
    plot(tvec,f/f(5*SECONDS))
    
    hold on
    % plot(tASL,control/control(5),'k--')
    % plot(tASL,tag/tag(5),'k')
    plot(tvec,V / V(5),'g')
    plot( tASL , ASL / ASL(3) , 'r' )
    axis tight
    hold off
    xlabel('Time (sec.)')
    
    legend('Perfusion','Arterial Velocity','ASL signal',4)
    title ('ASL tracking perfusion (Normalized to baseline)','FontWeight','bold')
    fatlines;
    dofontsize(10);
    
    % Plot the correlation between the ASL signal and the true perfusion
    subplot(223)
    %plot(f_sub/f_sub(3),  ASL/ASL(3),'*') , axis([ 0.7 1.3 0.7 1.3]) , axis square
    plot(f_sub/f_sub(3), ASL/ASL(3),'*-'), axis tight
    hold on, plot([1:0.2:1.8],[1:0.2:1.8],'--k')
    title('Correlation Plot','FontWeight','bold')
    xlabel('Flow')
    ylabel('Signal')
    
    fatlines;
    dofontsize(10);
    
    
    % Plot 
    
    ratio = ((ASL/ASL(3) ./ (f_sub /f_sub(3) )));
    subplot(224)
    plot(tASL, ratio), 
    title('Signal/Perfusion','FontWeight','bold')
    xlabel('Time (scans)')
%    hold on, plot(tvec,f/f(5*SECONDS),'--')
    axis tight
    fatlines;
    dofontsize(10);
%     
    hold off
end


if (nargin < 4)
    result = ASL;
else
    %result = sum((data - ASL).^2);
    
    if rpenalty>=0.001
	estimates=[estimates estimates(end)]; 
        result = abs(data - ASL) + rpenalty*(abs(diff(estimates)));
        
    else
        result = abs(data - ASL);
    end
    result(find(isnan(result))) = 0;
    result(find(isinf(result))) = 0;
    residue = [residue ; sum(result)^2];
    %ASL
    %subplot(211),plot(ASL); hold on;plot(ASL),hold off 
    %subplot(212) , 
    %plot(f_sub,'g'); hold on ; drawnow
end
return
