function [tSNR sSNR] = ASL_snr(mask_threshold)
% function [tSNR sSNR] = ASL_snr(mask_threshold)
%
% The mask trheshhold is computed based on the mean control image
% the program will expect a mean_con image to be present
% the threshold is is the number of standard devations of the signal
% intensity
%
clf
[mc h] = read_img('mean_con');
th = mask_threshold*std(mc(:));

msk = zeros(size(mc));
msk(find (mc>th)) = 1;

[ts h] = read_img('sub.img');
ms = mean(ts,1);  % mean signal map
tsd = std(ts,[],1);  % temporal std dev map

sNoise =  std(ms(msk==0)); % std. dev of the mean signal outside of the brain

tsd = reshape(tsd,h.xdim, h.ydim, h.zdim);
ms = reshape(ms,h.xdim, h.ydim, h.zdim);
msk = reshape(msk,h.xdim, h.ydim, h.zdim);

subplot(223); lightbox(ms ./ tsd+eps, [-2 2],4); title('tSNR per pixel');

ms = ms.* msk;
tsd = tsd.* ~msk;

subplot(221); lightbox(ms); title('temporal mean (inside brain)');
subplot(222); lightbox(tsd); title('temporal std. dev. (outside brain)');
subplot(224), lightbox(msk); title('mask')

colormap bone


% new code
signal = mean(ms(msk==1));
tNoise = mean(tsd(msk~=1));

tSNR = signal/tNoise
sSNR = signal/sNoise

set(gcf,'Name',pwd)
subplot(224)
axis off
text(0,-20,['temp SNR= ' num2str(tSNR)]);
text(0,-50,['spat SNR= ' num2str(sSNR)]);
drawnow
return
