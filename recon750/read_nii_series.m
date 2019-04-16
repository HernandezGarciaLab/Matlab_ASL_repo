function [imgOut,hdrOut] = read_nii_series(strPat,strFileOut)
% read_nii_series.m - reads time series of image data that's been saved in
% .nii format (one .nii per volume).  Similar to read_img_series for
% img/hdr pairs.
% 
% INPUTS
% strPat - string, file pattern of .nii files
% strFileOut [optional] - string, filename to write 4D image 
% 
% OUTPUTS
% imgOut - matrix of size [tdim xdim*ydim*zdim] containing image data
% hdrOut - header structure for the series
% 
% EXAMPLE
% strPat = './both_norotation/vol*.nii';
% [img,hdr] = read_nii_series(strPat);

% Author - Krisanne Litinas
% $Id: read_nii_series.m 1515 2014-09-10 20:02:16Z klitinas $

% Get array of filenames
[strPath,~,strExt] = fileparts(strPat);

if isempty(strExt)
    strPat = [strPat '.nii'];
elseif ~strcmpi(strExt,'.nii');
    fprintf('\nError: only works with .nii files!\n');
    return;
end

s = dir(strPat);
if isempty(s)
    fprintf('\nNo files found matching pattern %s\n',strPat);
    return;
end

casFiles = {s(:).name};
casFiles = sort(casFiles);
casFiles = fullfile(strPath,casFiles);
numFiles = length(casFiles);

hdr = read_nii_hdr(casFiles{1});
xDim = hdr.dim(2);
yDim = hdr.dim(3);
zDim = hdr.dim(4);
tDim = numFiles;
imgOut = nan(tDim,xDim*yDim*zDim);

for i = 1:numFiles
    strFile = casFiles{i};
    thisImg = read_nii_img(strFile);
    imgOut(i,:) = thisImg(:);
end

hdrOut = hdr;
hdrOut.dim(5) = tDim;
if exist('strFileOut','var')
    hdrOut = hdr;
    hdrOut.dim(5) = tDim;
    [~,~,strExt] = fileparts(strFileOut);
    if ~strcmpi(strExt,'.nii')
        strFileOut = [strFileOut '.nii'];
    end
    write_nii(strFileOut,imgOut,hdrOut,0);
end