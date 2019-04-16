function aggDiff = fmdiffs(strFileMatOne,strFileMatTwo)
% EXAMPLE
% strFileOne = './func/run_01/fmfile.mat';
% strFileTwo = './func/run_02/fmfile.mat';

% $Id: fmdiffs.m 1279 2014-03-24 20:06:25Z klitinas $
% $HeadURL: svn+ssh://klitinas@anger.engin.umich.edu/svn/matlab/img/trunk/fmdiffs.m $

sOne = load(strFileMatOne);
sTwo = load(strFileMatTwo);

fmOne = sOne.fm;
fmTwo = sTwo.fm;

aggDiff = sum(abs(fmTwo(:) - fmOne(:)));
