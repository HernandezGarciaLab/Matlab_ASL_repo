function [y] = see_spm(dim1,dim2,dim3);
% This is a matlab5 script will load-in and display spm-ready (almost) 3D files
% A spm (i.e. analyze) header is not needed
% TLC Aug 98

% Note, one ought to first 'cd' into directory of image files.

seemore = 'y';

while (seemore == 'y')

global fname; % This is so I can label images with appropriate filename.


% Identify file to display
disp('Select the 3D file to display please ... ');
fn = uigetfile('*.img','Files');
if(fn == 0)
    break;
end

yout = zeros(dim1,dim2,dim3);
datatyp = 'short';

fid = fopen(fn,'r'); % If PC, add 'b'
ferror(fid);
if (fid == -1) input('File not found or error reading it');
  break;
end

for slci = 1:dim3
	yout(:,:,slci) = fread(fid,[dim1,dim2],datatyp);
end % slci loop

slci = 1;
   while ( (slci <= dim3) & (slci >= 1) )
	img(yout(:,:,slci),1);
	axis image;
	slci =  input('Display which slice ? (enter 0 to quit ) ');
   end % while slci 

status = fclose(fid);

seemore =  input('See another file ? (dont forget single quotes) ');

end % while seemore

y = yout;

return;
