function [iCentroid, weightCentroid] = matcentroid(m,strOrient)
% General-Purpose Toolbox - a package of utilities used primarily for
% in-house analysis workflows.  This set of tools was developed as an
% in-house package by the Stroke Rehab Team of the Functional Electrical
% Stimulation (FES) Center in Cleveland, Ohio. This software is available
% to the scientific community as copyright freeware under the terms of the
% GNU General Public License (GPL).
%
% $Id: matcentroid.m 7857 2011-07-27 18:27:27Z khrovat $
%
% Authors: Sahil Grover, Kenneth Hrovat, Krisanne Litinas, Roger Cheng (c)
% Stroke Rehab Team of the Functional Electrical Stimulation (FES) Center
% in Cleveland, Ohio.  All rights reserved.
% matcentroid.m - returns index and value at index of centroid of a 2D or
% 3D matrix
%
% INPUTS
% m - 2D or 3D matrix
%
% OUTPUTS
% iCentroid - index (i,j) for 2D or (i,j,k) for 3D of centroid
% weightCentroid - weight of the centroid, sum for no
%
% EXAMPLE
% m = [1 1 1 1; 1 2 1 1; 1 1 1 1];
% [iCentroid, weightCentroid] = matcentroid(m)
% OR
% m = ones(3,3,3);
% m(:,:,2) = [1 1 1; 1 1 2; 1 1 1];
% [iCentroid, weightCentroid] = matcentroid(m)

% Author - Krisanne Litinas
% $Id: matcentroid.m 7857 2011-07-27 18:27:27Z khrovat $

mDims = size(m);
y = 1:mDims(1);
x = 1:mDims(2);


% Get the mass
weightCentroid = nansum(m(:));

% Temporarily change zeros to nan
iZero = find(m==0);
m(iZero) = nan;

% Normalize 
m = m - nanmin(m(:));

% Repopulate zeros
m(iZero) = 0;

if nargin == 1
    strOrient = 'xyz';
elseif ~strcmpi(strOrient,'ras') && ~strcmpi(strOrient,'xyz')
    error('elmat:invalidindexmode','strOrient should be "xyz" or "ras"');
end

% Account for 2D or 3D input
switch numel(mDims)
    case 2
        [x,y] = meshgrid(x,y);
        iCentroid = [nansum(m(:).*x(:)) nansum(m(:).*y(:))]/nansum(m(:));

    case 3
        z = 1:mDims(3);
        [x,y,z] = meshgrid(x,y,z);
        
        numNan=numel(find(isnan(m)));
        numZero = numel(find(m==0));
        numInactive = numNan+numZero;
        numActive = numel(m)-numInactive;
%         if numActive==1
%             iCentroid = ind2sub(size(mm),find(mm));
%         else
        

        iCentroid = [nansum(m(:).*x(:)) nansum(m(:).*y(:)) nansum(m(:).*z(:))]/nansum(m(:));

        % For 3D do conversion flip x, y dims
        % Apply offset for x-dim [wtf?  I don't know why this works]
        if strcmpi(strOrient,'ras')
            xOffset = mDims(1) + 1;
            error('probably broken/wrong strOrient')
        else
            xOffset = 0;
            iCentroid(2) = -iCentroid(2);
        end
        iCentroid = [xOffset-iCentroid(2) iCentroid(1) iCentroid(3)];
        end
end
