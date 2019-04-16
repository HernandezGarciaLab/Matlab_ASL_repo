function y = ginx2spm1(dim1,dim2,slc1,slc2);
% This is a matlab5 script.
% Used to import "ginx2tar1" files (after untar & gunzip).
% Use to input 2D ginx or xferx images (skip hdr) & output multiphase 3D volumes.
% dim1 = image size along first dimension
% dim2 = image size along second dimension
% slc1 = 1st image to read in
% slc2 = last image to read in
% ph1 = convert images starting with this phase (defunct)
% ph2 = and ending with this phase (defunct)
% Note each datum = 2(short) or 4(float)bytes.
% Spun off of ge2spm1.m with changes to allow transpose, flip vert and horiz.
% TLChenevert 3/98.

% Note, one ought to first 'cd' into directory of image files.
global fname; % This is so I can label images with appropriate filenames.
disp(' ');
disp('Select any of the images to define filename ... ');
fname = uigetfile('*i*','Files');
if(fname == 0) break;
end

[n m] = size(fname);
% Find index of character "i" put in by ginx2tar1, starting from end of filename.
for mm = m:-1:1
	if (fname(mm) == 'i')
		m0 = mm;
	end
end
basnm = fname(1:m0); % So now use fname up to, but exlc, "i"
datatyp = 'short';
%basnm = input('Input files basename (eg. "s1_dec4_97_e1266s2", include single quotes) ?  ');
%outbase= input('Output files basename (eg. "s1_dec4_97_e1266s2", include single quotes) ?  ');
outbase=basnm(1:(m0-1)); % Keep output fname a derivative of input.
asc = input('Acquisition Plane: 1=axial, 2=sag, 3=cor ? ');
%slorder =  input('Slice Order: 1=normal, -1=reverse  ? ');
%seeimgs =  input('See 1st phase images: 1=yes, 0=no  ? ')


% Lets leave in phase loop, but normally will output 1 phase
ph1 = 1;
ph2 = 1;
nslc = slc2 - slc1 + 1;
y = zeros(dim1,dim2,nslc);
for phi = ph1:ph2
	%phi;
   slc0 = slc1 - 1;
   %slc0 = nslc*(phi - 1);
   for slci = 1:nslc
    if (ph1==ph2) % Print out slci FYI for structural datasets (ie ph1=ph2) 
      %slci
     end
      imgi = slc0 + slci; % This index relates to import filename on disk.
      fname = strcat(basnm,int2str(imgi));
      fid = fopen(fname,'r','b'); % PC seems to want 'b'
      ferror(fid);
      if (fid == -1) disp('Error reading file!!! Did you cd to its directory ?');
         break;
      end
      status = fseek(fid,-2*dim1*dim2,1); % Neg byte offset from eof
      x = fread(fid,[dim1,dim2],datatyp);
      fclose(fid);
      %x = rot90(x);
      %img(x,1)as;
      %title(fname);
      %axis image; % This sets image to square pixel aspec ratio
      %pause;
      y(:,:,slci) = x;
   end % slci; loop over slices in this phase
   %size(y)
   phlable = int2str(phi);
	[d1 d2] = size(phlable);
	switch d2
		case 1 
         		outfn = [outbase '_00' phlable '.img'];
		case 2
        		outfn = [outbase '_0' phlable '.img'];
      		case 3
         		outfn = [outbase '_' phlable '.img'];
      		otherwise
         		disp(' Too many phases (>999) ... ');
	end % switch d2

% Display some images if desired 
 if(phi == ph1)
   disp(' ');
   disp('Want Images in SPM, eg. Axials: Pt_Left=Your_Top and Pt_Post=Your_Left ') 
   slci = ceil(nslc/2);
   figure(3);
   while ( (slci <= nslc) & (slci >= 1) )
	img(rot90(y(:,:,slci),2),1); % Show initial phase images only
	axis image;
	slci =  input('Display which slice ? (enter 0 to move on ) ');
   end % slci

   slorder =  input('Slice Order: 1=normal (#1=Inf-Lt-Post), -1=reverse  ? ');
   swap =  input('Swap Vert and Horiz on Images?	(0=No, 1=Yes) ');	
   flpvert =  input('Flip Top for Bottom ?	(0=No, 1=Yes) ');
   flphoriz =  input('Flip Right for Left ?	(0=No, 1=Yes) ');
   disp(' ');

   disp('Current maximum image intesity is = ');
   max(max(max(y)))
   scaleup = input('Order of magn multipler to keep max below 30k ? ');   
 end % if phi

if (slorder == -1) % May need to reverse slices
    yy = flipdim(y,3);
    y = yy;
	%z = 0.*y;
	%for nnn = 1:nslc
	%	z(:,:,nnn) = y(:,:,(nslc-nnn+1));
	%end
	%y = z;
 end % slorder if
 for nnn = 1:nslc
   if(flpvert == 1)
	yy = flipud(y(:,:,nnn));
   else
	yy = y(:,:,nnn);
   end % if flpvert
 
   if(flphoriz == 1)
	yyy = fliplr(yy);
   else
	yyy = yy;
   end % if flphoriz

   if(swap == 1)
	yyyy = yyy';
   else
	yyyy = yyy;
   end % if swap

   %y(:,:,nnn) = yyyy;
   yyyyy(:,:,nnn) = scaleup*yyyy;
 end % nnn loop
   %y = yyyyy;


 switch asc % Reorient image volume, if required
	case 1  % Fix axials
		for nnn = 1:nslc
			%yy = rot90(y(:,:,nnn),2);
			%y(:,:,nnn) = yy;
			zz = rot90(yyyyy(:,:,nnn),2);
			yout(:,:,nnn) = zz;
		end % for nnn
		%yyy = y;
	case 2  % Fix sagittals
		disp(' Sagittals and Coronals are untested ');
		%yy = permute(y,[3 2 1]);
		zz = permute(yyyyy,[3 2 1]);
		for nnn = 1:nslc
			%z = squeeze(yy(nnn,:,:));
			zzz = squeeze(zz(nnn,:,:));
			%yyy = rot90(z,1);
			zzzz = rot90(zzz,1);
			%yyyy = fliplr(yyy);
			zzzzz = fliplr(zzzz);
			%yy(nnn,:,:) = yyyy;
			yout(nnn,:,:) = zzzzz;
		end % for nnn		
		%yyy = yy;
	case 3  % Fix coronals
		disp(' Sagittals and Coronals are untested ');
		%yy = permute(y,[1 3 2]);
		zz = permute(yyyyy,[1 3 2]);
		for nnn = 1:nslc
			%z = squeeze(yy(:,nnn,:));
			zzz = squeeze(zz(:,nnn,:));
			%yyy = fliplr(z);
			zzzz = fliplr(zzz);
			%yyyy = flipud(yyy);
			zzzzz = flipud(zzzz);
			%yy(:,nnn,:) = yyyy;
			yout(:,nnn,:) = zzzzz;
		end % for nnn		
		%yyy = yy;
	otherwise
		disp(' Meaningless Acq Order, need 1,2 or 3 !!! ');
 end % asc switch

 if(phi == ph1)
   disp(' ');
   disp('Ax Imgs Should Be SPM-like, eg Ax: Pt_Left=Your_Top and Pt_Post=Your_Left ')
   disp('IF IMAGES ARE STILL NOT CORRECT, CNTRL-C TO BUG-OUT then start over!!! ');
   disp(' ');
   slci = ceil(nslc/2);
   figure(1);
   while ( (slci <= nslc) & (slci >= 1) )
	img(yout(:,:,slci),1); % Show initial phase images only
	axis image;
	slci =  input('Display which slice ? (enter 0 to move on ) ');
   end % slci 
 end % if phi


   fido = fopen(outfn,'w');
   count = fwrite(fido,yout,datatyp);
   status = fclose(fido);
			
end % phi
