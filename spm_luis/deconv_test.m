data = zeros(1,300);

data(1:30:end) = 1;
irf = -spm_hrf(1);
data = conv(data,irf);
data = data/max(data);
noise = 0.8* rand(1,300);
data = data(1:300)+noise;
%data = data(1:300) + 0.8* rand(1,300)
subplot(211), plot(data)

% deconvolve the stimulus function from the output thorugh
% linear regression
[func v] = hrf_deconv(data',(1:30:300), 300);
subplot(212), plot([func func+v func-v])

% deconvolve the HRF from the output through linear regression
inp1 = hrf_deconv2(data,irf);
figure,
subplot (2,1,1), plot(inp1)

% deconvolve the HRF using a Wiener filter
irf_pad = zeros(size(data));
irf_pad(1:length(irf)) = irf;
filter1 = conj(fft(irf_pad)) ./ ( (abs(fft(irf_pad)).^2 + abs(fft(noise)).^2) );

signal_f = fft(data);
inp2 = ifft (data .* filter1);

subplot (2,1,2), plot(abs(inp2))
