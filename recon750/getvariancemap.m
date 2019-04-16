function imgVar = getvariancemap(strFileNii,dim,strFileOut)
% getvariancemap.m - calculates variance of an image
% 
% INPUTS
% strFileNii - string, path to .nii file
% dim - [optional] dimension on which to compute the variance (default ndims)
% strFileOut - [optional] string, filename to write out the variance map
%
% OUTPUTS
% imgVar - variance matrix of the input .nii
% [implicit] - if strFileOut specified, .nii file written out containing imgVar
% 
% EXAMPLES
% strFileNii = 'run_01.nii';
% imgOut = getvariancemap(strFileNii,4);
% imgOut = getvariancemap(strFileNii,[],'variance_t.nii');
% imgOut = getvariancemap(strFileNii,3,'variance_z.nii');

% $Id: getvariancemap.m 1519 2014-09-17 15:03:23Z klitinas $

% Read image
[img,hdr] = read_nii_img_reshape(strFileNii);

% If dim not specified, use number of dimensions
if ~exist('dim','var') || isempty(dim)
   dim = ndims(img); 
end

% Variance
imgVar = (std(img,0,dim)).^2 ;

% Write out .nii if output filename given
if exist('strFileOut','var')
   vDim = hdr.dim(2:5);
   vDim(dim) = 1;
   hdr.dim(2:5) = vDim;
   hdr.datatype = 16;
   write_nii(strFileOut,imgVar(:),hdr,0);
end
