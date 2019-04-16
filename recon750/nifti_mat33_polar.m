function P = nifti_mat33_polar(A)
% nifti_mat33_polar.m - adapted from nifti_hdr.pas of dcm2nii source code
% (nifti_mat33_polar procedure), used towards populating orientation info
% in nifti headers
% 
% INPUTS
% A - 3x3 matrix
% 
% OUTPUTS
% P - 3x3 matrix
% 
% EXAMPLE
% A = rand(3,3);
% P = nifti_mat33_polar(A)

% Author - Krisanne Litinas
% $HeadURL: svn+ssh://klitinas@anger.engin.umich.edu/svn/matlab/img/trunk/nifti_mat33_polar.m $
% $Id: nifti_mat33_polar.m 1438 2014-06-23 14:38:44Z klitinas $

dif = 1;
k = 0;
X = A;

gam = loc_nifti_mat33_determ(X);

% perturb matrix
while gam == 0
    gam = 0.00001 * ( 0.001 + loc_nifti_mat33_rownorm(X) ) ;
    X(1,1) = X(1,1)+gam ;
    X(2,2) = X(2,2)+gam ;
    X(3,3) = X(3,3) +gam ;
    gam = loc_nifti_mat33_determ(X);
end

t = 1;
while t 
   Y = loc_nifti_mat33_inverse(X); 
   if dif > 0.3 %     // far from convergence
       alp = sqrt( loc_nifti_mat33_rownorm(X) * loc_nifti_mat33_colnorm(X) ) ;
       bet = sqrt( loc_nifti_mat33_rownorm(Y) * loc_nifti_mat33_colnorm(Y) ) ;
       gam = sqrt( bet / alp ) ;
       gmi = 1.0 / gam ;
   else
       gam = 1.0;
       gmi = 1.0 ;  % //close to convergence
   end;

   Z(1,1) = 0.5 * ( gam*X(1,1) + gmi*Y(1,1) ) ;
   Z(1,2) = 0.5 * ( gam*X(1,2) + gmi*Y(2,1) ) ;
   Z(1,3) = 0.5 * ( gam*X(1,3) + gmi*Y(3,1) ) ;
   Z(2,1) = 0.5 * ( gam*X(2,1) + gmi*Y(1,2) ) ;
   Z(2,2) = 0.5 * ( gam*X(2,2) + gmi*Y(2,2) ) ;
   Z(2,3) = 0.5 * ( gam*X(2,3) + gmi*Y(3,2) ) ;
   Z(3,1) = 0.5 * ( gam*X(3,1) + gmi*Y(1,3) ) ;
   Z(3,2) = 0.5 * ( gam*X(3,2) + gmi*Y(2,3) ) ;
   Z(3,3) = 0.5 * ( gam*X(3,3) + gmi*Y(3,3) ) ;

   dif = abs(Z(1,1)-X(1,1))+abs(Z(1,2)-X(1,2)) ...
          +abs(Z(1,3)-X(1,3))+abs(Z(2,1)-X(2,1)) ...
          +abs(Z(2,2)-X(2,2))+abs(Z(2,3)-X(2,3)) ...
          +abs(Z(3,1)-X(3,1))+abs(Z(3,2)-X(3,2)) ...
          +abs(Z(3,3)-X(3,3)) ;
      
      k = k+1;
      
    if k > 100 || dif < 3e-6
         P = Z;
         % changed break to return?
         t = 0;
         %break ; % //convergence or exhaustion
     end;
     X = Z ;
end
P = Z;
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

% -----------------------------------------
function result = loc_nifti_mat33_determ(R)
result = R(1,1)*R(2,2)*R(3,3)...
    -R(1,1)*R(3,2)*R(2,3)...
    -R(2,1)*R(1,2)*R(3,3)...
    +R(2,1)*R(3,2)*R(1,3)...
    +R(3,1)*R(1,2)*R(2,3)...
    -R(3,1)*R(2,2)*R(1,3) ;

% -----------------------------------------
function result = loc_nifti_mat33_rownorm(A)
r1 = abs(A(1,1))+abs(A(1,2))+abs(A(1,3));
r2 = abs(A(2,1))+abs(A(2,2))+abs(A(2,3));
r3 = abs(A(3,1))+abs(A(3,2))+abs(A(3,3));
if r1 < r2
    r1 = r2 ;
end
if r1 < r3
    r1 = r3 ;
end
result = r1 ;

% -----------------------------------------
function result = loc_nifti_mat33_colnorm(A)
r1 = abs(A(1,1))+abs(A(2,1))+abs(A(3,1));
r2 = abs(A(1,2))+abs(A(2,2))+abs(A(3,2));
r3 = abs(A(1,3))+abs(A(2,3))+abs(A(3,3));
if r1 < r2
    r1 = r2 ;
end
if r1 < r3
    r1 = r3 ;
end
result = r1 ;

% ------------------------------------
function Q = loc_nifti_mat33_inverse(R)
[r11,r12,r13,r21,r22,r23,r31,r32,r33] = locdealmatrix(R);
deti = r11*r22*r33-r11*r32*r23-r21*r12*r33+r21*r32*r13+r31*r12*r23-r31*r22*r13 ;

if deti ~= 0
    deti = 1.0 / deti ;
end
Q = zeros(3,3);
Q(1,1) = deti*( r22*r33-r32*r23) ;
Q(1,2) = deti*(-r12*r33+r32*r13) ;
Q(1,3) = deti*( r12*r23-r22*r13) ;

Q(2,1) = deti*(-r21*r33+r31*r23) ;
Q(2,2) = deti*( r11*r33-r31*r13) ;
Q(2,3) = deti*(-r11*r23+r21*r13) ;

Q(3,1) = deti*( r21*r32-r31*r22) ;
Q(3,2) = deti*(-r11*r32+r31*r12) ;
Q(3,3) = deti*( r11*r22-r21*r12) ;
