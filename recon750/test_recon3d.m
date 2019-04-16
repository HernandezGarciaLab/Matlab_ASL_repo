function  test_recon3d_mult(Pfile)

!rm *.nii
%sprec1_3d(Pfile,'m');
% sprec1_3d(Pfile,'h','N');

sprec1_3d(Pfile,'N');

% sprec1_3d(Pfile,'QO','d',-5, 'mat','S');

vols = dir('vol*.nii');
volname = vols(1).name;

hdr = read_hdr(volname);

global args; clear args
ortho2005([],'tseries_file', volname,...
	'wscale',[], ...
	'roitype','sphere',...
	'roisize',1,...
	'doMovie',1,...
	'interact',1 ...
	);


return
