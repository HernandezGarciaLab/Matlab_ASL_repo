% Runge-Kutta simulation of flow experiment:
% 
% use this diff. eq. for the arterial: 
% da(t,x)/dt  = Ka * da(t,x)/dx - R1*a(t,x)

warning off

% some constants
alpha = 0.85; 
f = 90 / 60; ;  % ml/sec.ml
lambda = 0.9;   % unitless
R1t = 1/1.2;    % 1/sec.
R1a = 1/1.6;    % 1/sec
Ka =100;        % mm/sec  ***************
Ttag = 1.5;       % seconds
TR = Ttag + 0.2;  % seconds

SECONDS = 1000;   % steps per second
MM = 5;        % steps per milimeter
dt = 1/SECONDS; % size of time steps
dx = 1/MM;      % size of space steps 

duration = 10;  % seconds
Length = 150;   % mm
tvec = [0:dt:duration];
xvec = [0:dx:Length];

% make an arterial input function (inversion tag function)
cycles = duration/TR;
input = zeros(size(tvec));
for n=0:2:cycles-1
	input(n*TR*SECONDS+1: (n*TR +Ttag)*SECONDS) = alpha;
end

% temporal profile of arterial compartment's signal
art=zeros(size(tvec));
% spatial profile of arterial network.
artX=zeros(size(xvec));
tis = art;


%%%%%%%%%%%%%% ** Diff eq.  **  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for t =2:max(size(tvec))
   
    % here's the kinetics for the arterial compartment 
    % update the whole length X at each iteration:
    artX(1) = input(t);     
    dAdx = diff(artX) / dx;
    dAdx2 = diff(artX,2) / (dx*dx);
    
    artX(2:end-1) = artX(2:end) ...
          - Ka * dAdx(1:end) * dt ...
          - artX(2:end) * R1a * dt ;

    % the tissue compartment gets input from this one element at 120 mm.
    art(t) = artX(120*MM);
    
    % here's the kinetics for the tissue compartment:  
    dtis = ...
        - tis(t-1)*R1t ...	    % T1 decay
        + f * art(t)  ... 	% inflow
        - tis(t-1)*f; 		% outflow
    
    tis(t) = tis(t-1) + dtis * dt; 
 end 
    subplot(211)
    hold off, plot(xvec,artX,'r'); 
    %hold on, plot(dAdx,'g') , hold off
    title(sprintf('t= %2.2f  INPUT= %2.2f  Ttransit=%2.2f',...
        t*dt, input(t) )); 
    axis([0 150 -1 1])
    
    subplot(212)
    hold off
    plot(tvec,art,'g'), 
    hold on , plot(tvec, tis,'r') 
    drawnow    

 
     subplot(212), hold on, plot(tvec, input)
     
