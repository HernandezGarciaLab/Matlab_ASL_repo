clear all; close all

% standard deviation of the gaussian noise
M0 = 100;
sd = 0.5;
Nticks = 500;

rho1 = 0.8;
t = linspace(0, 100, Nticks); 
Gnoise = sd*randn(Nticks,1);
Anoise =  sd*randn(Nticks,1);

signal = sin(3*t)  ;
noisy = zeros(size(signal));
signal = signal';

for n=2 : length(Anoise)
    Anoise(n) =  rho1 * Anoise(n-1) + Anoise(n);
end

signal2=signal;
for n=2 : length(signal)
    signal2(n) =  rho1 * signal2(n-1) + signal2(n) + Gnoise(n);
end

Anoise2 = Gnoise + circshift(Gnoise,1);
Anoise = Anoise*sd/std(Anoise);

Anoise2 = Anoise2*sd/std(Anoise2);

subplot(422)
plot(signal)
axis([0 500 -3 3])

subplot(423)
plot( Gnoise)
axis([0 500 -3 3])

subplot(424)
plot(signal + Gnoise)
axis([0 500 -3 3])

subplot(425)
plot(Anoise)
hold on
plot(Anoise2,'r')
axis([0 500 -3 3])

subplot(426)
plot(signal + Anoise)
axis([0 500 -3 3])

subplot(428)
plot(signal2)
axis([0 500 -3 3])

