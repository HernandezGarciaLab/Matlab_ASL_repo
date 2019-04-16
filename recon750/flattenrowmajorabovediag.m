function v = flattenrowmajorabovediag(m)
% General-Purpose Toolbox - a package of utilities used primarily for
% in-house analysis workflows.  This set of tools was developed as an
% in-house package by the Stroke Rehab Team of the Functional Electrical
% Stimulation (FES) Center in Cleveland, Ohio. This software is available
% to the scientific community as copyright freeware under the terms of the
% GNU General Public License (GPL).
%
% $Id: flattenrowmajorabovediag.m 7857 2011-07-27 18:27:27Z khrovat $
%
% Authors: Sahil Grover, Kenneth Hrovat, Krisanne Litinas, Roger Cheng (c)
% Stroke Rehab Team of the Functional Electrical Stimulation (FES) Center
% in Cleveland, Ohio.  All rights reserved.
% EXAMPLE
% m = reshape(1:36,6,6)'
% v = flattenrowmajorabovediag(m)

%% Verify squareness
if diff(size(m))~=0
    error('daly:common:badShape','expected square matrix as input')
end

%% Create logical mask for ABOVE DIAG UPPER
aboveDiagMask = (triu(ones(size(m,1)),1)==1);

%% Apply mask for row-major ordering
m = m';
v = m(aboveDiagMask');
