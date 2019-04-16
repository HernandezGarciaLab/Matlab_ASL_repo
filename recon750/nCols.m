function n = nCols(array)
% General-Purpose Toolbox - a package of utilities used primarily for
% in-house analysis workflows.  This set of tools was developed as an
% in-house package by the Stroke Rehab Team of the Functional Electrical
% Stimulation (FES) Center in Cleveland, Ohio. This software is available
% to the scientific community as copyright freeware under the terms of the
% GNU General Public License (GPL).
%
% $Id: nCols.m 7857 2011-07-27 18:27:27Z khrovat $
%
% Authors: Sahil Grover, Kenneth Hrovat, Krisanne Litinas, Roger Cheng (c)
% Stroke Rehab Team of the Functional Electrical Stimulation (FES) Center
% in Cleveland, Ohio.  All rights reserved.
% nCols - returns the number of columns in the input matrix
%
% INPUTS:
% array - matrix
%
% OUTPUTS:
% n - scalar number of columns in array
%
% EXAMPLE:
% a=magic(4);
% nCols(a)

% AUTHOR: Ken Hrovat
% $Id: nCols.m 7857 2011-07-27 18:27:27Z khrovat $

[m, n] = size(array);
