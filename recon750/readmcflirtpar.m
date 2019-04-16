function s = readmcflirtpar(strFile)
% readmcflirtpar.m - reads a parameter *.par file output from mcflirt
% motion correction.
%
% INPUTS
% strFile - string, .par file to read
%
% OUTPUTS
% s - structure containing x,y,z rotation (rad) and translation (mm) data
%
% EXAMPLE
% strFile = 'v3.2_run_01.par';
% sPar = readmcflirtpar(strFile)

% $Id: readmcflirtpar.m 1279 2014-03-24 20:06:25Z klitinas $
% $HeadURL: svn+ssh://klitinas@anger.engin.umich.edu/svn/matlab/img/trunk/readmcflirtpar.m $

fid = fopen(strFile,'r');
strFmt = ['%f' repmat('  %f',1,5)];
cOut = textscan(fid,strFmt,'delimiter','\n');

s.xr = cOut{1};
s.yr = cOut{2};
s.zr = cOut{3};
s.xt = cOut{4};
s.yt = cOut{5};
s.zt = cOut{6};

fclose(fid);
