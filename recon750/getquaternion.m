function [a,b,c,d,qfac] = getquaternion(R)
% getquaternion.m - given rotation matrix, computes quaternion parameters
% for nifti header.  Adapted from nifti_hdr.pas of mricron's dcm2nii source code
% (nifti_mat44_to_quatern procedure)
% 
% INPUTS
% R - 4x4 rotation matrix derived from image position/orientation info in
%     pfile (computed in getaffine.m)
% 
% OUTPUTS
% a,b,c,d - quaternion a/b/c/d parameters (only b,c,d actually stored in nii)
% qfac - either -1 or 1, stored as pixdim(1) in nii header)
% 
% EXAMPLE
% R = rand(4,4);
% [a,b,c,d,qfac] = getquaternion(R);

% Author - Krisanne Litinas
% $HeadURL: svn+ssh://klitinas@anger.engin.umich.edu/svn/matlab/img/trunk/getquaternion.m $
% $Id: getquaternion.m 1438 2014-06-23 14:38:44Z klitinas $

qx = R(1,4);
qy = R(2,4);
qz = R(3,4);

[r11,r12,r13,r21,r22,r23,r31,r32,r33] = locdealmatrix(R);
xd = sqrt( r11*r11 + r21*r21 + r31*r31 ) ;
yd = sqrt( r12*r12 + r22*r22 + r32*r32 ) ;
zd = sqrt( r13*r13 + r23*r23 + r33*r33 ) ;

if xd == 0
    r11 = 1;
    r21 = 0;
    r31 = 0;
    xd = 1; 
end
if yd == 0
    r22 = 1;
    r12 = 0;
    r32 = 0;
    yd = 1; 
end
if zd == 0
    r33 = 1;
    r13 = 0;
    r23 = 0;
    zd = 1; 
end

% (* assign the output lengths *)
   dx = xd;
   dy = yd;
   dz = zd;

%    (* normalize the columns *)

   r11 = r11/xd ; r21 = r21/xd ; r31 = r31/xd ;
   r12 = r12/yd ; r22 = r22/yd ; r32 = r32/yd ;
   r13 = r13/zd ; r23 = r23/zd ; r33 = r33/zd ;
   
   Q = [r11 r12 r13; r21 r22 r23; r31 r32 r33];
   %Q = [r11 r12 r13 r21 r22 r23 r31 r32 r33];

   % nifti_mat33_polar
   P = nifti_mat33_polar(Q);
   [r11,r12,r13,r21,r22,r23,r31,r32,r33] = locdealmatrix(P);

% (* compute the determinant to determine if it is proper *)
%%zd = r11*r22*r33-r11*r32*r23-r21*r12*r33+r21*r32*r13+r31*r12*r23-r31*r22*r13;
zd = det(Q);

if zd > 0 % proper
    qfac = 1;
else  % improper
    qfac = -1;
    r13 = -r13; r23 = -r23; r33 = -r33;
end

% Quaternions
a = r11 + r22 + r33 + 1;

if a > 0.5    %           (* simplest case *)
    a = 0.5 * sqrt(a) ;
    b = 0.25 * (r32-r23) / a ;
    c = 0.25 * (r13-r31) / a ;
    d = 0.25 * (r21-r12) / a ;
else                  %     (* trickier case *)
    xd = 1.0 + r11 - (r22+r33) ; % (* 4*b*b *)
    yd = 1.0 + r22 - (r11+r33) ; % (* 4*c*c *)
    zd = 1.0 + r33 - (r11+r22) ; % (* 4*d*d *)
    if xd > 1.0 
        b = 0.5 * sqrt(xd) ;
        c = 0.25* (r12+r21) / b ;
        d = 0.25* (r13+r31) / b ;
        a = 0.25* (r32-r23) / b ;
    elseif yd > 1.0 
        c = 0.5 * sqrt(yd) ;
        b = 0.25* (r12+r21) / c ;
        d = 0.25* (r23+r32) / c ;
        a = 0.25* (r13-r31) / c ;
    else
        d = 0.5 * sqrt(zd) ;
        b = 0.25* (r13+r31) / d ;
        c = 0.25* (r23+r32) / d ;
        a = 0.25* (r21-r12) / d ;
    end
    if a < 0.0 
        b=-b ; c=-c ; d=-d; a=-a; 
    end
end;

qa = a;
qb = b ;
qc = c ;
qd = d ;
% --------------------------------------------------------------
function [r11,r12,r13,r21,r22,r23,r31,r32,r33] = locdealmatrix(R)
r11 = R(1,1);
r12 = R(1,2);
r13 = R(1,3);
r21 = R(2,1);
r22 = R(2,2);
r23 = R(2,3);
r31 = R(3,1);
r32 = R(3,2);
r33 = R(3,3);
