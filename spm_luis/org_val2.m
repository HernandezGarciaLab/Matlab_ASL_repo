% Script 'org_val2' used to calc offset to AntCom (origin) in # Pixels
% TLChenevert 6/98.

% User may want to edit in AntCom (origin) location for current exam.
% Then "File-Save" this script.
% Answer "n" to "Manual Input Origin Location Now ?" query.
% This will save some repetitive input for this particular exam.


% **********************************************************
% **********************************************************
% *** ANTERIOR COMMISURE (ORIGIN) LOCATION FOR THIS EXAM ***
orgx = 0; % <--- Origin Location along R/L (+R/-L in mm)
orgy = -5.3; % <--- Origin Location along A/P (+A/-P in mm)
orgz = 31.2; % <--- Origin Location along S/I (+S/-I in mm)
% **********************************************************
% **********************************************************
% **********************************************************

fovx = input('Full FOV in R/L (in mm) ? ');
pixx = input('Total number of pixels/slices in R/L direction ? ');
disp('  ');
fovy = input('Full FOV in A/P (in mm) ? ');
pixy = input('Total number of pixels/slices in A/P direction ? ');
disp('  ');
fovz = input('Full FOV in S/I (in mm) (if slice dir, (Nsl-1)*(True SlcThk) ? ');
pixz = input('Total number of pixels/slices in S/I direction ? ');
disp('  ');

cx = input('R/L Location of Volume Center (+R/-L in mm) ? ');
cy = input('A/P Location of Volume Center (+A/-P in mm) ? ');
cz = input('S/I Location of Volume Center (+S/-I in mm) ? ');

yesno = input('Do you need to manually input origin values (0=No, 1=Yes) ? ');
if (yesno == 1)
  orgx = input('Origin Location along R/L (+R/-L in mm) ? ');
  orgy = input('Origin Location along A/P (+A/-P in mm) ? ');
  orgz = input('Origin Location along S/I (+S/-I in mm) ? ');
end % if


opixx = round( (orgx - cx + (fovx/2))*pixx/fovx );
opixy = round( (orgy - cy + (fovy/2))*pixy/fovy );
opixz = round( (orgz - cz + (fovz/2))*pixz/fovz );

disp('  ');
disp('  ');
disp('Origin Location (X,Y,Z) in millimeters is ... ');
orgnmm = [orgx orgy orgz]
disp('Origin Location (X,Y,Z) in Pixels is ... ');
orgn = [opixx opixy opixz]
 
