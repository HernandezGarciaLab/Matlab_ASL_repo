function z = interleave_matrices(x,y)
% General-Purpose Toolbox - a package of utilities used primarily for
% in-house analysis workflows.  This set of tools was developed as an
% in-house package by the Stroke Rehab Team of the Functional Electrical
% Stimulation (FES) Center in Cleveland, Ohio. This software is available
% to the scientific community as copyright freeware under the terms of the
% GNU General Public License (GPL).
%
% $Id: interleave_matrices.m 7857 2011-07-27 18:27:27Z khrovat $
%
% Authors: Sahil Grover, Kenneth Hrovat, Krisanne Litinas, Roger Cheng (c)
% Stroke Rehab Team of the Functional Electrical Stimulation (FES) Center
% in Cleveland, Ohio.  All rights reserved.
% INTERLEAVE_MATRICES interleave 2 matrices.
%
%   z = interleave_matrices(x,y)
%   z = [ x(:,1) y(:,1) x(:,2) y(:,2) ... x(:,C), y(:,C) ];
%
%   INPUTs:
%       x: RxC matrix
%       y: RxC matrix
%
%   OUTPUT:
%       z: Rx(2*C) matrix
%
% EXAMPLE:
% interleave_matrices([1 2 3 4]', [5 6 7 8]')
%
%   ADAPTED FROM WORK BY: Jason Blackaby <jblackaby@gmail.com>

%% Error checking
[Rx,Cx] = size(x);
if(isempty(x) && isempty(y))
    z = []; return;
elseif(isempty(x))
    z = y; return;
elseif(isempty(y))
    z = x; return;
end
if ~isequalsize(x,y)
    error('inputs must have same size')
end

%% Initialize z
z = nan*ones(Rx,2*Cx);

%% Build indices into z for x and y.
icx = 1:2:2*Cx-1;
icy = 2:2:2*Cx;

%% Form z using the indices.
z(:,icy) = y;
z(:,icx) = x;
