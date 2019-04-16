function niiprojection(datIn,strFileOut,strHeader)
% niiprojection.m: given 3d image, outputs pdf containing 
% orthogonal views of mid-plane sections (axial/coronal/sagittal)
%
% EXAMPLES
% strFileOut = 'test';
% strHeader = 'Module: spm2 homogeniety correction';
% niiprojection('t1overlay_func.nii',strFileOut)
% niiprojection({'t1overlay_func.nii';'et1overlay_func.nii'},strFileOut,strHeader)
%
% Author: Krisanne Litinas
% $Id: niiprojection.m 1279 2014-03-24 20:06:25Z klitinas $
% $HeadURL: svn+ssh://klitinas@anger.engin.umich.edu/svn/matlab/img/trunk/niiprojection.m $

if ischar(datIn)
   datIn = {datIn};
end

casFiles = datIn;
numImgs = length(casFiles);

% Plot
hFig = figure;
set(hFig,'color',[1 1 1]);
set(hFig,'PaperPosition',[0.0 0.0 8.5 11]);
set(hFig,'PaperSize',[8.5 11]);
hAx = tight_subplot(numImgs,3,0.02,0.05,0.05);

for i = 1:numImgs
    strFile = casFiles{i};
    [~,strName] = fileparts(strFile);
    [img,hdr] = read_nii_img_reshape(strFile);
    xDim = hdr.dim(2);
    yDim = hdr.dim(3);
    zDim = hdr.dim(4);
    tDim = hdr.dim(5);

    % If time series, plot middle frame
    if tDim > 1
       img = img(:,:,:,floor(tDim/2)); 
    end
    
    x = floor(xDim/2);
    y = floor(yDim/2);
    z = floor(zDim/2);
    
    % Do something here about scaling
    imgOne = squeeze(img(:,:,z));
    imgTwo = squeeze(img(x,:,:));
    imgThree = squeeze(img(:,y,:));
    imgScale = [0 max(imgOne(:))];
  
    
    % subplot axes indices
    iAx = i*3-2:1:i*3;
    
    % View 1
    axes(hAx(iAx(1)))
    imgView = squeeze(img(:,:,z));
    show(imgView,imgScale);
    axis('square')
    
     % View 2
    axes(hAx(iAx(2)))
    imgView = squeeze(img(x,:,:));
    % imgView = imgView(:,end:-1:1);
    show(imgView,imgScale);
    axis('square')
    title(strName,'interpreter','none');
    
     % View 3
    axes(hAx(iAx(3)))
    imgView = squeeze(img(:,y,:));
    show(imgView,imgScale);
    axis('square')
end

set(hAx,'xticklabel','','yticklabel','');

if exist('strHeader','var')
	my_suptitle(strHeader);
end

print(hFig,'-dpdf',strFileOut);
close(gcf);
