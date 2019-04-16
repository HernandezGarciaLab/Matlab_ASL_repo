function [mDiff,indRun] = rundiffs(strDirFunc)
% rundiffs.m - for a given functional task, loads any .nii images and
% calculates summed absolute difference values across all images
% 
% INPUTS
% strDirFunc - string, path to functional dir (below it should be the "run_##" subdirs)
% 
% OUTPUTS
% mDiff - numTotalTimePoints x numSlices matrix of difference values
% indRun - vector containing indices of mDiff corresponding to start of each run
% [implicit] shows plot of mDiff with vert lines at indices indRun
% 
% EXAMPLE
% strDir = '/export/subjects/lms11als00117/func';
% [mDiff,indRun] = rundiffs(strDir);

% Author - Krisanne Litinas
% $Id: rundiffs.m 1279 2014-03-24 20:06:25Z klitinas $
% $HeadURL: svn+ssh://klitinas@anger.engin.umich.edu/svn/matlab/img/trunk/rundiffs.m $

% Get .nii list
strPatNii = fullfile(strDirFunc,'*','run*.nii');
casFiles = simpleglob(strPatNii);
casFiles = sort(casFiles);
numFiles = length(casFiles);

% Load and concatenate image data
fprintf('\nGetting differences across %d runs.\n',numFiles);
imgCat = [];
indRun = [];
for i = 1:numFiles
    strFile = casFiles{i};
    img = read_nii_img_reshape(strFile);
    imgDims = size(img);
    imgCatDims = size(imgCat);
    if isempty(imgCat) || isequal(imgDims(1:3), imgCatDims(1:3))
        imgCat = cat(4,imgCat,img);
        indRun = [indRun; imgDims(4)];
    else
        fprintf('\nWarning: img %s does not have same dims as previous run(s), skipping.\n',strFile);
    end
end

% Get indices of output matrix corresponding to start of each run
% indRun = cumsum(indRun);
% indRun = [1; indRun];
indRun = cumsum([1; indRun(1)-1; indRun(2:end)]);
indRun(end) = [];

% Get summed difference 
d = diff(imgCat,1,4);
mDiff = squeeze(sum(sum(abs(d))))';

% Plots
hFig = figure;
set(hFig,'color',[1 1 1]);
hDiff = plot(1:length(mDiff),mDiff);
hold on;
hAx = gca;
set(hAx,'xlim',[1 length(mDiff)]);
set(hAx,'xtick',[],'linewidth',2);
title(strDirFunc);
yLims = get(hAx,'ylim');
hLines = line([indRun indRun]',repmat(yLims(:),1,length(indRun)));
set(hLines,'color',[0.75 0.75 0.75],'linewidth',2,'linestyle','--');
delete(hDiff);
plot(1:length(mDiff),mDiff);
