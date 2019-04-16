function make_nii(img,strFileOut,strFileRaw)
% make_nii.m
% Quick script to make a nifti file given image matrix
%
% EXAMPLE
% img = read_nii_img_reshape('run_01.nii'); % 3/4D image matrix
% strFileOut = 'new.nii';  % file to be written
% strFileRaw = 'P12345.7'; % raw pfile name
% make_nii(img,strFileOut);

% Author - Krisanne Litinas

hdr = define_nii_hdr;

dim = size(img);
hdr.dim = [4 zeros(1,7)];
xdim = dim(1);
ydim = dim(2);
zdim = dim(3);
tdim = dim(4);
hdr.dim(2:5) = dim;

hdrRaw = ge_pfilehdr(strFileRaw);

hdr.datatype = 4;
hdr.bitpix = 16; 

pixszx = hdrRaw.rdb.fov / xdim;
pixszy = hdrRaw.rdb.fov / ydim;

hdr.pixdim(2) = pixszx;
hdr.pixdim(3) = pixszy;
hdr.pixdim(4) = hdrRaw.image.slthick;

tr = hdrRaw.image.tr * 1e-6;
hdr.pixdim(5) = tr; 

img = reshape(img,tdim,(xdim*ydim*zdim));
write_nii(strFileOut,img',hdr,0);
