function ms = testlabel(Pfile, doGetraw)
if nargin>1
	if doGetraw
		str=['!~hernan/scripts/getraw ' Pfile];
		eval(str)
	end
end

!rm *.nii
%sprec1(Pfile,'m', 'l','fy');
sprec1(Pfile,'N','l','fy','C',0.2);

vols = dir('vol*.nii');
volname = vols(1).name;

hdr = read_hdr(volname);

aslsub(volname(1:end-4), 1, 1, hdr.tdim, 0, 0, 0);

ms = lightbox('mean_sub',[-100 100],3); 
print -djpeg testlabel
%figure, hist(ms(:), 100); 
