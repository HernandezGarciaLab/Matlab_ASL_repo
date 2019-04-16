function img4d_split(strFile4D,strPrefixOut,strTypeOut,strFlip)
% img4d_split.m - given 4d image file, outputs image data in series of 3d files
% 
% INPUTS
% strFile4D - name of 4d image file
% strPrefixOut - string, prefix of output filenames (ex 'vol' to give names like 'vol_001.img', default 'vol')
% strTypeOut - 'a' for analyze .img/.hdr pairs, 'n' for nifti .nii (default 'a')
% strFlip - 'fx', 'fy', 'fz' to flip image in x,y,or z respectively (default no flip)
% 
% OUTPUTS
% [implicit] set of 3d image files image files 
% 
% EXAMPLE
% strFile4D = 'run_01.nii';
% strPrefixOut = 'vol';
% strTypeOut = 'a';
% strFlip = 'fx';
% img4d_split(strFile4D,strPrefixOut,strTypeOut,strFlip)
% 
% NOTE
% 4d img/hdr input --> nii outputs not fully tested yet

% $Id: img4d_split.m 1523 2014-09-19 19:45:14Z klitinas $

[strPath,strName,strExt] = fileparts(strFile4D);
if ~exist('strPrefixOut','var')
    strPrefixOut = strName;
end
if ~exist('strTypeOut','var')
    strTypeOut = 'a';
end
if ~exist('strFlip','var')
    strFlip = '';
end

switch lower(strExt)
    case '.nii'
        [img,hdr] = read_nii_img_reshape(strFile4D);
        if strcmpi(strTypeOut,'a')
            hdr = nii2avw_hdr(hdr);
            hdr.tdim = 1;
        end
    case '.img'
        [img,hdr] = read_img(strFile4D);
        img = reshape(img',[hdr.xdim,hdr.ydim,hdr.zdim,hdr.tdim]);
        hdr.dims(5) = 1; % check this
end

if strcmpi(strFlip,'fx');
    img = img(end:-1:1,:,:,:);
elseif strcmpi(strFlip,'fy')
    img = img(:,end:-1:1,:,:);
elseif strcmpi(strFlip,'fz')
    img = img(:,:,end:-1:1,:);
end

numImgsOut = size(img,4);

for i = 1:numImgsOut
    thisImg = img(:,:,:,i);
    if strcmpi(strTypeOut,'a')
        if numImgsOut == 1
            strNameOut = fullfile(strPath,sprintf('%s.img',strPrefixOut));
        else
            strNameOut = fullfile(strPath,sprintf('%s_%03d.img',strPrefixOut,i));
        end
        write_img(strNameOut,thisImg,hdr);
    else
        strNameOut = fullfile(strPath,sprintf('%s_%03d.nii',strPrefixOut,i));
        hdr = avw2nii_hdr(hdr);
        write_nii(strNameOut,thisImg,hdr,0);
    end
end