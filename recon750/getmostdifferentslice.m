function [iSlice,iVol] = getmostdifferentslice(strFileOne,strFileTwo)
% getmostdifferentslice.m - given 2 .nii images with same dimensions, finds
% slicenumber and volume number that is most different across the two
% images
% 
% EXAMPLE
% [iSlice,iVol] = getmostdifferentslice(strFileOne,strFileTwo)

% $Id: getmostdifferentslice.m 1526 2014-09-23 16:05:23Z klitinas $

imgOne = read_nii_img_reshape(strFileOne);
imgTwo = read_nii_img_reshape(strFileTwo);

imgDiff = (imgTwo - imgOne).^2;
sumX = sum(imgDiff,1);
sumXY = sum(sumX,2);
sumXY = squeeze(sumXY);
[~,j] = max(sumXY(:));
[iSlice,iVol] = ind2sub(size(sumXY),j);