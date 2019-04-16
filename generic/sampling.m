close all

% this is the sampling rate representing the 
% continuous time
duration = 50; % seconds
dt0 = 0.01;
Nyquist0 = 1/(2*dt0);
t=0:dt0:duration-dt0;

%  the continuous function under scrutiny
f = 1; % Hz
xt = 2+ cos(f*2*pi *t) ;
%xt = zeros(size(t));
%xt(1) = 1;


% this is the sampling function of interest
dt = 0.05;
Nyquist = 1/(2*dt);
Nyquist = 0.5* 1/dt

% sampling train:
st = zeros(1,length(t));
st(1: dt/dt0 :end) = 1;

% Make the sampling train non-uniform here:
Ncycles = duration/4;
cLength = length(t)/Ncycles;
duty = 3 /4;
C = duty*cLength;
for n=0:Ncycles-1
    st(n*cLength +1 : (n+1)*cLength - C)=0;
end
st((n+1)*cLength : end) = 0;

% do the sampling
xtsamp = xt .* st;

plot(t,xt)
hold on ; stem(t,st,'k');
plot(t,xtsamp,'r'); hold off


% FT of the continuous signal
w = linspace(-Nyquist0, Nyquist0, length(t));

Xw = fftshift(fft(xt))

% FT of the discrete signal (before decimation in frequency)
Xwsamp = fftshift(fft(xtsamp));

figure
plot(w, abs(Xw))
hold on; plot(w, abs(Xwsamp),'r');

% this is where the decimation happens in frequency
wsamps = zeros(size(w));
wsamps(find(w>=-Nyquist & w<=Nyquist)) = 1;
Xwsamp = Xwsamp .* wsamps;

plot(w,abs(Xwsamp),'g')

% the actual decimation happens by throwing out the high freequency
Xwsamp2 = Xwsamp(find(wsamps));
w2 = w(find(wsamps));

% IFT of the sampled signal (no decimation yet)
xtsamp2 = (ifft(Xwsamp));
figure
plot(t, abs(xtsamp2))


% decimation of the sampled signal in time (throw out the zeros)
t3 = t(find(st));
xtsamp3 = xtsamp2(find(st));
hold on
plot(t3, abs(xtsamp3),'r')

% this is what the signal looks after decimation in frequency
xtsamp4 = ifft(Xwsamp2);
t4 = 0:dt:duration-dt;
plot(t4, abs(xtsamp4),'g')




