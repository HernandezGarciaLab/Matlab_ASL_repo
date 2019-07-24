function contrast2percent(scale, Z_threshold)
% function contrast2percent(scale)
%
% (c) Luis Hernandez-Garcia @ UM 2019
%
% This function is intended to translate the contrasts that are output
% by spmJr into percent signal change.
% This is useful for ASL quantitative FMRI
% The output images are a percent signal change relative to baseline
% This can be scaled by the input parameter "scale"
% SCALE can be a number (i.e. 100) or an image, like a baseline CBF image
%
% the output images are called percent_?????.img
%
% the images are thresholded by 
%  - the Z score threshold in the corresponding Z-map image, and 
%  - Twice the Z score threshold in the baseline Z-map image (removes background) 
%  


% the baseline image in spmJr is usually the first one
[base h] = read_img('Bhats.img');
base = base(1,:);

% read the contrast images:
confiles = dir('ConBhat_*.img');
% read the corresponding Z maps for thresholding:
zfiles = dir('Zmap_*.img');

    [msk0 h] = read_img(zfiles(1).name);

    msk0(abs(msk0) < 2*Z_threshold) = nan;
    msk0(abs(msk0) >= 2*Z_threshold) = 1;
    
for n=1:length(confiles)
    [tmp h] = read_img(confiles(n).name);
    [msk h] = read_img(zfiles(n).name);
    
    
    msk(abs(msk) < Z_threshold) = nan;
    msk(abs(msk) >= Z_threshold) = 1;
    
    if isstr(scale)
        scaleimg = read_img(scale);
    else
        scaleimg = scale * ones(size(msk));
    end
    
    h.datataype = 32;
    h.bits = 32;
    pct = scaleimg .* msk0 .* msk .* (tmp ./ base);
    write_img(sprintf('percent_%04d.img', n), pct, h);
    
    fprintf('\nWrting  percent signal change for contrast: %d (thresholded image) ...', n); 
end