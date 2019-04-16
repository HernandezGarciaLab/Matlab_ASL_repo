function result = kinetix_func(estimates,t,parms, data)
%function result = kinetix_func(estimates,t, parms, [data] )
%
% Euler simulation of flow experiment:
% for use with lsqnonlin
%
% use this diff. eq. for the arterial: 
% da(t,x)/dt  = Vart * da(t,x)/dx - R1*a(t,x)
%
% f = estimates(:,1);
% Vart = estimates(:,2);
%
% Ttag = parms(1);     % seconds
% del =  parms(2);	 %seconds
% crushers= parms(3);   % boolean
% R1t =  parms(4);    % 1/sec.
% R1a =   parms(5)   % 1/sec
% xchange_time =  parms(6);  % sec.
% alpha =  parms(7); % no units
% dist = parms(8);   % mm
%
% Typical values:
% Ttag =3.8;     % seconds
% del = 0.02;	 %seconds
% crushers=0;
% R1t = 1/1.2;    % 1/sec.
% R1a = 1/1.6;    % 1/sec
% xchange_time = 0.1;  % sec.
% alpha = 0.85; 
% dist = 120 ;   % mm
% Vart0 = 100 %mm/sec 
%
% transit_time = dist/Vart
% TR = Ttag + 0.2;  % seconds
% f = 90 / 60; ;  % ml/sec.ml
% lambda = 0.9;   % unitless


global residue rpenalty

warning off

%f = estimates(:,1);
%Vart = estimates(:,2);

f = estimates;

% Put sequence parameters here:
Ttag = parms(1);     % seconds
del =  parms(2);	 %seconds
crushers= parms(3);
R1t =  parms(4);    % 1/sec.
R1a =   parms(5);   % 1/sec
xchange_time =  parms(6);  % sec.
alpha =  parms(7); 
dist = parms(8);
Vart0 = parms(9);

TR = Ttag + 0.2;  % seconds

% assume that the change in mean Vart is 1/4 of the change in f
df = (f-f(1))/f(1);
dV = 0.4*df;
Vart = Vart0 + Vart0 * dV;
SECONDS = 300;  % steps per second
MM = 2;  % steps per milimeter
dx = 1/MM;
dt = 1/SECONDS;
% Note that this term   must be  less than 1 for all t :   Vart(t) * dAdx * dt
% otherwise the system becomes unstable

Length = 145;   % mm
duration = (length(f))*TR;  % seconds
xvec = [0:dx:Length];
%tvec = [TR:dt:duration];
tvec = [0:dt:duration-TR];

doFigs=0; 
show_uptake=1;
lambda = 0.9;   % unitless
transit_time = dist./Vart;
%keyboard

%tt = [TR:TR:duration]';
tt = [0:TR:duration-TR]';
% upsample the Vart anf f functions to match the simulation.
f = interp1(tt, f, tvec);
Vart = interp1(tt, Vart, tvec);

%find(isnan(f))
%find(isnan(Vart))

% sampling functions (image and subtraction)
sampl = zeros(size(tvec));
samplASL = sampl;
sampl((Ttag+del)*SECONDS:TR*SECONDS:end)=1;
sampleTimes = (Ttag+del):TR:duration;


% make an arterial input function (inversion tag function)
cycles = duration/TR;
input = zeros(size(tvec));
for n=0:2:cycles-2
	input(n*TR*SECONDS+1: (n*TR+Ttag)*SECONDS+1) = alpha;
end

% temporal profile of arterial compartment's signal
art=zeros(size(tvec));
% spatial profile of arterial network.
artX=zeros(size(xvec));

art_tmp = art;
tis = art;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Adiff=[]; Tdiff=[]; Tsignal=[]; Asignal=[];

%%%%%%%%%%%%%% ** Diff eq.  **  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Note that for the RK, simulation we need a dt/2 interval.
% Trick: what we have is that dt is really dt/2
% update the function every other dt
for t = 2 :max(size(tvec))
   
    % here's the kinetics for the arterial compartment 
    % update the whole length X at each iteration:
    artX(1) = input(t);     
    dAdx = diff(artX) / dx; 
%     artX(2:end) = artX(2:end) ...
%           - Vart(t) * dAdx * dt ...
%           - artX(2:end) * R1a * dt ;

%keyboard
    y0 = artX(2:end);
    k1 = ( -Vart(t)*dAdx - artX(2:end) * R1a ); 
    y1 = y0 + dt*k1;
    k2 = ( -Vart(t+1)*dAdx  - y1 * R1a ); 
    y2 = y0 + dt*k2;
    k3 = ( -Vart(t+2)*dAdx  - y2 * R1a ); 
    y3 = y0 + 2*dt*k3;

    artX(2:end)=artX(2:end) + 2*dt*(y0/6 + y1/3 + y2/3 + y3/6) ;

%    advance = round(Vart(t)*dt*MM);
%    fprintf(' %d - %d\n',t, advance');
%    %keyboard
%    artX(1+advance:end)= artX(1:end-advance);
%    artX(1:1+advance) = input(t);   
%    artX = artX *(1- R1a*dt);

    % the tissue compartment is only this one element at 20 mm.
    art(t) = artX(dist*MM);
    artX(dist*MM:end) = artX(dist*MM:end) -  f(t) * artX(dist*MM:end) * dt;  

    % here's the kinetics for the tissue compartment:  
    if ( t >= xchange_time*SECONDS + 1)
	%  Euler method
        dtis = ...
            - tis(t-1)*R1t ...	    % T1 decay
            + f(t) * art(t - xchange_time*SECONDS)  ... 	% inflow
            ;%- tis(t-1)*f(t); 		% outflow
       
        tis(t) = tis(t-1) + dtis * dt;


% Runge-Kutta:

%        y0 = tis(t-1);
%        k1 = f(t-1) * art(t -1- xchange_time*SECONDS) - y0*R1t ;
%        y1 = y0 + k1*dt/2;
%
%	k2 = f(t) * art(t - xchange_time*SECONDS) - y1*R1t ;
%	y2 = y0 + k2*dt/2;
%
%       k3 = f(t) * art(t - xchange_time*SECONDS) - y2*R1t ;
%	y3 = y0 + k3*dt/2;
%
%	tis(t) = tis(t-1) + dt*(y0/6 + y1/3 + y2/3 + y3/6) ;

    end
    
    % effect of crushing the tissue and arterial components:
    if sampl(t)==1
        %fprintf('*');
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
% there could be a problem with NaN
if isnan(ASL(1))
	ASL(1) = ASL(5);
end
if isnan(ASL(end))
	ASL(end) = ASL(end-4);
end

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
%    title(sprintf('ASL kinetics, phase=%2.2f',phase),'FontWeight','bold');
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


if (nargin < 4) 
	result = ASL;
else
	%result = sum((data - ASL).^2);

        if rpenalty>=0.001
		result = abs(data - ASL) + abs(rpenalty*diff(estimates));
	else
		result = abs(data - ASL);
	end
	result(find(isnan(result))) = 0;
	result(find(isinf(result))) = 0;
	residue = [residue ; sum(result)^2];
	%ASL
	%subplot(211),plot(ASL); hold on;plot(ASL),hold off 
	%subplot(212) , 
	%plot(estimates,'g'); hold on ; drawnow
end
return
