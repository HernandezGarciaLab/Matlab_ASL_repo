function outputFileName = sprec1(pfile,varargin)
% Copyright 2005
% Douglas C. Noll and others
% University of Michigan
%
% call sprec1 with no arguments to find options
%
% to allow immeidate access to matlab recon variables
% edit this file to comment out the top line and change
% scriptmode = 1;
%

% Added output filename as return variable - RCWelsh 2012-08-22
outputFileName = '';

scriptmode = 0;
if scriptmode == 1
    % in script mode, this is how recon is setup
    [args,scaninfo,kinfo] = rec_setup1('P04096.7','ft','sl','l','v');
else
    if exist('pfile','var') == 0
        rec_setup1;
        return
    else
        [args,scaninfo,kinfo] = rec_setup1(pfile,varargin{:});
    end
end % if scriptmode == 1

if args.out == 1
    args
    scaninfo
end
if args.norec == 1
    return
end

fid = fopen(args.pfile,'r','l');

nim = args.nim;
iph = args.iph;
isl = args.isl;
zflg = args.zflg;
mapdda = scaninfo.mapdda;
unfact = args.unfact;
nphases = scaninfo.nphases;
nslices = scaninfo.nslices;
ncoils = scaninfo.ncoils;
npr = scaninfo.npr;
concat = scaninfo.concat;
datestr = scaninfo.scan_date(1:9);
datestr(3) = '_';
datestr(6) = '_';

if strcmp(args.outfmt,'nifti')
    pixperframe=nim*nim*nslices;
    nii_start = 1;
    nii_stop = pixperframe;
    nii_data = zeros(pixperframe * (nphases-1),1);
end

if (args.rtype == 'cp') | (args.rtype == 'ft')
    % for gridding recon
    % set up kaiser-bessel functions
    scfactor = 0.04;  % arbitrary output scaning factor (depends on kb kernel, etc.)
    OVER = 2; % oversampling factor
    NW = 1024; % number of samples of k-b kernel
    kb_gridl = 1.5; % gridding width (in orig coords)
    kb_beta = 6.7; % Jackson's betas 1.5 = 6.7, 2.0 = 9.1, 2.5 = 11.5
    kbin = [-NW/2:NW/2]/NW;
    kbweights = besseli(0,kb_beta*sqrt(1.0-(2.0*kbin).^2));
    kx = []; ky = []; tt = [];
    for prnum = 1:npr
        kx = [kx real(kinfo.k.*exp(-i*2*pi*(prnum-1)/npr))*OVER];
        ky = [ky imag(kinfo.k.*exp(-i*2*pi*(prnum-1)/npr))*OVER];
        tt = [tt kinfo.t];
    end % for prnum = 1:npr

    %r /* kaiser-bessel correction */
    wcmax = sinh(sqrt(kb_beta^2))/sqrt(kb_beta^2);
    wctmp = (2*pi*kb_gridl*[-nim/2:nim/2-1]/nim/OVER).^2 - kb_beta^2 + eps;
    wc1d = real(sqrt(wctmp)./sin(sqrt(wctmp))*wcmax);
    wc = wc1d'*wc1d;
    [xx yy] = meshgrid([-nim/2:nim/2-1]);
    wc = wc.*(abs(xx + i.*yy) < 0.55*nim)*scfactor*args.outscale;
    subim = [-nim/2:nim/2-1] + nim*OVER/2 + 2;

    % set up apodization
    apod = fermi(nim*OVER,max(abs(kinfo.k))*OVER,-1);
    if (args.rtype == 'cp')
        % set up standard temporal interpolators
        tmax = max(kinfo.t);
        % for now, make the max segment length 4 ms long - make this user selectable
        L = ceil(tmax/0.004);
        tau = tmax/L;
        t2 = [0:L]*tau;
        % for now, make the temporal interpolators min-max interpolators assuming
        % a generic triangular histogram with a FWHM of 100 Hz
        df = 100;
        [ll llt] = meshgrid([0:L]);
        ggt2 = sinc((ll-llt)*tau*df).^2;
        gb2 = sinc((([0:L]'*tau*ones(size(kinfo.t)) - ones([L+1 1])*kinfo.t)*df)).^2;
        beta = 0; %.00001;
        % a2 has the 1D temporal interpolators
        a2 = inv(ggt2 + beta*eye(L+1))*gb2;
        % tints has the gridded versions of a2
        % make time map
        datgr = reshape(kbgrid_mex(kx,ky,tt,ones(size(kx)),nim*OVER,kb_gridl*OVER,kbweights(:)),[nim nim]*OVER);
        tmap = real(datgr)./(imag(datgr)+eps);
        tints = zeros(nim*OVER,nim*OVER,L+1);
        for l = 0:L
            tmpint = interp1(kinfo.t,a2(l+1,:),tmap);
            tints(:,:,l+1) = tmpint.*apod;
        end
        tints(find(isnan(tints))) = 0;
    end
end
kdens = kinfo.kdens.*kinfo.kmod;
[kkx kky] = meshgrid([0:nim*OVER-1]);
fftshmask = (-1).^(kkx + kky);

% for iter recon
% ??

if (args.map == 1)
    rtype = 'ft'; % do straight ft recon for field mapping
    fm = zeros(nim,nim,nslices);
    stsl = 0; ensl = nslices;
    stph = 0; enph = 2; iph = 0; args.unfact = 1; args.unf = 0;
    for slnum = stsl:ensl-1
        % do field map recon here
        dat0 = loaddat_ex2(0,slnum,scaninfo,fid);
        dat1 = loaddat_ex2(1,slnum,scaninfo,fid);
        immap = zeros([nim nim]);
        for coilnum = 1:ncoils
            phnum = 0;
            dat = dat0;
            % do standard recon
            docprec;

            imkbsv = imkb;
            if (scaninfo.revflg == 2)
                if (im1nz == 1)
                    im1sv = im1;
                end
            end

            phnum = 1;
            dat = dat1;
            % do standard recon
            docprec;

            imkb = imkb .* conj(imkbsv);
            if (scaninfo.revflg == 2)
                if (im1nz == 1)
                    imkb = imkb + im1 .* conj(im1sv);
                end
            end
            immap = immap + imkb;
        end % for coilnum
        % add fancy smoother
        mnfm = mean(immap(:));
        fmtmp = angle(immap.*exp(-i*angle(mnfm)));
        fmmag = sqrt(abs(immap));
        fmsm = angle(conv2(fmmag.*exp(i*fmtmp),ones([7 7]),'same'))+angle(mnfm);
        fm(:,:,slnum+1) = fmsm/(scaninfo.mapdel*1e-6)/2/pi; % in Hz
    end % for slnum
    save fmfile fm;
    % added by RCWelsh 2012-08-22
    outputFileName='fmfile.mat';
else
    rtype = args.rtype;
    if (args.rtype ~= 'ft')
        load fmfile;
    end
    if (iph == 0)
        stph = ((1-zflg)*mapdda*unfact);
        enph = nphases*unfact;
    else
        stph = iph-1+mapdda;
        enph = iph+mapdda;
    end
    if (isl == 0)
        stsl = 0; ensl = nslices;
    else
        stsl = isl-1; ensl = isl;
    end

    imar = zeros([nim nim nslices]);
    ahdr = make_ahdr(args,scaninfo);


    if args.allcoils == 1
        imarall = zeros([nim nim nslices ncoils]);
    end % if args.allcoils == 1
    if args.svraw == 1
        imarraw = zeros([OVER*nim OVER*nim nslices ncoils]);
    end % if args.svraw == 1
    for phnum = stph:enph-1
        phnumout = phnum + 1 - mapdda*unfact;
        if (args.out == 1)
            disp(sprintf('Time point = %d',phnumout));
        end
        for slnum = stsl:ensl-1
            % load data for for/rev, spirals, all coils
            dat = loaddat_ex2(phnum,slnum,scaninfo,fid);
            for coilnum = 1:ncoils

                % do ft or cp recon
                docprec;

                % combine if necessary
                if (scaninfo.revflg == 2)
                    if (im1nz == 1)
                        imkb = abs(abs(imkb) + i*abs(im1));
                    end
                end

                if args.flipx == 1
                    imkb = flipud(imkb);
                end
                if args.flipy == 1
                    imkb = fliplr(imkb);
                end
                if args.svraw == 1
                    imarraw(:,:,slnum+1,coilnum) = datgr;
                end % if args.svraw == 1
                if args.allcoils == 1
                    imarall(:,:,slnum+1,coilnum) = imkb;
                end % if args.allcoils == 1
                if ncoils > 1
                    % do L2 norm for multicoil
                    if coilnum == 1
                        imout = abs(imkb);
                    else
                        imout = abs(imout + i.*abs(imkb));
                    end
                    imkb = imout;
                end % if ncoils > 1
            end % for coilnum = 1:ncoils
            % now output indivual images image
            imar(:,:,slnum+1) = imkb;
            if strcmp(args.outfmt, 'sl')
                basestr = sprintf('sl%d.%03d',sl,fn);
                writeim(basestr,abs(imkb));
            end % if args.outfmt = 'sl'
        end % for slnum = stsl:ensl-1

        % write out full arrays
        basestr = sprintf('vol_e%d_%s_%04d',scaninfo.exam,datestr,phnum+args.imoffset);
        if args.svraw == 1
            eval(['save ' basestr '_raw imarraw;']);
        end % if args.svraw == 1
        if args.allcoils == 1
            eval(['save ' basestr '_all imarall;']);
        end % if args.allcoils == 1
        if strcmp(args.outfmt,'nifti')
            niidata(nii_start:nii_stop) =  abs(imar(:));
            nii_start = nii_stop +1;
            nii_stop = nii_stop + pixperframe;
        end
        if strcmp(args.outfmt, 'anal')
            write_hdr([basestr '.hdr'],ahdr);
            write_img([basestr '.img'],abs(imar),ahdr);
        elseif strcmp(args.outfmt, 'mat')
            if args.complex == 0
                imar = abs(imar);
            end
            eval(['save ' basestr ' imar;']);
        end % if args.outfmt == 'anal'

    end %for phnum = stph:enph-1
    % Added by RCWelsh 2012-08-22
    outputFileName = basestr;
end % if (args.map == 1)

% I'm not sure why this block of code is not up about the end as its for creating the actual 
% reconstructed data versus the field map. - RCWelsh 2012-08-22

if strcmp(args.outfmt,'nifti')
    nhdr = avw2nii_hdr(ahdr);
    nhdr.dim(1) = 4;
    nhdr.dim(5) = nphases -1;
    nhdr.dim(5) = nphases - mapdda;  % LHG - if you do a field map, the first one doesn't get counted.
    write_nii(sprintf('%s.nii',basestr),niidata, nhdr,0);
end


