function N = power_ranger02(alpha, power_threshold, effectImg, varImg, Nsubjects)
% function N = power_ranger02(alpha, power_threshold, effectImg, varImg, Nsubjects)
%
% computes the power of a t-test accross
% several images of every voxel.
%
% Luis Hernandez
% University of Michigan
% Last Edit 11-09-2006
%
% The null hypothesis is that the true voxel value is zero
% over all the images in the group
% The alternative hypothesis is that the true voxel value (the effect size)
% is the mean value accross the images
% p-value less than alpha means that the effect is true and we reject the
% nul hypothesis
%
%     The program will compute the power of your test with your
%     current number of samples 
%
% Arguments and defaults:
%   alpha: 	desired significance level (default ... 0.05)
%   power_threshold:  the desired power level (from 0 to 1) for which the program
%            will calculate the minimum number of subjects (default ...0.8)
%   effectImage:  Image containing effect sizes.  We assume that the
%   estimated model parameter value IS the true effect size.  ie - choose a Beta image
%   varImage :   esitmated variance of the Parameter estimate.
%   Nsubjects:  number of subjects used for these estimates
%
% Output:
%   power.img 
%

[x h] = read_img(effectImg);
x = x(:);
sigma_x = sqrt(read_img(varImg));
sigma_x = sigma_x(:);

for v=1:length(x)
    if isfinite(x(v)) && x(v)
        buf = power_finder02(x(v), sigma_x(v)^2, alpha, power_threshold, Nsubjects, 1);
        current_power(v) = buf(1);
        req_N(v) = buf(2);
        end_power(v) = buf(3);
    else
        current_power(v) = nan;
        req_N(v) = nan;
        end_power(v) = nan;
    end
end

h.glmax = 1;
h.glmin = 0;
%write_hdr('power.hdr',h);
write_img('power.img', current_power , h);

%write_hdr('end_power.hdr',h);
write_img('end_power.img',end_power, h);


h.glmax = max(req_N)*4;
h.glmin = 0;
h.datatype = 2;
h.bits = 8;
%write_hdr('N.hdr',h);
write_img('N.img', req_N,h);



return 

