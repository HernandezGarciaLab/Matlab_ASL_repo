function tileimg2pdf(niiDatIn,varargin)
% EXAMPLE
% strFileNii = 'run_01.nii';
% tileimg2pdf(strFileNii,'o','outfile','f',10);

% Author - Krisanne Litinas
% $Id: tileimg2pdf.m 1279 2014-03-24 20:06:25Z klitinas $
% $HeadURL: svn+ssh://klitinas@anger.engin.umich.edu/svn/matlab/img/trunk/tileimg2pdf.m $


% Read image data
if ischar(niiDatIn)
    strFileNii = niiDatIn;
    [strPath,strName] = fileparts(strFileNii);
    [img,hdr] = read_nii_img_reshape(strFileNii);
    numFrames = hdr.dim(5);
else
    numImgs = length(niiDatIn);
    img = cell(numImgs,1);
    numFrames = zeros(numImgs,1);
    casNames = cell(numImgs,1);
    [strPath,strName] = fileparts(niiDatIn{1});
    for i = 1:numImgs
        [strPath,casNames{i},strExt] = fileparts(niiDatIn{i});
        switch lower(strExt)
            case '.nii'
                [img{i},hdr] = read_nii_img_reshape(niiDatIn{i});
                numFrames(i) = hdr.dim(5);
            case '.mat'
                tmp = load(niiDatIn{i});
                img{i} = tmp.fm;
                %numFrames(i) = 1;
        end
    end
end


% Set defaults
% frameToShow = floor(numFrames/2);
if numFrames == 1
    frameToShow = 1;
else
    frameToShow = floor(numFrames(end)/2);
end
strFilePDFOut = fullfile(strPath,strName);
strHeader = '';
blnRescale =0;


% Parse args
argn = 1;
while (argn <= length(varargin));
    argtype = ( cell2mat(varargin(argn) ));
    argn = argn + 1;
    switch (argtype)
        case 'o'
            strFilePDFOut = cell2mat(varargin(argn));
            argn = argn+1;
        case 'f'
            if (ischar(cell2mat(varargin(argn))))
                frameToShow = str2double(cell2mat(varargin(argn)));
            else
                frameToShow = cell2mat(varargin(argn));
            end
            argn = argn+1;
        case 'h'
            strHeader = cell2mat(varargin(argn));
            argn = argn+1;
        case 'r'
            blnRescale =1;
            
    end
end

hFig = figure;
set(hFig,'color',[1 1 1]);
set(hFig,'PaperPosition',[0.0 0.0 8.5 11]);
set(hFig,'PaperSize',[8.5 11]);

if iscell(img)
    hAx = tight_subplot(numImgs,1,[0.05 0.05],[0.05 0.05]);
    cPos = get(hAx,'pos');
    for i = 1:length(img)
        thisImg = img{i};
        if ndims(thisImg) == 3
            imgShow = squeeze(thisImg(:,:,:));
        else
            imgShow = squeeze(thisImg(:,:,:,frameToShow));
        end
        axes(hAx(i));
        
        if blnRescale
            tmp=thisImg(:,:,floor(end/2),:);
            maxScale = max(tmp(:));
            show(tile(imgShow),[0 maxScale]);
        else
            show(tile(imgShow));
        end
        
        if strcmpi(casNames{i},'fmfile')
            strTitle = sprintf('%s: Reconstructed field map',casNames{i});
        else
            strTitle = sprintf('%s: Reconstructed image (frame #%d)',casNames{i},frameToShow);
        end
        title(strTitle,'interpreter','none')
    end
else
    imgShow = squeeze(img(:,:,:,frameToShow));
    if blnRescale
        tmp=img(:,:,floor(end/2),:);
        maxScale = max(tmp(:));
        show(tile(imgShow),[0 maxScale]);
    else
        show(tile(imgShow));
    end
    hAx = gca;
    strTitle = sprintf('%s: Reconstructed image (frame #%d)',strName,frameToShow);
    title(strTitle,'interpreter','none')
end

set(hAx,'xticklabel','');
set(hAx,'yticklabel','');

% Figure header
if ~isempty(strHeader)
    my_suptitle(strHeader);
end

print(hFig,'-dpdf',strFilePDFOut);
close(gcf);
