function [FdaSNR,BhatFdaSNR,GammahatFdaSNR,sigma2hatFdaSNR] = spmJr_cplx2 (root, X, C)
% [FdaSNR,BhatFdaSNR,GammahatFdaSNR,sigma2hatFdaSNR] = spmJr_cplx2 (file_root, Desmat, contrast_vector)
%
% Created by Daniel Rowe so includeme please!
% Large SNR approximation Mag and Phase Act of
% Rowe, D.B.:  Modeling both the magnitude and phase of
% complex-valued fMRI data. NeuroImage 25(4):1310-1324, 2005.
% but still cite above.
% Under H0 this produces an F stat with 2r and 2n-2(q+1) df
% where q+1 is the number of columns in X
% and r is the number of rows in C
% Don't forget this is only for LARGE SNR!
%
% Bonus materials by Luis Hernandez:
%
% we also compute stats maps based on magnitude and phase data by
% themselves... this is useful for comparison and troubleshooting.
% It is done bbyt straight OLS estimation
%
% inputs:
%
% file_root:  this is where the data live:  either a single 4D AVW format or
%             a time series of files containing the individual frames.
%             if this is not a string, I assume you enetered a t x p matrix, where
%             columns are pixels and rows are time points
% DesMat:     The design matrix.  The dimensions must be [time x regressors]
% contrast:   contrast vector
%
%
% outputs:	we write out the statistical maps and the paramaters estimates of each analysis
%			in analyze format images:
%
%			Fmap_cplx, Fmap_mag, Fmap_phs
%			Tmap_mag, Tmap_phs
%			log10P_cplx, log10P_mag, log10P_phs  (these are the
%			-10*log10(pvalues of the F maps)
%			Bhats_mag, Bhats_phs
%			Bhats_cplx, Ghats_cplx are the magnitude and phase coefficients
%			resulting from the complex analysis
% usage:
%
% [FdaSNR,BhatFdaSNR,GammahatFdaSNR,sigma2hatFdaSNR] =
%         spmJr_cplx2(file_root, Desmat, contrast_vector)

doMask = 1;
writeFiles = 1;

if isstr(root)
    names = dir(sprintf('%s*',root));
    suffix = names(1).name(end-3:end);
    if suffix=='.nii'
        [mdata, h] = read_img(names(1).name);
        %h = nii2avw_hdr(h);
    else
        mdata = read_img_series(root);
        hnames = dir(sprintf('%s*.hdr',root))
        h = read_hdr(hnames(1).name);
    end
    fprintf('\n Done reading the magnitude data. ...');
    
    names = dir(sprintf('p_%s*',root));
    suffix = names(1).name(end-3:end);
    if suffix=='.nii'
        [pdata, h] = read_img(names(1).name);
        %h = nii2avw_hdr(h);
    else
        pdata = read_img_series(sprintf('p_%s*',root));
        hnames = dir(sprintf('p_%s*.hdr',root))
        h = read_hdr(hnames(1).name);
    end
    fprintf('\n Done reading the phase data. crunching ...');
    
    % merge data into complex numbers:
    Ycomp = mdata .* exp(-i* pdata/1000);
    
else
    % in case the data didn't come from a file but from a matrix
    Ycomp=root;
    writeFiles = 0;
    
end


[n,p]=size(Ycomp);
q=size(X,2)-1;
df=2*n-2*(q+1);

CC = [
    [C,   zeros(size(C,1),size(C,2))];
    [zeros(size(C,1),size(C,2))],   C];

% Number of time frames
[r]=size(CC,1);

BhatFdaSNR=zeros(q+1,p);
GammahatFdaSNR=zeros(q+1,p);
sigma2hatFdaSNR=zeros(p,1);
FdaSNR=zeros(p,1);

demeanphase=1;
% Mean center the phase of the time course
if (demeanphase==1)
    phibar=zeros(1,p);
    if(abs(Ycomp(1,1))~=0)
        phibar=angle(sum(Ycomp./abs(Ycomp)));
    else
        for count=1:p
            if abs(Ycomp(:,count))~=0
                phibar(1,count)=angle(sum(Ycomp(:,count)./abs(Ycomp(:,count))));
            end
        end
    end
    Ycomp=Ycomp.*kron(ones(n,1),exp(-i*phibar));
end

% split the data back up
Y=abs(Ycomp);,
Yphi=angle(Ycomp);
clear Ycomp

if doMask
    mask = mean(Y,1);
    threshold = 4*median(mask(:));
    mask( mask < threshold) = 0;
    mask( mask >= threshold ) = 1;
end

if 1
    
    %% Complex Analysis Here:
    fprintf('\nBegin Complex Analysis ...');
    W=inv(X'*X);
    BhatFdaSNR=W*X'*Y;
    
    for count=1:p
        if Y(1,count)~=0;
            
            GammahatFdaSNR(:,count) = inv(X'*diag(Y(:,count).^2)*X)*X'*diag(Y(:,count).^2)*Yphi(:,count);
            
            sigma2hatFdaSNR(count,1) = (Y(:,count)-X*BhatFdaSNR(:,count))' * (Y(:,count)-X*BhatFdaSNR(:,count)) + ...
                (Yphi(:,count)-X*GammahatFdaSNR(:,count))'*diag(Y(:,count).^2)*(Yphi(:,count)-X*GammahatFdaSNR(:,count));
            
            FdaSNR(count,1) = (CC*[BhatFdaSNR(:,count);GammahatFdaSNR(:,count)] )'* ...
                inv(CC*[W,zeros(q+1,q+1);zeros(q+1,q+1),inv(X'*diag(Y(:,count).^2)*X)]*CC')* ...
                ( CC*[BhatFdaSNR(:,count);GammahatFdaSNR(:,count)] ) ...
                /sigma2hatFdaSNR(count,1);
        end
    end
    
    if doMask
        FdaSNR = FdaSNR'.*mask;
        BhatFdaSNR = BhatFdaSNR.*repmat(mask,q+1,1);
        GammahatFdaSNR = GammahatFdaSNR.*repmat(mask,q+1,1);
    end
    
    FdaSNR=FdaSNR*df/r;
    
    pval = 1- Fcdf(FdaSNR,df,r);
    
    if (demeanphase==1)
        GammahatFdaSNR(1,:)=angle(exp(i*GammahatFdaSNR(1,:)).*exp(i*phibar));
    end
    
    sigma2hatFdaSNR=sigma2hatFdaSNR/df;
    
    if writeFiles
        % write out some files:
        outh = h;
        outh.tdim = 1;
        outh.datatype = 16;
        outh.bits = 32;
        write_hdr( 'Fmap_cplx.hdr', outh);
        write_img_data( 'Fmap_cplx.img', FdaSNR', outh);
        
        write_hdr( 'ResVar_cplx.hdr', outh);
        write_img_data( 'ResVar_cplx.img', sigma2hatFdaSNR, outh);
        
        write_hdr( sprintf('log10Pcplx.hdr',n), outh);
        write_img_data( sprintf('log10Pcplx.img',n), -log10(pval), outh);
        
        
        outh.tdim = size(BhatFdaSNR,1);
        write_hdr( 'Bhats_cplx.hdr', outh);
        write_img_data( 'Bhats_cplx.img', BhatFdaSNR', outh);
        
        write_hdr( 'Ghats_cplx.hdr', outh);
        write_img_data( 'Ghats_cplx.img', GammahatFdaSNR', outh);
    end
    
end

%%  Magnitude Analysis Here
fprintf('\nBegin Magnitude Only Analysis ...');

p1 = size(X,2);
Nframes = size(Y,1);
Npix = size(Y,2);
df2 = Nframes-p1 -1;
df1 = 1;

sigma2hat = zeros(1,Npix);
RSS = zeros(1,Npix);
vCon = zeros(1,Npix);


Xinv = pinv(X);
% W = inv(X'*X);
Bhat_mag = Xinv*Y;
DC = diag(C);


% compute residual variance ...
for p=1:Npix
    sigma2hat(p) = (Y(:,p) - X*Bhat_mag(:,p))' * (Y(:,p)-X*Bhat_mag(:,p)) / df2;
    % RSS(p) = (Y(:,p) - X*DC*Bhat_mag(:,p))' * (Y(:,p) - X*DC*Bhat_mag(:,p)) ;
    % RSS(p) = sigma2hat(p) + (DC*Bhat_mag(:,p))'*X'*X*(DC*Bhat_mag(:,p)) ;
    vCon(p) = C * Xinv * sigma2hat(p) * Xinv' * C';
    Tmap(p) = C*Bhat_mag(:,p) / sqrt(vCon(p));
end

if doMask
    Tmap = Tmap.*mask;
    Bhat_mag = Bhat_mag.*repmat(mask, p1,1);
    
end

Fmap = Tmap .^2;
% change in residual variances from model
%Fmap = (RSS - sigma2hat) ./ sigma2hat;
% adjust for degrees of freedom
%Fmap = Fmap *  df1/df2;

% compute significance
pval = 1- Fcdf(Fmap,df2,df1);
pval(pval==Inf) = 0;
pval(pval==nan) = 0;

if writeFiles
    outh = h;
    outh.datatype = 16;
    outh.bits = 32;
    outh.tdim = 1;
    
    write_hdr( 'Tmap_mag.hdr', outh);
    write_img_data( 'Tmap_mag.img', Tmap', outh);
    
    write_hdr( 'Fmap_mag.hdr', outh);
    write_img_data( 'Fmap_mag.img', Fmap', outh);
    
    write_hdr( sprintf('log10Pmag.hdr',n), outh);
    write_img_data( sprintf('log10Pmag.img',n), -log10(pval), outh);
    
    % write out some other files ...
    outh.tdim = size(Bhat_mag,1);
    write_hdr( 'Bhats_mag.hdr', outh);
    write_img_data( 'Bhats_mag.img', Bhat_mag', outh);
end



%%  Phase Analysis Here
fprintf('\nBegin Phase Only Analysis ...');

p1 = size(X,2);
Nframes = size(Yphi,1);
Npix = size(Yphi,2);
df2 = Nframes-p1 -1;
df1 = 1;

sigma2hat = zeros(1,Npix);
RSS = zeros(1,Npix);
vCon = zeros(1,Npix);


Xinv = pinv(X);
% W = inv(X'*X);
Bhat_phs = Xinv*Yphi;
DC = diag(C);


% compute residual variance ...
for p=1:Npix
    sigma2hat(p) = (Yphi(:,p) - X*Bhat_phs(:,p))' * (Yphi(:,p)-X*Bhat_phs(:,p)) / df2;
    % RSS(p) = (Y(:,p) - X*DC*Bhat_phs(:,p))' * (Y(:,p) - X*DC*Bhat_phs(:,p)) ;
    % RSS(p) = sigma2hat(p) + (DC*Bhat_phs(:,p))'*X'*X*(DC*Bhat_phs(:,p)) ;
    vCon(p) = C * Xinv * sigma2hat(p) * Xinv' * C';
    Tmap(p) = C*Bhat_phs(:,p) / sqrt(vCon(p));
end

if doMask
    Tmap = Tmap.*mask;
    Bhat_phs = Bhat_phs.*repmat(mask, p1,1);
    
end

Fmap = Tmap .^2;
% change in residual variances from model
%Fmap = (RSS - sigma2hat) ./ sigma2hat;
% adjust for degrees of freedom
%Fmap = Fmap *  df1/df2;

% compute significance
pval = 1- Fcdf(Fmap,df2,df1);
pval(pval==Inf) = 0;
pval(pval==nan) = 0;

if writeFiles
    outh = h;
    outh.datatype = 16;
    outh.bits = 32;
    outh.tdim = 1;
    write_hdr( 'Fmap_phs.hdr', outh);
    write_img_data( 'Fmap_phs.img', Fmap', outh);
    
    write_hdr( 'Tmap_phs.hdr', outh);
    write_img_data( 'Tmap_phs.img', Tmap', outh);
    
    write_hdr( sprintf('log10Pphs.hdr',n), outh);
    write_img_data( sprintf('log10Pphs.img',n), -log10(pval), outh);
    
    
    % write out some other files ...
    outh.tdim = size(Bhat_phs,1);
    write_hdr( 'Bhats_phs.hdr', outh);
    write_img_data( 'Bhats_phs.img', Bhat_phs', outh);
end



