function strFileOut = temporal_stdev_img(strFileNii)
% temporal_stdev_img.m - given image of .nii format, calculates standard deviation 
% of each voxel across all temporal frames.
% 
% INPUTS
% strFileNii - string, filename of .nii image
% 
% OUTPUTS
% strFileOut - string, filename of .nii output image containing the
% per-voxel time-based standard deviation of the input .nii
% 
% EXAMPLE
% strFileNii = 'run_01.nii';
% strFileOut = temporal_stdev_img(strFileNii);

% Author - Krisanne Litinas
% $Id: temporal_stdev_img.m 1279 2014-03-24 20:06:25Z klitinas $
% $HeadURL: svn+ssh://klitinas@anger.engin.umich.edu/svn/matlab/img/trunk/temporal_stdev_img.m $

if ~exist(strFileNii,'file')
    error('Image file "%s" does not exist.',strFileNii);
end

[img,hdr] = read_nii_img(strFileNii);

imgSTD = std(img);
hdrSTD = hdr;
hdrSTD.dim(5) = 1;

[strPath,strName,strExt] = fileparts(strFileNii);
strNameOut = sprintf('%s_temporal_stdev%s',strName,strExt);
strFileOut = fullfile(strPath,strNameOut);
write_nii(strFileOut,imgSTD,hdrSTD,0);
