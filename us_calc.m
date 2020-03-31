% calculating heat generated
% numbers from Szabo book
% equation from Duck book

% The pulse from Lee's work on  somatosensory
freq = 0.25 % MHz
P0 = 0.8e6 % Pa

% the tones:
tbd = 300e-3 % s
prf = 500 % Hz
period = 1/prf
pulse_duration = 1e-3
duty_cycle = 0.5
Ncycles = tbd/pulse_duration

% over all, for each stimulus:
ISI = 3 % s
avg_duty = (tbd*duty_cycle + (ISI-tbd)*0)/ISI

% if bone
dz = 1 % cm
alpha = 3.54 % dB / MHz /  cm
Z = 6.36e6 % Rayls

% if brain
dz = 9 % cm
alpha = 0.58 % dB / MHz /  cm
Z = 1.62e6 % Rayls

I0 = P0.^2 / (2*Z)  % Watts / m^2
I0 = I0 * 1e-4      % Watts / cm^2

% derating calculation
% 10*log10 (I0_derated / I0) = -0.3*freq*dz
I0_derated = I0* 10^(-0.3*freq*dz/10 )
P0_derated = P0* 10^(-0.3*freq*dz/20 )

% I_spta:  temporal average of a sinusoid:
I0_spta = I0_derated*(mean(sin(linspace(0,2*pi,100)).^2))
I0_spta = I0_spta * avg_duty

% absorbed power per volume
qv = 2*alpha * freq * I0 * exp(-2*alpha*freq*dz)  % W/cm^3

% mechanical index  (MPa / sqrt(MHz) )
MI = (P0_derated*1e-6)/sqrt(freq)


% from 
% Heating Induced by Therapeutic Ultrasound in the Presence of Magnetic Nanoparticles.
% Kaczmarek K, Hornowski T, Kubov?íková M, Timko M, Koralewski M, Józefczak A.
% ACS Appl Mater Interfaces. 2018 Apr 11;10(14):11554-11564.
h = 125   % W/m2/K    heat transfer coefficient at 3 MHz agar with nanoparticles 
cp = 4170 % J/kg/K   specific heat

deltaT = qv/h
SAR = cp * deltaT/dt


% CW intensity used at 250 kHZ in King paper
% calculate pressure from intensity:
I = 0.2*1e4 % W/m2
rho = 1 % g/ml
c = 1546 % m/s
P = sqrt(I/(2*rho * c))
