function plottimecoursesnapshot(strFileNotCorrected,strFileCorrected,strFileOut,strHeader)
% EXAMPLE
% strFileNotCorrected = 'prun_01.nii';
% strFileCorrected = 'tprun_01.nii';
% plottimecoursesnapshot(strFileNotCorrected,strFileCorrected)

% $Id: plottimecoursesnapshot.m 1279 2014-03-24 20:06:25Z klitinas $
% $HeadURL: svn+ssh://klitinas@anger.engin.umich.edu/svn/matlab/img/trunk/plottimecoursesnapshot.m $

% Load data, get time course vectors for top/bot/mid voxels
[vTopOne,vBotOne,vMidOne,xDimOne,yDimOne,zDimOne] = locgettimecourse(strFileNotCorrected);
[vTopTwo,vBotTwo,vMidTwo,xDimTwo,yDimTwo,zDimTwo] = locgettimecourse(strFileCorrected);
[~,strNameOne] = fileparts(strFileNotCorrected);
[~,strNameTwo] = fileparts(strFileCorrected);

% Plots
hFig = figure;
set(hFig,'color',[1 1 1]);
set(hFig,'PaperPosition',[0.0 0.0 8.5 11]);
set(hFig,'PaperSize',[8.5 11]);
hAx = tight_subplot(3,1,0.05,0.05,[0.05 0.05]);

% tDim = numel(vTopOne);
axes(hAx(1));
locdosubplot(vTopOne,vTopTwo);
hTop = gca;
strTitle = sprintf('Voxel time course before/after slice time correction: [%d %d %d]',floor(xDimOne/2),floor(yDimOne/2),zDimOne);
title(strTitle);

axes(hAx(2));
locdosubplot(vMidOne,vMidTwo);
hMid = gca;
strTitle = sprintf('Voxel time course before/after slice time correction: [%d %d %d]',floor(xDimOne/2),floor(yDimOne/2),floor(zDimOne/2));
title(strTitle);

axes(hAx(3));
locdosubplot(vBotOne,vBotTwo);
hBot = gca;
xlabel('Volume number');
strTitle = sprintf('Voxel time course before/after slice time correction: [%d %d %d]',floor(xDimOne/2),floor(yDimOne/2),1);
title(strTitle);
set([hMid hTop],'xticklabel','');


if exist('strHeader','var')
    my_suptitle(strHeader);
end

axes(hAx(1));
hLegend = legend(strNameOne,strNameTwo);
set(hLegend,'pos',[0.79 0.9 0.15 0.09],'interpreter','none')

print(hFig,'-dpdf',strFileOut);
close(gcf);

% -----------------------------------------------------------------
function [vTop,vBot,vMid,xDim,yDim,zDim] = locgettimecourse(strFile)
img = read_nii_img_reshape(strFile);
xDim = size(img,1);
yDim = size(img,2);
zDim = size(img,3);
x = floor(xDim/2);
y = floor(yDim/2);
zMid = floor(zDim/2);

vBot = squeeze(img(x,y,1,:));
vTop = squeeze(img(x,y,end,:));
vMid = squeeze(img(x,y,zMid,:));

% ------------------------------
function locdosubplot(vOne,vTwo)
tDim = numel(vOne);
if ~isequal(vOne,vTwo)
    plot(1:tDim,vOne,'b.-','linewidth',1.25)
    hold on;
    plot(1:tDim,vTwo,'g.-','linewidth',1.25) 
else
    plot(1:tDim,vOne,'color',[0 0.5 0.5],'linewidth',1.25);
    hold on;
    plot(1:2:tDim,vOne(1:2:end),'b.');
    plot(2:2:tDim,vTwo(2:2:end),'g.');
end
set(gca,'xlim',[1 tDim]);
