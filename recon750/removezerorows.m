function a = removezerorows(a)
% General-Purpose Toolbox - a package of utilities used primarily for
% in-house analysis workflows.  This set of tools was developed as an
% in-house package by the Stroke Rehab Team of the Functional Electrical
% Stimulation (FES) Center in Cleveland, Ohio. This software is available
% to the scientific community as copyright freeware under the terms of the
% GNU General Public License (GPL).
%
% $Id: removezerorows.m 7857 2011-07-27 18:27:27Z khrovat $
%
% Authors: Sahil Grover, Kenneth Hrovat, Krisanne Litinas, Roger Cheng (c)
% Stroke Rehab Team of the Functional Electrical Stimulation (FES) Center
% in Cleveland, Ohio.  All rights reserved.
% EXAMPLE
% a = [
%           1 2 3
%           0 0 0
%           4 5 6
%           0 0 0
%           7 8 9
%      ]
% b = removezerorows(a)
iZeroRows = find(all(a==0,2));
a(iZeroRows,:) = [];
