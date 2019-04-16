function [Q,b,c,d,qfac] = getaffine(iop,ipp,pix,ncols)
% getaffine.m - adapted from mricron dcm2nii code to get affine matrix and
% quaternion information needed for nifti header
% 
% INPUTS
% iop - image orientation patient: length 6 vector containing direction cosines for rows and cols
% ipp - image position patient: length 3 vector with [x y z] patient translation offset
% pix - length 3 vector of pixel dimensions [x y z] in mm
% ncols - number of columns in image
% 
% OUTPUTS
% Q - 4x4 matrix used to populate srow matrix in nifti header
% b - quaternion_b 
% c - quaternion_c
% d - quaternion_d
% qfac - 1 or -1, used to populate pixdim(1) in nifti header
% 
% USAGE
% [Q,b,c,d,qfac] = getaffine(iop,ipp,pix,ncols)

% Author - Krisanne Litinas
% $HeadURL: svn+ssh://klitinas@anger.engin.umich.edu/svn/matlab/img/trunk/getaffine.m $
% $Id: getaffine.m 1438 2014-06-23 14:38:44Z klitinas $

Q = eye(4);

% First 2 rows are orientation values
Q(1,1:3) = iop(1:3);
Q(2,1:3) = iop(4:6);

% Normalize rows 1 and 2
n1 = sqrt(Q(1,1)^2+Q(1,2)^2 +Q(1,3)^2);
n2 = sqrt(Q(2,1)^2+Q(2,2)^2 +Q(2,3)^2);
if n1 > 0
    Q(1,:) = Q(1,:)/n1;
else
    Q(1,1:3) = [1 0 0];
end
if n2 > 0
    Q(2,:) = Q(2,:)/n2;
else
    Q(2,1:3) = [0 1 0];
end

% Row 3 is cross product of rows 1,2
Q(3,1:3) = cross(Q(1,1:3),Q(2,1:3));

% Transpose
Q = Q';

% If det(Q) < 0, negate 3rd column
D = det(Q);
if D < 0
    Q(1:3,3) = -Q(1:3,3);
end

% Scale by pixel spacing
diagVox = [pix(1) 0 0; 0 pix(2) 0; 0 0 pix(3)];
Q(1:3,1:3) = Q(1:3,1:3) * diagVox;

% Offsets
Q(1:3,4) = ipp';

% Q now equals 'dicom_to_patient' in spm_dicom_convert


% flip x,y ?
patient_to_tal  = eye(4);
patient_to_tal(1,1) = -1;
patient_to_tal(2,2) = -1;

analyze_to_dicom = eye(4);
analyze_to_dicom(2,2) = -1;
analyze_to_dicom(1,4) = -1;
analyze_to_dicom(3,4) = -1;
analyze_to_dicom(2,4) = ncols; 

Q = patient_to_tal * Q;
Q = Q * analyze_to_dicom;

% //reportMatrix('mat',Q);
% //Q now equals 'mat' in spm_dicom_convert
% //subasgn.m in SPM5 translates by one voxel...
analyze_to_dicom = eye(4);
analyze_to_dicom (:,4) = 1;

Q = Q * analyze_to_dicom;

[~,b,c,d,qfac] = getquaternion(Q);


