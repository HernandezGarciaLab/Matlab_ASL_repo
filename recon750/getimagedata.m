function [img,hdr] = read_image_data(strImgIn,strReshape)
% read_image_data.m - returns image and header for .nii, .img,
% or pattern (e.g. 'vol') for bunch of 3D volumes in ANALYZE series
% 
% INPUTS
% strImgIn - string, filename (.nii, .img) or rootname (start of image data
%       files, used in case of multiple image files in the series)
% 
% strReshape - 'reshape' to return image matrix in size
%       [xdim,ydim,zdim,tdim] instead of default [tdim xdim*ydim*zdim]
%
% OUTPUTS
% img - 3 or 4D matrix of image data
% hdr - structure, image header
% 
% EXAMPLES
% [img,hdr] = read_image_data('run_01.nii','reshape');
% [img,hdr] = read_image_data('run_01.img','reshape');
% [img,hdr] = read_image_data('vol');

% Author - Krisanne Litinas
% $Id: getimagedata.m 1279 2014-03-24 20:06:25Z klitinas $
% $HeadURL: svn+ssh://klitinas@anger.engin.umich.edu/svn/matlab/img/trunk/getimagedata.m $

[strPath,strName,strExt] = fileparts(strImgIn);

% Case for series in img/hdr fmt (3D)
if isempty(strExt)
    [img, hdr] = read_img_series(strImgIn);
    
else 
    switch(lower(strExt))
        case '.img'
            [img,hdr] = read_img(strImgIn);
        case '.nii'
            [img,hdr] = read_nii_img(strImgIn);
        otherwise
            fprintf('\nInvalid file type "%s".',strExt);
    end
end

% Reshape if specified
if exist('strReshape','var')
    if strcmpi(strReshape,'reshape')
        if strcmpi(strExt,'.nii')
            xdim = hdr.dim(2);
            ydim = hdr.dim(3);
            zdim = hdr.dim(4);
            tdim = hdr.dim(5);
        else
            xdim = hdr.xdim;
            ydim = hdr.ydim;
            zdim = hdr.zdim;
            tdim = hdr.tdim;
        end
    end
    img = reshape(img',xdim,ydim,zdim,tdim);
end
