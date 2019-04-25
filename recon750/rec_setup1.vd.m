function [args,scaninfo,kinfo] = rec_setup1(rawfile,varargin)
%function [args,scaninfo,kinfo] = rec_setup1(rawfile,varargin)
%

% $Id: rec_setup1.m 1677 2015-02-26 16:49:01Z klitinas $
% $HeadURL: svn+ssh://klitinas@woo.engin.umich.edu/work/repos/matlab/recon/trunk/rec_setup1.m $

%
% some default paramters
%
outscale = 1;
FSIZE = 7;
stderr = 2; % fid for stderr

%
% parsing inputs
%

%
% error message
%
if exist('rawfile','var') == 0
  fprintf(stderr,'Usage: %s rawfile [OPTIONS]\n',mfilename);
  fprintf(stderr,'\nRecon Options\n');
  fprintf(stderr,'cp   Do conj phase recon\n');
  fprintf(stderr,'iter Do iterative (CG) recon\n');
  fprintf(stderr,'jnt  Do joint estimation recon\n');
  fprintf(stderr,'m    Generate field maps (for use with -h)\n');
  fprintf(stderr,'cm   Do conj phase correct on existing fieldmap\n');
  fprintf(stderr,'F #  Filter for smoothing fieldmap (default %d)\n',FSIZE);
  fprintf(stderr,'M #  Navigator correction for multishot (magnitude)\n');
  fprintf(stderr,'P #  Navigator correction for multishot (phase)\n');
  fprintf(stderr,'O #  Off-resonance demodulation (in Hz)\n');
  fprintf(stderr,'OF # Off-resonance shift of field map (in Hz)\n');
  fprintf(stderr,'n #  Recon image size (default set by pulse sequence)\n');
  fprintf(stderr,'d #  Sample delay term (for calibration)\n');
  fprintf(stderr,'QI   Do in spiral data in in-out spiral acquisition\n');
  fprintf(stderr,'QO   Do out spiral data in in-out spiral acquisition\n');
  fprintf(stderr,'\nOutput Options\n');
  fprintf(stderr,'V    Read header only (no recon)\n');
  fprintf(stderr,'v    Verbose\n');
  fprintf(stderr,'l    Shift images to actual Rx-ed location\n');
  fprintf(stderr,'A    Output Analyze format (default)\n');
  fprintf(stderr,'sl   Output individual images\n');
  fprintf(stderr,'mat  Output matlab .mat files\n');
  fprintf(stderr,'com  Output complex data matlab .mat files\n');
  fprintf(stderr,'S    Output matlab k-space data (for diags)\n');
  fprintf(stderr,'a    Output matlab file for all coils in multicoil recon\n');
  fprintf(stderr,'R1   Rotation image 90 deg.\n');
  fprintf(stderr,'R2   Rotation image 180 deg. (also -R)\n');
  fprintf(stderr,'R3   Rotation image 270 deg.\n');
  fprintf(stderr,'fx   Flip images in x-direction\n');
  fprintf(stderr,'fy   Flip images in y-direction\n');
  fprintf(stderr,'q    Reverse slice ordering\n');
  fprintf(stderr,'x #  Shift images in x-direction by # pixels\n');
  fprintf(stderr,'y #  Shift images in y-direction by # pixels\n');
  fprintf(stderr,'z #  Zoom factor (default 1.0)\n');
  fprintf(stderr,'L    Do L2 norm with existing images (for spiral in/out)\n');
  fprintf(stderr,'t #  Recon temporal frame # only\n');
  fprintf(stderr,'s #  Recon slice # only (incompatible with -A)\n');
  fprintf(stderr,'o #  Offset output image numbers (adds # to temp frame)\n');
  fprintf(stderr,'I    For interleaved slice ordering\n');
  fprintf(stderr,'C #  To adjust output scaling (default = %f)\n',outscale);
  fprintf(stderr,'0    (zero) to output 0th time point (field map)\n');
  return
end
%
% add test to see if raw file is arg structure - if so, use that
%
% set defaults
%
if exist('args','var') == 0
    args.pfile = rawfile;
    args.rtype = 'ft'; % 'cp','ft','iter','jnt'
    args.map = 0;  %  /* correction maps for hom. corr. */
    args.numrot = 0; % /* extra rotations */
    args.phs = 0; %     /* output phase images */
    args.out = 0; % verbose 
    args.norec = 0;% , no recon
    args.allcoils = 0; %/* output images for all coils */
    args.L2 = 0; %      /* output L2 combintation of images */
    args.imoffset = 0;
    args.setnim = 0; 
    args.nim = 64;
    args.iph = 0;
    args.isl = 0;
    args.samp1 = 0;
    args.fsize = FSIZE;
    args.lrshift = 0;
    args.tbshift = 0;
    args.zoomer = 1;
    args.outscale = outscale;
    args.pt = 0;
    args.fmoff = 0;
    args.phasefact = 0;
    args.svraw = 0; %   /* save mag raw data into images */
    args.loc = 0; %     /* true locations, shift images */
    args.rev = 0; %     /* reverse slice ordering */
    args.outfmt = 'anal'; %    /* ANALYZE output format */
    args.unf = 0; %     /* UNFOLD recon */
    args.unfact = 1; %     /* UNFOLD recon */
    args.zflg = 0; %    recon zero point
    args.rsa = 0; %     /* Out flag in in-out spiral */
    args.sliceorder = 1; %  /* 0=interleaved, 1=sequential */
    args.flipx = 0;   % flip x axis at output 
    args.flipy = 0;   % flip x axis at output 
    args.complex = 0;   
        
    args.cpmap = 0;
    args.kfilt = 0;
    args.oss = 0;
    args.rfnc = 10;
    % LHG for z grappa . 2.16.16
    args.dograppaz = 0;
    args.numACS = 0;
    % LHG 1.10.19 - fix for rotation of the spiral leaves
    args.RR = 0;
    
end
%
% read input args
%
  argn = 1;
  while (argn <= length(varargin));
    argtype = ( cell2mat(varargin(argn) ));
    argn = argn + 1;
    switch (argtype)
      case 'ft', args.rtype = 'ft';
      case 'cp', args.rtype = 'cp';
      case 'h', args.rtype = 'cp';
      case 'iter', args.rtype = 'it';
      case 'jnt', args.rtype = 'jn';
      case 'm',  args.map = 1;  %  /* correction maps for hom. corr. */
      case 'R1', args.numrot = 1; % /* extra rotations */
      case 'R2', args.numrot = 2; % /* extra rotations */
      case 'R',  args.numrot = 2; % /* extra rotations */
      case 'R3', args.numrot = 3; % /* extra rotations */
      case 'v', args.out = 1; % verbose 
      case 'V', args.out = 1; args.norec = 1;% verbose, no recon
      case 'a', args.allcoils = 1; %/* output images for all coils */
      case 'L', args.L2 = 1; %      /* output L2 combintation of images */
      case 'o', args.imoffset = getnum( cell2mat(varargin(argn) )); argn = argn+1;
			%		 /* offset in output image numbers */
      case 'n', args.setnim = 1; 
                args.nim = getnum(cell2mat(varargin(argn))); 
                argn = argn+1;  %  image size
      case 't', args.iph = getnum(cell2mat(varargin(argn))); argn = argn+1;
      case 's', args.isl = getnum(cell2mat(varargin(argn)));  argn = argn+1;
      case 'd', args.samp1 = getnum(cell2mat(varargin(argn))); argn = argn+1;
      case 'F', args.fsize = getnum(cell2mat(varargin(argn))); argn = argn+1;
      case 'x', args.lrshift = getnum(cell2mat(varargin(argn))); argn = argn+1;
      case 'y', args.tbshift = getnum(cell2mat(varargin(argn))); argn = argn+1;
      case 'z', args.zoomer = getnum(cell2mat(varargin(argn))); argn = argn+1;
      case 'C', args.outscale = getnum(cell2mat(varargin(argn))); argn = argn+1;
      case 'O', args.pt = getnum(cell2mat(varargin(argn))); argn = argn+1;
      case 'OF', args.fmoff = getnum(cell2mat(varargin(argn))); argn = argn+1;
      case 'P', args.phasefact = getnum(cell2mat(varargin(argn))); argn = argn+1;
      case 'S', args.svraw = 1; %   /* save mag raw data into images */
      case 'l', args.loc = 1; %     /* ture locations, shift images */
      case 'q', args.rev = 1; %     /* reverse slice ordering */
      case 'A', args.outfmt = 'anal'; %    /* ANALYZE output format */
      case 'N', args.outfmt = 'nifti'; %    /* ANALYZE output format */
      case 'sl', args.outfmt = 'sl'; %    
      case 'mat', args.outfmt = 'mat'; %    
      case 'com', args.complex = 1; args.outfmt = 'mat'; 
      case 'U', args.unf = 1; %     /* UNFOLD recon */
      case 'QI', args.rsa = 1; %     /* Out flag in in-out spiral */
      case 'QO', args.rsa = 2; %     /* Out flag in in-out spiral */
      case '0', args.zflg = 1; %    recon zero time point
      case 'I', args.sliceorder = 0; %  /* 0=interleaved, 1=sequential */
      case 'fx', args.flipx = 1;   % flip x axis at output 
      case 'fy', args.flipy = 1;   % flip x axis at output 
                % LHG 2.16.16
      case 'grappaz', args.dograppaz = 1;
          args.numACS = getnum(cell2mat(varargin(argn)));
          % number of calibration scans before the undersampling begins
          argn = argn+1;
      case 'RR', args.RR = 1;   % flip x axis at output 

      otherwise, 
        fprintf(stderr,'%s: Did not recognize option %s\n',mfilename,argtype);
    end % switch
  end % while

hdr = ge_pfilehdr(args.pfile);


scaninfo.npr=hdr.rdb.user4;          % number of interleaves
if args.unf == 1
  args.unfact = hdr.rdb.user4;
end
scaninfo.nphases=hdr.rdb.user1; % number of time points
scaninfo.nphmult=hdr.rdb.user1; % number of time points
if ((scaninfo.nphmult > 1) & (args.map == 1))
  scaninfo.nphases=2;
end
scaninfo.ndat=hdr.rdb.frame_size;                % get frame size
scaninfo.nslices=hdr.rdb.nslices;      % number of slices
scaninfo.dda=hdr.rdb.user16; % disdaqs
scaninfo.mapdda=hdr.rdb.user19;
scaninfo.opxres=hdr.rdb.user3; % spiral size
% scaninfo.gtype=hdr.rdb.user5;  % std or vd spirals?
scaninfo.mapdel=hdr.rdb.user15;   % in us
scaninfo.samptime=hdr.rdb.user13; % in us
scaninfo.slewrate=hdr.rdb.user7;  
scaninfo.fsgcm=hdr.rdb.user6;  
scaninfo.risetime=round(scaninfo.fsgcm*10000.0/scaninfo.slewrate);
scaninfo.ts=hdr.rdb.user13*1.0e-6;    % in s
scaninfo.gts=4.0e-6;                  % hard code, in s
scaninfo.opfov=hdr.rdb.user0;         % field of view in cm 

if hdr.rdb.user30 ~= 0
    scaninfo.slthick = hdr.rdb.user30;
else
    scaninfo.slthick = hdr.image.slthick;
end

scaninfo.slgap = hdr.rdb.user31;

if (args.setnim == 0)
  args.nim = hdr.rdb.im_size;
end

%scaninfo.densamp=hdr.rdb.user17;  % vd spiral only
%scaninfo.sensfact=hdr.rdb.user18;  % vd spiral only
scaninfo.vdflg=hdr.rdb.user23;  % vd spiral only
scaninfo.densamp=hdr.rdb.user22;  % vd spiral only
scaninfo.sensfact=hdr.rdb.user20*scaninfo.npr;  % vd spiral only
% to dermine for/rev spiral info
scaninfo.concat=hdr.rdb.user11;  % =1 for double readout 
scaninfo.revflg = hdr.rdb.user21;  % =0 for for, =1 for rev, =2 for both
if (scaninfo.revflg == 0)
%       args.rsa = 1; %  force forward spiral
    args.rsa = 2; %  force forward spiral
end
scaninfo.rotation=hdr.rdb.rotation; 
scaninfo.transpose=hdr.rdb.transpose;
kfact1 = -exp(i*pi*scaninfo.rotation/2);
kfact2 = exp(i*pi*args.numrot/2)/args.zoomer;
if (args.loc == 1)
  if (scaninfo.transpose == 0)
    pixshift = hdr.rdb.yoff/hdr.rdb.im_size - i*hdr.rdb.xoff/hdr.rdb.im_size;
  else
    pixshift = -hdr.rdb.xoff/hdr.rdb.im_size + i*hdr.rdb.yoff/hdr.rdb.im_size;
  end
  pixshift = conj(kfact1)*pixshift;
else
  pixshift = 0;
end
scaninfo.pixshifth = real(pixshift);
scaninfo.pixshiftv = imag(pixshift);
scaninfo.ncoils=hdr.rdb.dab(2)-hdr.rdb.dab(1)+1;
scaninfo.mcskip=hdr.rdb.raw_pass_size/scaninfo.ncoils;

% informational or output only
scaninfo.scan_date=hdr.rdb.scan_date;
scaninfo.scan_time=hdr.rdb.scan_time;
scaninfo.exam=hdr.image.im_exno;
scaninfo.series=hdr.image.im_seno;
scaninfo.tr=hdr.image.tr / 1e3;
scaninfo.te=hdr.image.te / 1e3;
scaninfo.fa=hdr.image.mr_flip;
scaninfo.psdname=hdr.image.psdname;
scaninfo.r1=hdr.rdb.ps_aps_r1;
scaninfo.r2=hdr.rdb.ps_aps_r2;
scaninfo.tg=hdr.rdb.ps_aps_tg;
scaninfo.freq=hdr.rdb.ps_aps_freq;
scaninfo.headersize=hdr.rdb.off_data;
scaninfo.rawsize=scaninfo.headersize+hdr.rdb.raw_pass_size;


scaninfo.ngap=hdr.rdb.user10;  % not used - maybe want for spiral in/out
scaninfo.fast_rec_off=hdr.rdb.user12;  % not used in E2
scaninfo.fast_rec_lpf=0;               % not used in E2
scaninfo.sliceorder=args.sliceorder;   %  /* 0=interleaved, 1=sequential */ 

% -------------- MR750 STUFF HERE BEGIN ----------------------------
% to dermine for/rev spiral info
scaninfo.revflg = hdr.rdb.user5;  % =0 for for, =1 for rev, =2 for both
if (scaninfo.revflg == 0)
%       args.rsa = 1; %  force forward spiral
      args.rsa = 2; %  force forward spiral
end
if (scaninfo.revflg == 2)
      scaninfo.concat=1;  % =1 for double readout 
else
      scaninfo.concat=0;  % =1 for double readout 
end
scaninfo.gtype = 0;
nodd = rem((scaninfo.nphmult*scaninfo.npr*(scaninfo.concat+1)),2);
nodd = 0;
scaninfo.mcskip = scaninfo.nslices*((scaninfo.concat+1)*scaninfo.nphmult*scaninfo.npr+1+nodd)*4*scaninfo.ndat;
% ---------------MR750 STUFF HERE END -----------------------------

%
% generate k-space trajectories
%
if (scaninfo.vdflg == 0)
  % standard spiral
  [g,k,t,s]=spiralgradlx3(scaninfo.opfov,scaninfo.opxres,scaninfo.gts,scaninfo.slewrate,scaninfo.fsgcm,scaninfo.npr);
  vd = ones(size(k));
else 
  % var dens spiral
%  [g,k,t,s,vd]=genspivd2(scaninfo.opfov,scaninfo.opxres,scaninfo.sensfact,scaninfo.fsgcm,scaninfo.slewrate,scaninfo.densamp);
  [g,k,t,s,vd]=dogradvd(scaninfo.opfov,scaninfo.opxres,scaninfo.gts,scaninfo.slewrate,scaninfo.fsgcm,scaninfo.sensfact,scaninfo.densamp);
end
% -------------- MR750 STUFF HERE BEGIN ----------------------------
% mr750 fix - need to interpolate k-space traj
nd2 = round(length(k)*scaninfo.gts/scaninfo.ts)
scaninfo.ndat
lk = length(k)
size(k);
newk = interp1([1:lk],k,[1:nd2]*lk/nd2,'linear');
newvd = interp1([1:lk],vd,[1:nd2]*lk/nd2,'linear');
lt = length(t);
newt = interp1([1:lt],t,[1:nd2]*lt/nd2,'linear');
if (nd2 < scaninfo.ndat)
  k = [newk zeros([1 (nd2-scaninfo.ndat)])];
  vd = [newvd zeros([1 (nd2-scaninfo.ndat)])];
  t = [newt zeros([1 (nd2-scaninfo.ndat)])];
else
  k = newk(1:scaninfo.ndat);
  vd = newvd(1:scaninfo.ndat);
  t = newt(1:scaninfo.ndat);
end
vd(1) = 0;
k(1) = 0;
t(1) = 0;
size(k);


% -------------- MR750 STUFF HERE END ----------------------------
if (scaninfo.transpose == 0)
  k = imag(k) + i*real(k);
else
  k = -k;
end
k = k.*kfact1;
% for advancing samples
if (args.samp1 < 0)
  k = [ones([1 -args.samp1])*k(1) k];
  vd = [ones([1 -args.samp1])*vd(1) vd];
end
if args.samp1 > 0
    k = k(args.samp1+1:end);
    vd = vd(args.samp1+1:end);
end
lk = length(k);
if lk < scaninfo.ndat
  k = [k k(lk)*ones([1 (scaninfo.ndat-lk)])];
  vd = [vd vd(lk)*ones([1 (scaninfo.ndat-lk)])];
else
  k = k(1:scaninfo.ndat);
  vd = vd(1:scaninfo.ndat);
end
lk = length(k);
% density comp factor
g = [0 diff(k)];
kdens = -abs(g).*sin(angle(g)-angle(k)).*vd;

% data modulation for shifting and bulk off-resonance
t = [0:lk-1]*scaninfo.ts;
xsh = args.lrshift/args.nim + scaninfo.pixshifth; 
ysh = args.tbshift/args.nim - scaninfo.pixshiftv; 
kmod = exp(i*2*pi*(args.pt*t +  xsh*real(k) + ysh*imag(k)));
k = k*kfact2;

kinfo.k = k;
kinfo.kdens = kdens;
kinfo.kmod = kmod;
kinfo.t = t;
kinfo.vd = vd;
kinfo.s = s;
kinfo.g = g;


return;

function out = getnum(inar)
if (ischar(inar))
  out = str2num(inar);
else
  out = inar;
end
return;
