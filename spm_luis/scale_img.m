function scale_img(target_img, scalefactor_img);
%
% function scale_img(target_img, scalefactor_img);
% This function is to normalize the signal changes to a baseline signal
%  Note that this will make the noise outside the brain go crazy...
%
% usage:
%       scale_img('Contrast_img.img', 'Beta_0_estimate.img');
%
% spm_smooth(scalefactor_img, ['s' scalefactor_img], [8 8 8]);
%
% [den h] = read_img(['s' scalefactor_img]);
% [num h] = read_img(target_img);
% out = 100*num ./den;
% write_img(['scaled_' target_img], out, h);
% 

fprintf('Smoothing ... %s', scalefactor_img);
spm_smooth(scalefactor_img, ['s' scalefactor_img], [8 8 8]);
[den h] = read_img(['s' scalefactor_img]);

[num h] = read_img(target_img);

out = 100*num ./den;

write_img(['scaled_' target_img], out, h);

%{
%for debugging purposes
subplot(131); lightbox(num); title('Original')
subplot(132); lightbox(den); title('Denominator')
subplot(133); lightbox(out); caxis([-100 100]); title('Result (Percent signal)')
%}

return