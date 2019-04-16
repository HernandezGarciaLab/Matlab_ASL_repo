function asl_stream04( pname, DesMat, doDiff )

%function asl_stream04( pname, DesMat, doDiff )
%
% example:     asl_stream04('P00000.7',0)
%

despiker_ASL(pname, 3, 0);
sprec1(['f_' pname], 'l', 'fx', 'fy','N', 'com');

vfile = dir('vol*.nii');
vfile = vfile(1).name;
[p, n,e,v] = fileparts(vfile)


if doDiff
	vfile = 'sub';
	h = read_hdr('sub.hdr');
	Nframes = h.tdim;
	aslsub(n,1, 1,Nframes,0,1,0);
end

myCompCor_mod(vfile, DesMat);

return

