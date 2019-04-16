function out = condense(in)
% General-Purpose Toolbox - a package of utilities used primarily for
% in-house analysis workflows.  This set of tools was developed as an
% in-house package by the Stroke Rehab Team of the Functional Electrical
% Stimulation (FES) Center in Cleveland, Ohio. This software is available
% to the scientific community as copyright freeware under the terms of the
% GNU General Public License (GPL).
%
% $Id: condense.m 7857 2011-07-27 18:27:27Z khrovat $
%
% Authors: Sahil Grover, Kenneth Hrovat, Krisanne Litinas, Roger Cheng (c)
% Stroke Rehab Team of the Functional Electrical Stimulation (FES) Center
% in Cleveland, Ohio.  All rights reserved.
% in is Nx2 matrix
% out is is Mx2 "condensed" matrix (if any overlap exists M<N); otherwise out = in;
%
% NOTE: this assumes monotonically increasing first column and each row of
% input has column 2 entry greater than or equal to column 1 entry

% dbstack, size(in), pause(1)

%% Initialize output
out = in;

%% Check for any (rows) range overlaps
if ~anyrangeoverlap(out)
    return
end

%% Condense top 2 rows (if needed)
out = condensetworows(out,1);
out = condensetworows(out,2);

%% Return top row & recursion on rows 2:end
out = [out(1,:); condense(out(2:end,:))];
