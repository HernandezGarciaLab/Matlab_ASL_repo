function [sliceOrder,refSlice] = sliceordervec(numSlices,strSliceDir,strSliceOrder)
% EXAMPLES
% numSlices = 42;
% iSlice = sliceordervec(numSlices,'bu','seq') % default
% [iSlice,ref] = sliceordervec(numSlices,'bu','int')

% $HeadURL: svn+ssh://klitinas@anger.engin.umich.edu/svn/matlab/img/trunk/sliceordervec.m $
% $Id: sliceordervec.m 1688 2015-04-06 19:59:52Z klitinas $

% slice dir default bottom->up
if ~exist('strSliceDir','var')
    strSliceDir = 'bu';
end

% slice order default sequential
if ~exist('strSliceOrder','var')
    strSliceOrder = 'seq';
end

% Direction
switch lower(strSliceDir)
    case 'bu'
        sliceOrder = 1:numSlices;
    case 'td'
        sliceOrder = numSlices:-1:1;
    case 'lr'
        sliceOrder = 1:numSlices;
    case 'rl'
        sliceOrder = numSlices:-1:1;
end
%%refSlice = ceil(numSlices/2) + 1;

% interleave ordering case
if strcmpi(strSliceOrder,'int')
    slicesOne = sliceOrder(1:2:end);
    slicesTwo = sliceOrder(2:2:end);
    sliceOrder = [slicesOne slicesTwo];
end

% Reference slice
iRef = ceil(numSlices/2) + 1;
refSlice = sliceOrder(iRef);