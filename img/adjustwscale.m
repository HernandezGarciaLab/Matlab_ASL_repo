% function adjustwscale(src,eventdata,hT,hB,img,hFig,x,y,z)
function adjustwscale(src,eventdata,hAxScale,img,hFig,x,y,z)


hChild = get(hFig,'children');
hImgs=findobj(hChild,'type','image');


hLines = get(hAxScale,'children');
hMin = findobj(hLines,'tag','scaleMin');
hMax = findobj(hLines,'tag','scaleMax');
newMin = get(hMin,'xdata');
newMin = round(newMin(1));
newMax = get(hMax,'xdata');
newMax = round(newMax(1));


maxData = max(img(:));
minData = min(img(:));


% Check top thing
imgNew = (img - newMin)*256 / (newMax-newMin);
imgNew(find(imgNew>256)) = 256;
imgNew(find(imgNew<1)) = 1;

% need input of x, y, z to get right slice.
for iPlot = 1:length(hImgs)
    hThisImage = hImgs(iPlot);
    %hData = get(hThisImage,'CData');
    hParent = get(hThisImage,'Parent');
    hFigTag = get(hParent,'tag');
    switch lower(hFigTag)
        case 'fig1'
            %set(hThisImage,'CData',imgNew(x,:,:));
            set(hThisImage,'CData',squeeze(imgNew(:,:,z)));
        case 'fig2'
            set(hThisImage,'CData',squeeze(imgNew(:,y,:))');
        case 'fig3'
            %set(hThisImage,'CData',imgNew(:,:,z));
            set(hThisImage,'CData',squeeze(imgNew(x,:,:))');
    end
    %set(gca,axis tight;
    axes(hParent)
    axis tight
end