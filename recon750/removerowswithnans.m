function mm = removerowswithnans(m)
% General-Purpose Toolbox - a package of utilities used primarily for
% in-house analysis workflows.  This set of tools was developed as an
% in-house package by the Stroke Rehab Team of the Functional Electrical
% Stimulation (FES) Center in Cleveland, Ohio. This software is available
% to the scientific community as copyright freeware under the terms of the
% GNU General Public License (GPL).
%
% $Id: removerowswithnans.m 7857 2011-07-27 18:27:27Z khrovat $
%
% Authors: Sahil Grover, Kenneth Hrovat, Krisanne Litinas, Roger Cheng (c)
% Stroke Rehab Team of the Functional Electrical Stimulation (FES) Center
% in Cleveland, Ohio.  All rights reserved.
% EXAMPLE
% m = [1 5;2 6; 3 NaN; 4 8];
% mm = removerowswithnans(m)

% Author - Krisanne Litinas
% $Id: removerowswithnans.m 7857 2011-07-27 18:27:27Z khrovat $

mm = m(~any(isnan(m),2),:);
