function out = mywienerfilt(input, system, noise)

NOISE=fft(noise);
NOISE= mean((NOISE.^2));


INPUT = fft(input);
SYSTEM = fft(system);
G = conj(SYSTEM) ./ ((abs(system)).^2 + NOISE );

OUT = G .* INPUT ;

out = abs(ifft(OUT)+100)-100;

return

% some test code
count = 1;
count2 = 1;
s2 = 0.52; % CNR=8; 0.05;  % noise level relative to signal
tau1=17;
tau2=42;
T = 200;
TP = 20;
H_true = HRF_mat(tau1, tau2, T);
x = zeros(T,1);
onsets = (T-15)* rand(TP,1) +1;
x(round(onsets)) = 1;
n=sqrt(s2)*rand(T,1);
n2=sqrt(s2)*rand(T,1);

a=zeros(T,1);
a(1) = 1;
h = H_true*a;

y = H_true*x + n;
y = y-mean(y);

xhat = mywienerfilt(y,h,n);
hhat = mywienerfilt(y,x,n);

subplot(211)
plot(x), hold on, plot(xhat,'r'), hold off
subplot(212)
plot(h), hold on, plot(hhat,'r'), hold off