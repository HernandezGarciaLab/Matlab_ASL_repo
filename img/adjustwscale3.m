function adjustwscale3(img,hFig,x,y,z)
% adjustwscale3.m - used in ortho to do scaling of orthogonal views.
% 
% INPUTS
% img - 3D image data to plot
% hFig - figure handle of orthoviews
% x - integer, x-coordinate 
% y - integer, y-coordinate
% z - integer, z-coordinate

% Author - Krisanne Litinas
% $Id: adjustwscale3.m 737 2013-07-31 13:57:39Z klitinas $

% Find the images
hChild = get(hFig,'children');
hImgs=findobj(hChild,'type','image');

% Cycle through all 3 images and plot appropriate slices
for iPlot = 1:length(hImgs)
    hThisImage = hImgs(iPlot);
    hParent = get(hThisImage,'Parent');
    hFigTag = get(hParent,'tag');
    switch lower(hFigTag)
        case 'fig1'
            set(hThisImage,'CData',squeeze(img(:,:,z)));
        case 'fig2'
            set(hThisImage,'CData',squeeze(img(:,y,:))');
        case 'fig3'
            set(hThisImage,'CData',squeeze(img(x,:,:))');
    end
    axes(hParent)
%     axis tight
end