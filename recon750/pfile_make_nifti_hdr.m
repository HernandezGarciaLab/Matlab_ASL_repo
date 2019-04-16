function hdr = pfile_make_nifti_hdr(strPFile)
% EXAMPLE
% strFileRaw = 'P14336.7';
% niiHdr = pfile_make_nifti_hdr(strFileRaw)

% $HeadURL: svn+ssh://klitinas@anger.engin.umich.edu/svn/matlab/img/trunk/pfile_make_nifti_hdr.m $
% $Id: pfile_make_nifti_hdr.m 1422 2014-05-22 18:00:55Z klitinas $

% Get location info from pfile
rawHdr = ge_pfilehdr(strPFile);

% Position (analogous to Image Position Patient in dcm)
x_pos = rawHdr.image.normal_L;
y_pos = rawHdr.image.normal_P;
z_pos = rawHdr.image.normal_S;
ipp = [x_pos y_pos z_pos];

% Orientation (analogous to Image Orientation Patient in dcm)
norm_R = rawHdr.image.norm_R;
norm_A = rawHdr.image.norm_A;
norm_S = rawHdr.image.norm_S;

% Not sure why y/z seem swapped?
iop = [1 0 0 norm_R norm_S norm_A];

% Dimensions
x_pix = rawHdr.image.pixsize_X;
y_pix = rawHdr.image.pixsize_Y;
pix_spacing = [x_pix y_pix];
slthick = rawHdr.image.slthick;


% Image dimensions
%-------------------------------------------------------------------
% nc = hdr{1}.Columns;
% nr = hdr{1}.Rows;
nr = rawHdr.image.imatrix_X;
nc = rawHdr.image.imatrix_Y;
nz = rawHdr.rdb.nslices;
dim    = [nc nr nz];
% dt     = determine_datatype(hdr{1});

% Orientation information
%-------------------------------------------------------------------
% Axial Analyze voxel co-ordinate system:
% x increases     right to left
% y increases posterior to anterior
% z increases  inferior to superior

% DICOM patient co-ordinate system:
% x increases     right to left
% y increases  anterior to posterior
% z increases  inferior to superior

% T&T co-ordinate system:
% x increases      left to right
% y increases posterior to anterior
% z increases  inferior to superior

analyze_to_dicom = [diag([1 -1 1]) [0 (dim(2)+1) 0]'; 0 0 0 1]; % Flip voxels in y
patient_to_tal   = diag([-1 -1 1 1]); % Flip mm coords in x and y directions

% R  = [reshape(hdr{1}.ImageOrientationPatient,3,2)*diag(hdr{1}.PixelSpacing); 0 0];
% x1 = [1;1;1;1];
% y1 = [hdr{1}.ImagePositionPatient(:); 1];
R  = [reshape(iop,3,2)*diag(pix_spacing); 0 0];
x1 = [1;1;1;1];
y1 = [ipp(:); 1];

% if length(hdr)>1,
if nz>1,
    x2 = [1;1;dim(3); 1];
    
    % y2 = [hdr{end}.ImagePositionPatient(:); 1];
    % Need last (top) slice position
    dz = rawHdr.series.end_loc - rawHdr.series.start_loc;
    op = abs(iop(6) * dz);  % vector length
    if iop(5) == 0
        dy = 0;
    else
        dy = op/iop(5);
    end
    if iop(4) == 0
        dx = 0;
    else
        dx = op/iop(4);
    end
    y2 = [ipp(1)+dx; ipp(2)+dy; ipp(3)+dz; 1];
    

else
    % orient           = reshape(hdr{1}.ImageOrientationPatient,[3 2]);
    orient           = reshape(iop,[3 2]);
    orient(:,3)      = null(orient');
    if det(orient)<0, orient(:,3) = -orient(:,3); end;

    z = slthick;
    x2 = [0;0;1;0];
    y2 = [orient*[0;0;z];0];
end
dicom_to_patient = [y1 y2 R]/[x1 x2 eye(4,2)];
mat              = patient_to_tal*dicom_to_patient*analyze_to_dicom;


N      = nifti;
% pinfos = [ones(length(hdr),1) zeros(length(hdr),1)];
% volume = zeros(dim);
% N.dat  = file_array(fname,dim,dt,0,pinfo(1),pinfo(2));
N.mat  = mat;
N.mat0 = mat;
N.mat_intent  = 'Scanner';
N.mat0_intent = 'Scanner';
% N.descrip     = descrip;
% create(N);
% N.dat(:,:,:) = volume;
hdr = N.hdr;

