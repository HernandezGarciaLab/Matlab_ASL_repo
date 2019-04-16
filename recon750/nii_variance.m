function imgVar = nii_variance(strFileNii,strFileOut)
% EXAMPLES
% strFile = 'run_01.nii';
% [1] imgVar = nii_variance(strFile);
% [2] strFileOut = 'variance.nii'; imgVar = nii_variance(strFile,strFileOut);

% $Id: nii_variance.m 1321 2014-04-15 13:43:24Z klitinas $

% Read in data
[img,hdr] = read_nii_img(strFileNii);
hdrOut = hdr;
hdrOut.dim(1) = 3;
hdrOut.dim(5) = 1;
hdrOut.datatype = 16;

% Compute the variance 
imgVar = (std(img,0,1)).^2;

% If specified write out variance map
if exist('strFileOut','var')
    write_nii(strFileOut,imgVar, hdrOut,0);
end

% Output the reshaped matrix
imgVar = reshape(imgVar, [hdrOut.dim(2) hdrOut.dim(3) hdrOut.dim(4)]);