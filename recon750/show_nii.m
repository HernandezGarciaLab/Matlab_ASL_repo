function show_nii(strFile,volnum,scale)
% EXAMPLE
% strFile = 'fm5.nii';
% shownii(strFile);

% $Id: show_nii.m 1279 2014-03-24 20:06:25Z klitinas $
% $HeadURL: svn+ssh://klitinas@anger.engin.umich.edu/svn/matlab/img/trunk/show_nii.m $

img = read_nii_img_reshape(strFile);

if ~exist('volnum','var') || isempty(volnum)
    volnum = 1;
end

img = img(:,:,:,volnum);

if exist('scale','var')
    show(tile(img),scale);
else
    show(tile(img));
end
