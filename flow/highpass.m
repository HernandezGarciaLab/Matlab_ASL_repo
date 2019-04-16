function outdata = highpass(indata, cutoff)
%function outdata = highpass(indata, cutoff)
%
% Luis Hernandez-Garcia @UM 2006
%
% filters data using a gaussian windowed rect function by multiplication in the 
% frequency domain
%
% indata = data to be filtered
% cutoff = cutoff frequency.  It is expressed as a fraction of the Nyquist frequency
%         e.g. - cutoff=0.2 means filter out the bottom 20% of the spectrum
%

% make the KERNEL
KERNEL = ones(size(indata));
cutoff = cutoff * length(KERNEL)/2;
KERNEL(1:cutoff) = 0;
KERNEL(end-cutoff:end) = 0;

% smooth the edges of the kernel with a Gaussian
KERNEL = conv(KERNEL, make_gaussian(length(KERNEL)/2,5,length(KERNEL)));
KERNEL = KERNEL(length(indata)/2: end - length(indata)/2);

% Apply the kernel to the FT of the data
INDATA = fft(indata);
OUTDATA = INDATA .* KERNEL;

outdata = abs(ifft(OUTDATA));

return