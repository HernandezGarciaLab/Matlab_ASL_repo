function strFileOut = niiflipupdown(strFileNii,strFileOut)
% niiflipupdown.m - given input .nii, flips up-down
% 
% INPUTS
% strFileNii - string, filename of .nii image to be flipped
% strFileOut - string, filename of output (flipped) .nii (default overwrites input filename)
% 
% OUTPUTS
% strFileOut - string, filename of output (flipped) .nii
% 
% EXAMPLE
% strFileNii = './run_01.nii';
% [1] strFileOut = niiflipupdown(strFileNii);
% [2] strFileOut = niiflipupdown(strFileNii,'./flipped_run_01.nii');

% Author - Krisanne Litinas
% $Id: niiflipupdown.m 1279 2014-03-24 20:06:25Z klitinas $
% $HeadURL: svn+ssh://klitinas@anger.engin.umich.edu/svn/matlab/img/trunk/niiflipupdown.m $

% Read nii and get image dims
[img,hdr] = read_nii_img(strFileNii);
xDim = hdr.dim(2);
yDim = hdr.dim(3);
zDim = hdr.dim(4);
tDim = hdr.dim(5);

% Reshape and flip
if tDim > 1
    imgReshape = reshape(img',xDim,yDim,zDim,tDim);
    imgFlip = imgReshape(:,:,end:-1:1,:);
else
    imgFlip = img(:,:,end:-1:1);
end
imgOut = reshape(imgFlip,xDim*yDim*zDim,tDim)';


% Default outfile if not specified (write over input file, but make copy first)
if ~exist('strFileOut','var')
    [strPath,strName,strExt] = fileparts(strFileNii);
    strFileCopy = fullfile(strPath,['before_udflip_' strName strExt]);
    strCmd = sprintf('rsync -a %s %s',strFileNii,strFileCopy);
    unix(strCmd);
    strFileOut = strFileNii;
end

% Write out new file
write_nii(strFileOut,imgOut,hdr,0);
