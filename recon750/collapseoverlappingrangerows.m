function out = collapseoverlappingrangerows(in)
% General-Purpose Toolbox - a package of utilities used primarily for
% in-house analysis workflows.  This set of tools was developed as an
% in-house package by the Stroke Rehab Team of the Functional Electrical
% Stimulation (FES) Center in Cleveland, Ohio. This software is available
% to the scientific community as copyright freeware under the terms of the
% GNU General Public License (GPL).
%
% $Id: collapseoverlappingrangerows.m 7857 2011-07-27 18:27:27Z khrovat $
%
% Authors: Sahil Grover, Kenneth Hrovat, Krisanne Litinas, Roger Cheng (c)
% Stroke Rehab Team of the Functional Electrical Stimulation (FES) Center
% in Cleveland, Ohio.  All rights reserved.
% in is Nx2 matrix
% out is is Mx2 "condensed" matrix (if any overlap exists M<N); otherwise out = in;
%
% NOTE: this assumes monotonically increasing first column and each row of
% input has column 2 entry greater than or equal to column 1 entry

%% Initialize output
out = in;

%% Check if anything needs to be done
[blnOverlap,indOverlap] = anyrangeoverlap(out);

%% Check for any (rows) range overlaps, collapse as needed
if ~blnOverlap, return, end

%% Collapse overlapping rows
out = combinetheserows(out,indOverlap);

%% Recursively collapse rows as needed
out = collapseoverlappingrangerows(out);
