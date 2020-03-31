t=linspace(0,10,100);
a = sin(10*t);
b = sin(3*t);

subplot(321)
plot(a)
axis off

subplot(322)
plot(abs(fftshift(fft(a))))
axis off

subplot(323)
plot(b)
axis off

subplot(324)
plot(abs(fftshift(fft(b))))
axis off

subplot(325)
plot(abs(a.*b))
axis off

subplot(326)
plot(abs(fftshift(fft(a.*b))))
axis off
