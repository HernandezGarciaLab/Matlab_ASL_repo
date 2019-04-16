function niihdapplyorient(strFileNii,strFileRaw,strFileOut)
% EXAMPLES
% strFileNii = 'run_01.nii';
% strFileRaw = '140514_P09216.7';
%
% [1] write to same .nii file (overwrite old header)
%     niihdapplyorient(strFileNii,strFileRaw)
% 
% [2] write to new .nii file
%     strFileOut = 'run_01_new.nii';
%     niihdapplyorient(strFileNii,strFileRaw,strFileOut)

% Author - Krisanne Litinas
% $HeadURL: svn+ssh://klitinas@anger.engin.umich.edu/svn/matlab/img/trunk/niihdapplyorient.m $
% $Id: niihdapplyorient.m 1475 2014-07-30 18:23:56Z klitinas $

% Original nifti data and header
[img,hdr] = read_nii_img(strFileNii);

% Read pfile for orientation/position info
% Orientation (get into form of Image Orientation Patient in dcm)
hdrRaw = ge_pfilehdr(strFileRaw);

% First 3 elements (iop123) is direction cosine of 1st row 
% Last  3 elements (iop456) is direction cosine of 1st col
% Derive these based on top right/bottom right/top left position info given
% in pfile header
tr = [hdrRaw.image.trhc_R hdrRaw.image.trhc_A hdrRaw.image.trhc_S];
br = [hdrRaw.image.brhc_R hdrRaw.image.brhc_A hdrRaw.image.brhc_S];
tl = [hdrRaw.image.tlhc_R hdrRaw.image.tlhc_A hdrRaw.image.tlhc_S];

iop123 = (tr-tl)/norm(tr-tl);
iop123(1) = -iop123(1);
iop456=(tr - br) / norm(tr -br);
iop456(3) = -iop456(3);
iop = [iop123 iop456];
iop(2) = -iop(2);

nr = hdrRaw.image.imatrix_X;
nc = hdrRaw.image.imatrix_Y;
nz = hdrRaw.rdb.nslices;
dim    = [nc nr nz];

% Position (analogous to Image Position Patient in dcm)
x_pos = hdrRaw.image.normal_L;
y_pos = hdrRaw.image.normal_P;
z_pos = hdrRaw.image.normal_S;
ipp = [x_pos y_pos z_pos];

% Dimensions
x_pix = hdrRaw.image.pixsize_X;
y_pix = hdrRaw.image.pixsize_Y;
pix_spacing = [x_pix y_pix];
slthick = hdrRaw.image.slthick;
slgap = hdrRaw.rdb.user31;
% pix = [pix_spacing slthick];
pix = [pix_spacing slthick+slgap]; % edit to account for if gap > 0

% Fix ipp here if image acquired top-->down order
if strcmpi(char(hdrRaw.series.start_ras),'S')
   %d = [0 0 (nz-1)*slthick]';
   d = [0 0 (nz-1)*(slthick+slgap)]'; % edit to account for if gap > 0
   R = [iop123; iop456; cross(iop456,iop123)];
   ipp = R*d + ipp';
   ipp = ipp';
end

% Get affine does dcm2nii-like magic 
[R,quatern_b,quatern_c,quatern_d,qfac] = getaffine(iop,ipp,pix,nc);

% Get output filename
if nargin == 2
    strFileOut = strFileNii;
end

% Populate header fields and write out the file
hdrOut = hdr;
hdrOut.pixdim(1) = qfac;
hdrOut.qform_code = 1;
hdrOut.sform_code = 1;
hdrOut.quatern_b = quatern_b;
hdrOut.quatern_c = quatern_c;
hdrOut.quatern_d = quatern_d;
hdrOut.qoffset_x = R(1,4);
hdrOut.qoffset_y = R(2,4);
hdrOut.qoffset_z = R(3,4);
hdrOut.srow_x = R(1,:);
hdrOut.srow_y = R(2,:);
hdrOut.srow_z = R(3,:);

write_nii(strFileOut,img,hdrOut,0) 