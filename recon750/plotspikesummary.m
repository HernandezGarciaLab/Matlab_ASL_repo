function mSpikes = plotspikesummary(s,strFileRaw,strFileOut,strHeader)
% EXAMPLE
% [ind,s] = despiker_2014('P47616.7',2,0, 0,2014);
% mSpikes = plotdespikesummary(s);

% $Id: plotspikesummary.m 1703 2015-04-13 18:32:06Z klitinas $
% $HeadURL: svn+ssh://klitinas@anger.engin.umich.edu/svn/matlab/img/trunk/plotspikesummary.m $

[~,~,strExt] = fileparts(strFileRaw);

% Add up the spikes across coils, slices.
casCoils = fieldnames(s);
numCoils = length(casCoils);

% need to output all slices separately
% mSpikes is size [numSlices numVols numCoils]
mSpikes = [];
for c = 1:numCoils
    strCoil = casCoils{c};
    sCoil = s.(strCoil);
    
    casSlices = fieldnames(sCoil);
    numSlices = length(casSlices);
    
    for iSlice = 1:numSlices
        strSlice = casSlices{iSlice};
        
        % ignore first time point (should be the field map)
        badRowsSlice = sCoil.(strSlice).badrows(2:end);
        if isempty(mSpikes)
            mSpikes = badRowsSlice;
        else
            mSpikes(iSlice,:,c) = badRowsSlice;
        end
    end
end



hFig = figure;
set(hFig,'color',[1 1 1]);
set(hFig,'PaperPosition',[0.0 0.0 8.5 11]);
set(hFig,'PaperSize',[8.5 11]);

mColor = rand(numSlices,3);
set(hFig,'DefaultAxesColorOrder',mColor);
% xVec = 0:1:size(mSpikes,2)-1;
xVec = 1:size(mSpikes,2);
if numCoils > 1
    % numSpikesAcrossCoils = sum(m,2);
    numSpikesAcrossCoils = sum(mSpikes,3);
    hAxSumAll = subplot(411);
    % plot(xVec,numSpikesAcrossCoils,'linewidth',2);
    plot(xVec,numSpikesAcrossCoils,'.','markersize',10);
    %set(gca,'xticklabel','');
    set(gca,'pos',[0.13 0.82 0.775 0.092]);
    title(sprintf('Number of spikes summed across all coils (n=%d)',numCoils));
    xlabel('Volume Number');
    ylabel('Number of Spikes');

    padborder(gca,10);
        set(gca,'xlim',[0 size(mSpikes,2)+1]);

    % For each time point, plot the coil with most spikes
    % %     mMaxTimePoint = max(m,[],2);
    % %     hAxTimePt = subplot(412);
    % %     plot(xVec,mMaxTimePoint,'linewidth',2);
    % %     set(gca,'xticklabel','');
    % %     set(gca,'pos',[ 0.13 0.66  0.775 0.09])
    % %     title('Number of spikes (noisiest coil per time point)');
    
    % Sum across slices
    mAcrossSlices = squeeze(sum(mSpikes));
    numSpikesPerCoil = sum(mAcrossSlices,1);
    % %     padborder(gca,10);
    
    % hAxTimePt=subplot(412);
    hAxSliceBased = subplot(412);
    mColorTmp=get(gca,'colororder');
    mColor = [mColorTmp;[153 0 76]/256];
    %set(gcf,'DefaultAxesColorOrder',mColor)
    set(gca,'colorOrder',mColor);
    mSpikesPerSlice = squeeze(sum(mSpikes,2));
    %axes(hAx(2));
%     plot([1:numSlices],mSpikesPerSlice','-','markersize',10);
    hP=plot(1:numSlices,mSpikesPerSlice','.-','markersize',10);

    padborder(gca,10)
    set(gca,'xlim',[0 numSlices+1]);

    xlabel('Slice number');
    ylabel('Number of Spikes');
    title(sprintf('Number of spikes per slice (%d slices), separated by channel',numSlices));
    %legend({'c1';'c2';'c3';'c4';'c5';'c6';'c7';'c8'});
    
% %     % Get worst coil
% %     [~,iMaxCoil] = max(numSpikesPerCoil);
% %     mMaxCoil = mSpikesPerSlice(:,iMaxCoil);
% %     hAxWorstCoil = subplot(413);
% %     plot(xVec,mMaxCoil,'linewidth',2);
% %     title(sprintf('Number of spikes for noisiest coil (#%d)',iMaxCoil));
% %     xlabel('Volume Number');
% %     % set([hAxSumAll hAxTimePt hAxWorstCoil],'linewidth',2,'xlim',[0 xVec(end)]);
% %     set([hAxSumAll hAxSliceBased hAxWorstCoil],'linewidth',2,'xlim',[0 xVec(end)]);
% %     set(gca,'pos',[ 0.13 0.50 0.775 0.09])
% %     padborder(gca,10);
    
    % Get the time point/slice with most number of spikes
    tmp=sum(numSpikesAcrossCoils);
    [maxSpikes,iMax] = max(tmp);

    
    if strcmpi(strExt,'.data')
        sprec1_rds(strFileRaw,'m','l','fy');
        sprec1_rds(strFileRaw,'h','l','fy','t',iMax,'N');
    else
        sprec1(strFileRaw,'m','l','fy');
        sprec1(strFileRaw,'h','l','fy','t',iMax,'N');
    end
    
    d = dir('vol*.nii');
    strFileRec = d(1).name;
    img = read_nii_img_reshape(strFileRec);
    hAxImg = subplot(414);
    show(tile(img));
    % strTitle = sprintf('Time frame (#%d) with most spikes (n=%d)',t-1,maxSpikes);
    strTitle = sprintf('Time frame (#%d) with most spikes (n=%d)',iMax,maxSpikes);
    set(hAxImg,'pos',[0.13 0.08 0.775 0.342],'xticklabel','','yticklabel','');
    title(strTitle);
else
    
%     numSpikesAcrossCoils = m;
        numSpikesAcrossCoils = mSpikes;

    hAx = tight_subplot(3,1,0.05,0.05,[0.08 0.05]);
    
    axes(hAx(1));
    plot([1:size(mSpikes,2)],mSpikes','.','markersize',10);
    padborder(gca,10)
    set(gca,'xlim',[0 size(mSpikes,2)+1])
    xlabel('Volume number');
    % ylabel('Number of Spikes');
    ylabel('Number of Spikes/Volume');
    
    mSpikesPerSlice = sum(mSpikes,2);
    axes(hAx(2));
    plot([1:numSlices],mSpikesPerSlice,'.-','markersize',10,'color','b');
    set(gca,'xlim',[0 numSlices+1]);
    padborder(gca,10)
    xlabel('Slice number');
%     ylabel('Number of Spikes');
    ylabel('Number of Spikes/Slice');

    
    % Get the time point/slice with most number of spikes
    axes(hAx(3));
    % [maxSpikes,t] = max(numSpikesAcrossCoils);
    [maxSpikes,t] = max(sum(numSpikesAcrossCoils,1));
    if strcmpi(strExt,'.data')
        sprec1_rds(strFileRaw,'m','l','fy');
        sprec1_rds(strFileRaw,'h','l','fy','t',t,'N');
    else
        sprec1(strFileRaw,'m','l','fy');
        sprec1(strFileRaw,'h','l','fy','t',t,'N');
    end
    d = dir('vol*.nii');
    strFileRec = d(1).name;
    img = read_nii_img_reshape(strFileRec);
    show(tile(img));
    % strTitle = sprintf('Time frame (#%d) with most spikes (n=%d)',t-1,maxSpikes);
    strTitle = sprintf('Time frame (#%d) with most spikes (n=%d)',t,maxSpikes);
    set(gca,'xticklabel','','yticklabel','');
    title(strTitle);
    
end

% header title
my_suptitle(strHeader);

!rm -f vol*.nii
!rm fmfile.mat
print(hFig,'-dpdf',strFileOut);
close(gcf);
