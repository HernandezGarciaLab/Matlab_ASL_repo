function out = condensetworows(x,row1)
% General-Purpose Toolbox - a package of utilities used primarily for
% in-house analysis workflows.  This set of tools was developed as an
% in-house package by the Stroke Rehab Team of the Functional Electrical
% Stimulation (FES) Center in Cleveland, Ohio. This software is available
% to the scientific community as copyright freeware under the terms of the
% GNU General Public License (GPL).
%
% $Id: condensetworows.m 7857 2011-07-27 18:27:27Z khrovat $
%
% Authors: Sahil Grover, Kenneth Hrovat, Krisanne Litinas, Roger Cheng (c)
% Stroke Rehab Team of the Functional Electrical Stimulation (FES) Center
% in Cleveland, Ohio.  All rights reserved.
row2 = row1+1;
if nRows(x)<row2
    out = x;
    return
end
a = x(row1,1); b = x(row1,2);
c = x(row2,1); d = x(row2,2);
if c <= b
    x(row1,1) = a; x(row1,2) = d;
    x(row2,:) = [];
end
out = x;
