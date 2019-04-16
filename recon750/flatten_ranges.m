function inds = flatten_ranges(rowsOfRanges)
% General-Purpose Toolbox - a package of utilities used primarily for
% in-house analysis workflows.  This set of tools was developed as an
% in-house package by the Stroke Rehab Team of the Functional Electrical
% Stimulation (FES) Center in Cleveland, Ohio. This software is available
% to the scientific community as copyright freeware under the terms of the
% GNU General Public License (GPL).
%
% $Id$
%
% Authors: Sahil Grover, Kenneth Hrovat, Krisanne Litinas, Roger Cheng (c)
% Stroke Rehab Team of the Functional Electrical Stimulation (FES) Center
% in Cleveland, Ohio.  All rights reserved.
% EXAMPLE
% rowsOfRanges = [7 8; 9 12];
% flatten_ranges(rowsOfRanges)

% Author: Ken Hrovat
% $Id$

inds = eval(strrep(strrep(vec2str(rowsOfRanges),',',':'),';',' '));
