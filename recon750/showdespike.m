function [mDiffOrig,mDiffDes,mSpikes,mCount,s] = showdespike(strFile,threshold,mDiffOrig)
% EXAMPLE
% strFile = 'P00000.7';
% showdespike(strFile);

if ~exist('threshold','var')
    threshold = 3;
end


% Recon original image
if ~exist('mDiffOrig','var')
    sprec1(strFile,'A');
    mDiffOrig = locgetdiffs;
    !rm vol*
end

% Despike
% despiker(strFile,threshold,0,0,2013);
% [i,s,mSpikes,mCount] = despiker_2014_new2(strFile,threshold,0,0);
[i,s,mSpikes,mCount] = despiker_2014(strFile,threshold,0,0);
% despiker_re_im(strFile,2,0,0,2014);

[strPath,strName,strExt] = fileparts(strFile);
strFileDespiked = fullfile(strPath,sprintf('f_%s%s',strName,strExt));

% Recon despiked image
sprec1(strFileDespiked,'A');
mDiffDes = locgetdiffs;
!rm vol*

% Plots
H = figure; 
set(H,'color',[1 1 1]);

hOrig = subplot(311);
hDiffOrig = plot(mDiffOrig);
set(hOrig,'xticklabel',[])
yLim = get(hOrig,'ylim');
title('raw');

hDes = subplot(312);
hDiffDes = plot(mDiffDes);
set(gca,'ylim',yLim);
title('despiked')

% hNum = subplot(313);
% hSpikes = plot(mSpikes);
% title('number of spikes');

% --------------------------
function mDiff = locgetdiffs
% Read series data and get dimensions
fprintf('\nReading series data....');
[seriesData,hdr] = read_img_series('vol_*');
fprintf('done.');

% Get dimensions and reshape
seriesData = seriesData';
xDim = hdr.xdim;
yDim = hdr.ydim;
zDim = hdr.zdim;
tDim = size(seriesData,2);

bigdat = reshape(seriesData,xDim,yDim,zDim,tDim);

% diffdat=diff(bigdat(:,:,:,5:end),1,4);
diffdat=diff(bigdat(:,:,:,1:end),1,4);

mDiff = squeeze(sum(sum(abs(diffdat)))).';