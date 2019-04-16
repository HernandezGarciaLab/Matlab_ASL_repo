function compare_fsl_mcflirt(strFileParOne,strFileParTwo)
% EXAMPLE
% strFileOne = 'v3.2_run_01.par';
% strFileTwo = 'v5.0_run_01.par';
% compare_fsl_mcflirt(strFileOne,strFileTwo)

% $Id: compare_fsl_mcflirt.m 1279 2014-03-24 20:06:25Z klitinas $
% $HeadURL: svn+ssh://klitinas@anger.engin.umich.edu/svn/matlab/img/trunk/compare_fsl_mcflirt.m $

sOne = readmcflirtpar(strFileParOne);
sTwo = readmcflirtpar(strFileParTwo);

H = figure;
set(H,'color',[1 1 1]);
set(H,'pos',[110 418 1559 679]);

% Rotations
locdosubplot(sOne.xr,sTwo.xr,'xr',1);
locdosubplot(sOne.yr,sTwo.yr,'yr',2);
locdosubplot(sOne.zr,sTwo.zr,'zr',3);

% Translations
locdosubplot(sOne.xt,sTwo.xt,'xt',4);
locdosubplot(sOne.yt,sTwo.yt,'yt',5);
locdosubplot(sOne.zt,sTwo.zt,'zt',6);

% ---------------------------------------------
function locdosubplot(vOne,vTwo,strLabel,iPlot)
d = abs(vTwo - vOne);
hAx = subplot(2,3,iPlot);
hD = plot(d,'r');
hold on;
hOne = plot(vOne,'b');
hTwo = plot(vTwo,'g');
set(hAx,'xlim',[1 length(vOne)]);
title(strLabel);
