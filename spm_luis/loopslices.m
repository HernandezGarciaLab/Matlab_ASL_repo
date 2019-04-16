%
%
% a little routine for looping over the slices of an spm activation map
% and displaying them on the screen and saving as tiff.
%
%

% have the user point to an image file and then loop over the dimensions

global myAnatomicFile;

global LZSLICE;

myAnatomicFile = spm_get(1,'.img','select an image for rendering');

%[d d d d d origin] = spm_hread(myAnatomicFile);

tiffOutput = input('TIFF output (1/0) :');

for iz = 1:V(3)
     LZSLICE = (iz-1)*V(6)+(1-V(9))*V(6)
     spm_single_slice;
     if (tiffOutput == 1) 
        if (iz < 10) 
           fileName = ['slice_0' int2str(iz)];
        else
	   fileName = ['slice_' int2str(iz)];
	end;
	tiffwrite(Tc,split,fileName);
     end;
end;
