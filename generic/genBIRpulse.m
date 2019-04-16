
function bir180 = genBIRpulse(sweepWidth, Tseg)
% function bir180 = genBIRpulse(sweepWidth, Tseg)
% SweepWidth is in KHz
% dt = 1e-3;  % ms
% Tseg is in ms
% Npoints = Tseg/dt;

dt = 1e-3;  % ms
Npoints = Tseg/dt;
t=linspace(0,Tseg,Npoints);
zeta = 15;
kappa = atan(60); % 1.5541;
tankappa = 60;
%wmax = 0.389 *2*pi;  % krad/sec  
wmax = sweepWidth *2*pi;  % krad/sec  

amp1 = tanh(zeta * (1 - (t./Tseg))); 
amp2 = tanh(zeta * (t./Tseg)); 

phase1 = -wmax*Tseg*log( abs(cos(kappa*t/Tseg)) / (kappa*tankappa) );
phase2 = -wmax*Tseg*log( abs(cos(kappa*(t/Tseg -1))) / (kappa*tankappa) );

rf1 = amp1.*exp(i*phase1);
rf2 = amp2.*exp(i*phase2);

bir180 = [rf2 rf1];
bir180 = bir180/max(abs(bir180));
%{
figure(1)
subplot(321), plot(amp1)
subplot(322), plot(amp2)
subplot(323), plot(phase1)
subplot(324), plot(phase2)
subplot(313), plot(abs(bir180))
%}
return