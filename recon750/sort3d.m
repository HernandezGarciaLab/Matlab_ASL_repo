function [vSort,ix,iy,iz] = sort3d(m,strMode,strZeros)
% General-Purpose Toolbox - a package of utilities used primarily for
% in-house analysis workflows.  This set of tools was developed as an
% in-house package by the Stroke Rehab Team of the Functional Electrical
% Stimulation (FES) Center in Cleveland, Ohio. This software is available
% to the scientific community as copyright freeware under the terms of the
% GNU General Public License (GPL).
%
% $Id: sort3d.m 7857 2011-07-27 18:27:27Z khrovat $
%
% Authors: Sahil Grover, Kenneth Hrovat, Krisanne Litinas, Roger Cheng (c)
% Stroke Rehab Team of the Functional Electrical Stimulation (FES) Center
% in Cleveland, Ohio.  All rights reserved.
% sort3d - sorts 3D array
%
% INPUTS
% m - 3D array of doubles
% strMode - sort order, 'ascend' or 'descend'
% strZeros - 'keepzeros' (default) to consider elements containing value of zero,
%   'removezeros' to not consider zero values 
%
% OUTPUTS
% vSort - column vector, size numel(m) containing elements of m sorted
% ix - column vector, x indices of sorting (size = numel(m))
% iy - column vector, y indices of sorting (size = numel(m))
% iz - column vector, z indices of sorting (size = numel(m))
%
% EXAMPLE
% m = [2 5 1; 4 0 7; 11 3 9];
% m(:,:,2) = [1.5 7.1 12; -1 14 -7; 6 8 -2];
% [vSort,ix,iy,iz] = sort3d(m,'descend') OR
% [vSort,ix,iy,iz] = sort3d(m,'ascend')
%
% NOTES
% Does not include NaNs in output

% Author - Krisanne Litinas
% $Id: sort3d.m 7857 2011-07-27 18:27:27Z khrovat $

% Error check for bad sort mode
if ~strcmpi(strMode,'ascend') && ~strcmpi(strMode,'descend')
    error('common:badsortmode','Invalid sort mode "%s", should be "ascend" or "descend"',strMode);
end

vm = m(:);
[vSort,iSort] = sort(vm,strMode);
iNan = find(isnan(vSort));
vSort(iNan) = [];
iSort(iNan) = [];

if nargin == 2
    strZeros = 'keepzeros';
elseif ~strcmpi(strZeros,'keepzeros') && ~strcmpi(strZeros,'removezeros')
    error('common:invalidarg','Invalid zero handling "%s", specify "removezeros" or "keepzeros"',strZeros);
end

if strcmpi(strZeros,'removezeros')
    iZero = find(vSort==0);
    vSort(iZero) = [];
    iSort(iZero) = [];
end


[ix,iy,iz]=ind2sub(size(m),iSort);
