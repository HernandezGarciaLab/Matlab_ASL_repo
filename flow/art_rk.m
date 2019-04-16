

% Runge-Kutta simulation of flow experiment:
warning off

% frequency of sinusoidal activation paradigm:
SECONDS = 10;  % step size =100 points / second
alpha=0.85;

R1a = 1/10.5;    % 1/sec

Ka = 9 ;     % 1/sec  based on inspection of the curves in the Ye paper.

Ttransit = 1.2;   % seconds
Ttag = 0.9 ; 
TR = Ttag + 0.2;

duration = 10*SECONDS;
t = [0:1/SECONDS:duration];


% sequence parameters:

% make an arterial input function (inversion tag function)
cycles = duration/TR;
input = zeros(size(t));
for n=0:2:cycles-1
	input(n*TR*SECONDS+1: (n*TR +Ttag)*SECONDS) = alpha;
end

% temporal profile of arterial compartment's signal
art=zeros(1,duration *SECONDS);

% spatial profile of arterial network.
art0=zeros(1,2*SECONDS);

Ka= Ka *ones(size(art));  % define a baseline flow
Ttransit = Ttransit * ones(size(art));  % define a baseline transit time

for k=1 :max(size(t))
    
	% here's the kinetics for the arterial compartment:
    
    % spatial effect of dispersion:
    % one spatial x increment is equivalent to 
    % the distance traveled in one temporal increment    
    % so x = Ttransit means the distance to the tagging plane
    dart0(1) = input(k)*Ka(k)...
        -art0(1)*Ka(k) ...
        -art0(1)*R1a;
 
    art0(1) = art0(1) + dart0(1) *1/SECONDS;    

    for x=2:max(size(art0))
        
        dart0(x) = art0(x-1)*Ka(k) ...
            -art0(x)*Ka(k) ...
            -art0(x)*R1a;
        
        art0(x) = art0(x) + dart0(x)*1/SECONDS;    
    end
  
    subplot(211)
    plot(art0); title(sprintf('t= %2.2f  INPUT= %2.2f dart0(1)=%2.2f Ttransit=%2.2f',...
        k/SECONDS, input(k), dart0(1), Ttransit(k))); 
    axis([0 2*SECONDS 0 1]); 
    % here's the kinetics for the tissue compartment:
   art(k) = art0(Ttransit(k)*SECONDS);
   subplot(212)
   plot(art)
   drawnow
end

