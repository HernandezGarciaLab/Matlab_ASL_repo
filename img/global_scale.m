function global_scale(file, Nsd)
% function global_scale(filename, Nsd)
%
% LHG 9/11/14
%
% this function's job is to scale all the images in the time series so that
% the mean value for the time series is 1000 inside a mask
%
% Nsd : number of standard deviations used for the mask threshold
% the mask is made by thresholding the mean image
%
% Note that it doesn't scale images so that they are 1000 individually,
% just the mean of the time series.
%
% Note that this function overwrites the original file with the rescaled
% version.
%
fprintf('\nRecaling time series : %s ...', file);
[s h] = read_img(file);
ms = mean(s,1);
threshold = std(ms);
msk = zeros(size(ms));
msk(ms>threshold) = 1;
ms = ms .* msk;

lightbox(reshape(ms,h.xdim, h.ydim, h.zdim));
title('Using these pixels for the average');

gscale = 1000/mean(ms(ms > 0));
s = s*gscale;
write_img(file, s, h);

fprintf(' ... done\n')

return
