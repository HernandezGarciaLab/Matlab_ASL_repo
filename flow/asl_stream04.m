function asl_stream04( pname, DesMat, doDiff )

%function asl_stream04( pname, DesMat, doDiff )
%
% example:     asl_stream04('P00000.7', 'DesignMatrix.txt', 1)
%
doComplex=0;

despiker_ASL(pname, 3, 0);

if doComplex
	sprec1(['f_' pname], 'l', 'fx', 'fy','N', 'com');
else
	sprec1(['f_' pname], 'l', 'fx', 'fy','N');
end

vfile = dir('vol*.nii');
vfile = vfile(1).name;
[p, n,e,v] = fileparts(vfile)

h = read_hdr(vfile);
Nframes = h.tdim;


if doDiff
	aslsub_sur(n,1,Nframes,0, 0);
	vfile = 'sub.img';
end

myCompCor_mod(vfile, DesMat);

return

