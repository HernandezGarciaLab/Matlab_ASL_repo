function [img,hdr] = read_nii_img_reshape(strFileNii)
% EXAMPLE
% strFileNii = 'prun_01.nii';
% [img,hdr] = read_nii_img_reshape(strFileNii);

% $Id: read_nii_img_reshape.m 1279 2014-03-24 20:06:25Z klitinas $
% $HeadURL: svn+ssh://klitinas@anger.engin.umich.edu/svn/matlab/img/trunk/read_nii_img_reshape.m $

% Read file
[imgTmp,hdr] = read_nii_img(strFileNii);

% Reshape image
xDim = hdr.dim(2);
yDim = hdr.dim(3);
zDim = hdr.dim(4);
tDim = hdr.dim(5);

if tDim > 1
    img = reshape(imgTmp',xDim,yDim,zDim,tDim);
else
    img = imgTmp;
end
