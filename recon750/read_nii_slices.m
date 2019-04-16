function img = read_nii_slices(strPat)
% EXAMPLE
% strPat = './slice_*.nii';
% img = read_nii_slices(strPat);

% Author - Krisanne Litinas
% $Id: read_nii_slices.m 1516 2014-09-12 20:01:23Z klitinas $

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
tDim = hdr.dim(5);
img = zeros(xDim,yDim,zDim,tDim);

for i = 1:numFiles
    strFile = casFiles{i};
    thisImg = read_nii_img_reshape(strFile);
    img(:,:,i,:) = thisImg(:,:,i,:);
end