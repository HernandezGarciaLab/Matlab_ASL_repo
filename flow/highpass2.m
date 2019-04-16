%function outdata = highpass2(indata, cutoff)
%
% Luis Hernandez-Garcia @UM 2008 and
% Daniel B. Rowe @ MCW 2008
%
% filters data using a gaussian windowed rect function by multiplication in the 
% frequency domain
%
% indata = data to be filtered, n TRs by p voxels
% cutoff = cutoff frequency.  It is expressed as a fraction of the Nyquist frequency
%         e.g. - cutoff=0.2 means filter out the bottom 20% of the spectrum

function outdata = highpass2(indata, cutoff)


% make the KERNEL
[n,p]=size(indata);

KERNEL = ones(n,1);
cutoff = round(cutoff * n/2); 
KERNEL(1:cutoff) = 0;, KERNEL(n-cutoff:n) = 0;

% smooth the edges of the kernel with a Gaussian
KERNEL = conv(KERNEL, make_gaussian(n/2,5,n));
KERNEL = transpose(KERNEL(n/2: 2*n - n/2-1));
KERNEL(1,1)=1; % keep mean

% Apply the kernel to the FT of the data
INDATA = fft(indata);
OUTDATA = INDATA .* kron(ones(1,p),KERNEL);

% figure(1)
% plot(abs(INDATA)); hold on; plot(abs(OUTDATA),'r'); hold off

outdata = ifft(OUTDATA);
% figure(2)
% plot(abs(indata)); hold on; plot(abs(outdata),'r'); hold off

return

function result=make_gaussian(m,sd,pts)
%function result=make_gaussian(m,sd,pts)
%
% x = linspace(0,pts,pts);
% result = exp( - (x-m).^2 / sd);
% result = result/sum(result);
x = linspace(0,pts-1,pts);
result = exp( - (x-m).^2 / sd);
result = result/sum(result);
return
