function series_est(rootname,parms,f0)

%set up the estimation conditions and boundaries
LB = f0*0.5;
UB = f0*2.5;
optvar=optimset('lsqnonlin');
optvar.TolFun = 1e-15;
optvar.TolX = 1e-10;
optvar.MaxIter = 7;
optvar.Diagnostics = 'on';
optvar.Display = 'iter';
optvar.DiffMinChange = 1.0e-6;


% determine the file names and sizes
names=dir(sprintf(rootname,'*.img'));
hnames=dir(sprintf(rootname,'*.hdr'));

h = read_hdr(hnames(1).name));
NPIX = h.xdim*h.ydim*h.zdim;

% discard pixels that have zeros in them
mask=read_img_data(h, names(1).name);
f = zeros(size(mask));

for pix=1:NPIX
	if (abs(mask(pix) >= 0.001)
		signal=timeplot5('.',rootname, pix);
		([est2 , resnorm, res, ex, output]  = lsqnonlin(@kinetix_lsq,...
			est0, LB, UB, ...
			optvar,...
			t,parms, ...
			signal);
		

