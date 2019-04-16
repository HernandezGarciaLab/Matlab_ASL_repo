function [bln,ind] = anyrangeoverlap(r,blnStrict)
% General-Purpose Toolbox - a package of utilities used primarily for
% in-house analysis workflows.  This set of tools was developed as an
% in-house package by the Stroke Rehab Team of the Functional Electrical
% Stimulation (FES) Center in Cleveland, Ohio. This software is available
% to the scientific community as copyright freeware under the terms of the
% GNU General Public License (GPL).
%
% $Id: anyrangeoverlap.m 7857 2011-07-27 18:27:27Z khrovat $
%
% Authors: Sahil Grover, Kenneth Hrovat, Krisanne Litinas, Roger Cheng (c)
% Stroke Rehab Team of the Functional Electrical Stimulation (FES) Center
% in Cleveland, Ohio.  All rights reserved.
% ANYRANGEOVERLAP - check if any rows of range matrix, r, have overlap
%
% INPUTS:
% r - Nx2 matrix of range values [RNGMIN(:) RNGMAX(:)]
% blnStrict - boolean; true for strictly overlap, so [0 1; 1 2] would not match;
%        only like [0 2; 1 3] would match; if false, then [0 1; 1 2] would
%        match for overlap
%
% OUTPUTS:
% bln - boolean true if there are overlaps; otherwise, false

% Author: Ken Hrovat
% $Id: anyrangeoverlap.m 7857 2011-07-27 18:27:27Z khrovat $

%% Get overlap criterion
if nargin<2
    blnStrict = 0;
end

%% Do diagonal diff for successive, row-to-row differences
dd = diagdiff(r);

%% Find overlaps
if blnStrict
    ind = find(dd<0);
else
    ind = find(dd<=0);
end

%% Check if any overlap exists
bln = ~isempty(ind);
