function strFileOut = sprec1_3d_grappaz(args,scaninfo,kinfo)
%function strFileOut = sprec1_3d_grappaz(pfile,varargin)

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
%
% Luis Hernandez-Garcia: 2010
% included FFT along kz dimension for 3D spiral reconstruction
%
% Luis Hernandez-Garcia: 2016
% including GRAPPA rexon along z axis
%

SHOWME = 0;
scriptmode = 0;
warning off

% if scriptmode == 1
%     % in script mode, this is how recon is setup
%     [args,scaninfo,kinfo] = rec_setup1('Pcrush00','ft','sl','l','v');
% else
%     if exist('pfile','var') == 0
%         rec_setup1;
%         return
%     else
%         [args,scaninfo,kinfo] = rec_setup1(pfile,varargin{:});
%     end
% end % if scriptmode == 1

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

ndat = scaninfo.ndat;

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
        
        if args.RR==1  % reverse the rotation of the spiral leaves for multi shot LHG 1/10/19
            kx = [kx real(kinfo.k.*exp(i*2*pi*(prnum-1)/npr))*OVER];
            ky = [ky imag(kinfo.k.*exp(i*2*pi*(prnum-1)/npr))*OVER];
        else
            kx = [kx real(kinfo.k.*exp(-i*2*pi*(prnum-1)/npr))*OVER];
            ky = [ky imag(kinfo.k.*exp(-i*2*pi*(prnum-1)/npr))*OVER];
        end
        
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
    rtype = args.rtype;
    %  rtype = 'ft'; % do straight ft recon for field mapping
    fm = zeros(nim,nim,nslices);
    stsl = 0; ensl = nslices;
    stph = 0; enph = 2; iph = 0; args.unfact = 1; args.unf = 0;
    for slnum = stsl:ensl-1
        % do field map recon here
        dat0 = loaddat_ex3(0,slnum,scaninfo,fid);
        dat1 = loaddat_ex3(1,slnum,scaninfo,fid);
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
        fmsm = angle(conv2(fmmag.*exp(i*fmtmp),ones(args.fsize),'same'))+angle(mnfm);
        fm(:,:,slnum+1) = fmsm/(scaninfo.mapdel*1e-6)/2/pi; % in Hz
    end % for slnum
    save fmfile fm;
    strFileOut='fmfile.mat';
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
    
    ahdr = make_ahdr(args,scaninfo);
    
    
    if strcmp(args.outfmt,'nifti')
        pixperframe=nim*nim*nslices;
        nii_start = 1;
        nii_stop = pixperframe;
        nii_data = zeros(pixperframe * (enph-stph),1);
        
        if args.dograppaz
            nii_data = zeros(pixperframe*2 * (enph-stph - args.numACS),1);
        end
    end
    
    if args.dograppaz == 1
        imarall = zeros([nim nim nslices ncoils]);
        imarall2 = zeros([nim nim 2*nslices ncoils]);
        imarall_tmp = zeros([nim nim nslices ncoils]);
    end % if args.dograppaz == 1
    

     if args.allcoils == 1
         imarall = zeros([nim nim nslices ncoils]);
     end % if args.allcoils == 1
     
    if args.svraw == 1
        imarraw = zeros([OVER*nim OVER*nim nslices ncoils]);
    end % if args.svraw == 1
    
    
    if args.dograppaz
        % store all the raw spiral data (ungridded) for interpolation
        kspace_all = zeros([ndat ncoils nslices]);
    end
    
    isEven=0;
    
    % allocate space for grappa calibration stuff
    if args.dograppaz


        Nxy = 250;  % this is the number of equations that we will have.  
                   % one for the kz column at each of the kx, ky
        Nkz = 1;   % number of kz neighbors on each side to use in the grappa kernel  
        
        offset = 15; % If I use the first few points from coil 4, 
                             % I get terrible resultsso I skip part of the FID
                             % coil 4, looks time shifted! I don't know why.
              
                             
        % data Buffers for grappa (center of k-space)
        TargetData = zeros(Nxy, 1*ncoils);
        SourceData = zeros(Nxy, (Nkz*2)*ncoils);
        
        evenBuf = zeros(Nxy, ncoils, nslices);
        oddBuf = zeros(Nxy, ncoils, nslices);
        
        % ACS data buffers
        TargetACS = zeros(Nxy, 1*ncoils);
        SourceACS = zeros(Nxy, (Nkz*2)*ncoils);
        
        % Buffer to combine all the planes together before FFT
        imar_out  = zeros(nim, nim, nslices*2);

        % grappaKernel matrix
        
        
        
    end
    
    for phnum = stph:enph-1
                
        imarall = zeros([nim nim nslices ncoils]);
        imar = zeros([nim nim nslices]);
        phnumout = phnum + 1 - mapdda * unfact;
        
        if (args.out == 1)
            disp(sprintf('Time point = %d',phnumout));
        end
        
        for slnum = stsl:ensl-1
            % load data for for/rev, spirals, all coils
            %scaninfo
            
            % dat has an FID on each row from a separate coil or interleave
            dat = loaddat_ex3(phnum,slnum,scaninfo,fid);
            
            % dat = loaddat_ex2_lhg(phnum,slnum,scaninfo,fid);           
            % imagesc(abs(dat)); title(['raw data slice : ' num2str(slnum)]); drawnow; pause(0.5)
            
            
            if args.dograppaz
                kspace_all(:,:, slnum+1) = dat;
            end
               
            if (args.dograppaz)  && ...
                    ( abs(slnum - nslices/2-0.5) < Nkz ) && ...
                    (phnum < args.numACS)
                %&& ...
                %    (phnum > 1)
                % extract and average the calibration data for
                % the GRAPPA kernel calculation
                % Dimensions:
                % dat :         (nk_xy x ncoils)
                % evenBuf :  (Nxy x ncoils x nslices)
                % oddBuf :  (Nxy x ncoils x nslices)
              
                              
                tmp = dat(offset+1 : Nxy +offset, :) ;   % Grab the first few points of the FID for this Kz platter
                
                if phnum <= args.numACS
                    if isEven
                        evenBuf(:,:,slnum) = evenBuf(:,:,slnum) + tmp;
                    else
                        oddBuf(:,:,slnum) = oddBuf(:,:,slnum) + tmp;
                    end
                end
                
                
            end
             
            
            revflg = scaninfo.revflg;
            flipx = args.flipx;
            flipy = args.flipy;
            svraw = args.svraw;
  
            for coilnum = 1:ncoils
                
                % do ft or cp recon
                docprec;
                
                % combine if necessary
                if (revflg == 2)
                    if (im1nz == 1)
                        imkb = abs(abs(imkb) + i*abs(im1));
                    end
                end
                
                if flipx == 1
                    imkb = flipud(imkb);
                end
                if flipy == 1
                    imkb = fliplr(imkb);
                end
                if svraw == 1
                    imarraw(:,:,slnum+1,coilnum) = datgr;
                end % if args.svraw == 1
                              
                imarall(:,:,slnum+1,coilnum) = imkb;
               
               

            end % if ncoils > 1
            %
            
            
            
            
            if SHOWME==2
                figure(1); lightbox(abs(imkb)); drawnow;
            end

            
            if strcmp(args.outfmt, 'sl')
                basestr = sprintf('sl%d.%03d',sl,fn);
                writeim(basestr,abs(imarall));
            end % if args.outfmt = 'sl'
            
            
            
        end % for slnum = stsl:ensl-1
        
        isEven = ~isEven;
        
        
        if phnum == args.numACS && args.dograppaz
            fprintf('\n calculating grappa Kernel...')
            % Now I can compute the grappa coeffients
            
            % solve inverse problem for interpolation kernel
            % TargetData =   grappaKernel * SourceData
            % dimensions:
            % SourceData :     Nxy  x  Nkz*ncoils
            % TargetData :     Nxy  x  ncoils 
            % grappaKernel:    Nkz*2*ncoils  x  ncoils
            %


            
            sourcestart = nslices/2 - Nkz + 1;
            sourceend = nslices/2 + Nkz;
            targetplane = nslices/2;
            
            fprintf('\n source kz lines are from %d to %d in the odd frames', sourcestart, sourceend);
            fprintf('\n target kz line is %d from the even frames', targetplane);
                       
            SourceData = [];
            TargetData = squeeze(evenBuf(:,:, targetplane)); 
            
            %evenBuf = evenBuf/(args.numACS*2)
            %oddBuf = oddBuf/(args.numACS*2)
            
            for slicenum = sourcestart:sourceend
                SourceData = [SourceData squeeze(oddBuf(:,:,slicenum))];
            end
            
            % using regularization:           
            A = SourceData;
            B = TargetData;
            lambda = 1e3;
            grappaKernel = inv(A'*A + lambda*eye(size(A,2)))*A' * B;
             
           % grappaKernel = pinv(SourceData) * TargetData;
            rank(SourceData.')
           
            % compute error in the kernel
            RMSE = 100*norm( (TargetData - SourceData*grappaKernel) ./ TargetData)/length(TargetData(:)) ;    
            
            if  SHOWME==1
                figure(5);
                subplot(223); imagesc(abs(TargetData)); title('Target')
                subplot(221); imagesc(abs(SourceData)); title('Source')
                subplot(222); imagesc(abs(grappaKernel)); title('grappa kernel')
                subplot(224); imagesc(abs(SourceData*grappaKernel)); title('testing S*G')
            end
            fprintf('Done.  norm of the error : %f percent. ', RMSE);
        end
        
      
        
        if args.dograppaz && phnum >= args.numACS
            
            fprintf('\nUsing the grappa Kernel for frame num: %d', phnum);
            % after numACS, we only collect the odd kz platters
            % interpolate the even kz platters from the odd ones
            % first allocate  some space for the output
            % dimensions:
            % imar :            (nim x num x nslices)
            % imarall :         (nim x num x nslices x ncoils)
            % imarall2:         (nim x nim x 2*nslices x ncoils)
            % target  :         1 x ncoils
            % source  :         1 x Nkz*2*ncoils 
            % grappaKernel:     Nkz*2*ncoils  x ncoils
            
            
            % After the ACS calibration, we collect only the odd kz planes
            imarall2(:) = 0;
            imarall2(:, :, 1:2:end,:) = imarall;
            kzcenter = zeros(nslices*2, ncoils);
            kzcenter(1:2:end, :) = squeeze(kspace_all(1,:,:)).';

            
            % ... so we interpolate those data from all coils to 
            % recover the even kz planes.
            for slnum = Nkz : nslices-Nkz

                for k=1:ndat
                        source = squeeze( kspace_all(k, :, slnum-Nkz+1:slnum+Nkz) );
                        
                        target = source(:).' * grappaKernel;
                        
                        %plot(abs(source)); hold on
                        %plot(abs(target),'k*'); drawnow; hold off;
                        
                        % We hijack the variable 'dat' to store the 
                        % the target kz plane that we just calculated 
                        
                        dat(k,:) = target;
                    
                end
                
                % for diagnostics
                kzcenter(slnum*2,:) = dat(1,:);
                        
                for coilnum = 1:ncoils
                    
                    
                    
                    imkb(:) = 0;
                    
                    docprec   % takes dat and generates a regridded, reconned  slice:  imkb
                    
                    imarall2(:,:,slnum*2, coilnum) = imkb;
                end
                % fprintf('\r Filled in kz slice num:  %d', slnum*2);   
                
            end
            
            imarall = imarall2;
            
            
            if SHOWME
                for n=1:ncoils
                    figure(16)
                    subplot(6,6,n)
                    plot(abs(kzcenter(:,n))); 
                    title(sprintf('kz at coil: %d, frame: %d', n, phnum));
                    drawnow
                end
            end
            
        end
        
        if SHOWME==2
            % sanity check :
            if phnum == 1
                kz1 = imarall; % squeeze(imarall(:,:,:,1));
            end
            
            if phnum == 2
    
                kz2 = imarall; % squeeze(imarall(:,:,:,1));
                
                full = zeros(size(imarall));
                full = cat(3,full, full);
                
                full(:,:,1:2:end, :) = kz2;
                full(:,:,2:2:end, :) = kz1;
                

                fullimg = zeros(size(full));
                            
                figure(8)
                subplot(221)
                lightbox(abs(full),[],6); title('combined coils: fully sampled kz space')
                
                for n=1:ncoils
                    fullimg(:,:,:,n) = nslices*fftshift( ifft( fftshift(full(:,:,:,n),3) ,[], 3) ,3 );
                end
                fullimg = sqrt( sum ( (fullimg .* conj(fullimg)) ,4 ) ) ;
                
                subplot(223)
                lightbox(abs(fullimg),[],6);title('combined coils: fully sampled image space')
    
                
                kzcenter = mean(full,1);
                kzcenter = squeeze(mean(kzcenter,2));
                subplot(222)
                plot(abs(kzcenter));
                title('combined coils: fully sampled (0,0,kz) space')

                
                
            end
            
        end
    
        %
        % LHG : do the FFT along the z direction for a stack of spirals
        if (nslices > 1)
            
            imar(:) = 0;
            for n=1:ncoils
                %fprintf('\nFFT along dimension 3, coil: %d, frame num: %d', n, phnum);
                
                tmp = squeeze(imarall(:,:,:,n));
                
                imar = nslices*fftshift( ifft( fftshift(tmp,3) ,[], 3) ,3 );
                
                if n==1, coil1 = tmp; end
                
                imarall(:,:,:,n) = imar;
            end
            %
            if SHOWME==2
                for n=1:ncoils
                    figure(16)
                    subplot(6,6,n)
                    lightbox(abs(tmp)); colorbar off;
                    
                    title(sprintf('interpolated coil: %d, frame num: %d', n, phnum));
                    
                    figure (44)
                    subplot(6,6,n); lightbox(abs(imarall(:,:,:,n))); colorbar off;
                    
                end
                drawnow
                pause
                %
            end
            
            % for debugging .... remove coil 4:   imarall(:,:,:,4) = 0;
            
            % Now combine the coil images:  Root mean square sum over the
            % coils (4th dimension)
            imar_out = sqrt( sum ( imarall .* conj(imarall) ,4 ) ); %/ncoils ; 
            
            if args.complex
                % fix phase difference bettween coils
                %ref_phs = angle(imarall(end/2,end/2,end/2, 5));
                % use coil #4
                ref_phs = angle(imarall(end/2,end/2,end/2, 4));

                for cc=1:ncoils
                    phsdiff = ref_phs - angle(imarall(end/2, end/2, end/2, cc));
                    imarall(:,:,:, cc) = imarall(:,:,:,cc) * exp(-i*phsdiff);
                end
                %imar_out = sqrt( sum ( imarall .* conj(imarall) ,4 ) );
                imar_out = sum(imarall,4);% /ncoils;
            end

        end
        

        
        if SHOWME==2
            figure(3); 
            
            lightbox(abs(imar_out),[],6); 
            title('fft along Z of combined all coils ')
            if args.dograppaz && phnum >= args.numACS
                figure(8)
                subplot(224)            
                RMSE = 100*( (fullimg - imar_out) ./ fullimg) ;    
                
                lightbox(abs(RMSE),[0 50],6);title('% Errors after grappaz: image space')
                RMSE(isnan(RMSE)) = 0;
                RMSE = norm( RMSE(:)) / length(RMSE(:)) ; 
                
                fprintf('\ngrappa RMSE: %f ', RMSE);
            end
        end
        

        
 
        %
        % write out full arrays
        basestr = sprintf('vol_e%d_%s_%04d', scaninfo.exam, datestr, phnum+args.imoffset);
        
        if args.svraw == 1
            eval(['save ' basestr '_raw imarraw;']);
        end % if args.svraw == 1
        
        if args.allcoils == 1
            eval(['save ' basestr '_all imarall;']);
        end % if args.allcoils == 1
        
        
        if strcmp(args.outfmt, 'anal')
            
            ahdr = make_ahdr(args,scaninfo);
            
            if (args.dograppaz)
                % if we are doing GRAPPA, then the dimensions will be different
                ahdr.zdim = nslices*2;li
                ahdr.tdim = ahdr.tdim - args.numACS;
            end
            
            write_hdr([basestr '.hdr'],ahdr);
            write_img([basestr '.img'],abs(imar),ahdr);
            
        elseif strcmp(args.outfmt, 'mat')
            
            if args.complex == 0
                imar_out = abs(imar_out);
            end
            eval(['save ' basestr ' imar_out;']);
        end % if args.outfmt == 'anal'
        
        if strcmp(args.outfmt,'nifti')
            
            if (args.dograppaz && phnum == args.numACS)
                pixperframe = pixperframe * 2;
                nii_start = 1;
            end
            
            nii_stop = nii_start + pixperframe -1 ;
            
            nii_data(nii_start:nii_stop) =  abs(imar_out(:));
            p_nii_data(nii_start:nii_stop) =  angle(imar_out(:));
            
            nii_start = nii_stop +1;
        end
        
    end %for phnum = stph:enph-1
    strFileOut = basestr;
end % if (args.map == 1)

if strcmp(args.outfmt,'nifti')
    
%     ahdr.tdim = nphases ;
    ahdr.tdim = 1 ;

    
    if (args.dograppaz)
        % if we are doing GRAPPA, then the dimensions will be different
        ahdr.zdim = ahdr.zdim*2;
        ahdr.tdim = ahdr.tdim - args.numACS;
    end
    
    nhdr = avw2nii_hdr(ahdr);
    nhdr.dim(1) = 4;
    
    %    write_nii(sprintf('%s.nii',basestr),nii_data, nhdr,0);
    strFileOut = sprintf('%s.nii',basestr);
    write_nii(strFileOut,nii_data, nhdr,0);
    
    % now the phase
    if (args.complex)
        write_nii(sprintf('p_%s.nii',basestr),p_nii_data*1000, nhdr,0);
    end
    
end

end


