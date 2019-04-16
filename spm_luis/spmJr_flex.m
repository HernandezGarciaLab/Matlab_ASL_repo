function [betaCon vCon zmap] = spmJr_flex (root, DesMat, contrast, flags)

% spmJr_flex (file_root, Desmat, contrast_matrix)
%
% The extremely quick and dirty SPM analysis
%
%   (c) 2010 Luis Hernandez-Garcia
%   University of Michigan
%   report bugs to:  hernan@umich.edu
%
% The program solves the linear model specified in DesMat for the
% parameters by ordinary least squares.  It calculates T scores and Z scores
%
% This version removes time points from data and design matrix when a NaN is found.
% this is intended to help with RFX analysis of images that are not perfectly aligned after
% normalization because of variable prescription.  It's SLOW .
%
% I'm borrowing (calling) spm_t2z.m  for the Z score calculation.  Thanks!
%
% No filtering, whitening, or
% anything at all is done to the data.  You're on your own for that.
%
% inputs:
%
% file_root:  this is where the data live:  either a single 4D AVW format or
%             a time series of files containing the individual frames.
%             if this is not a string, I assume you enetered a t x p matrix, where
%             columns are pixels and rows are time points
% DesMat:     The design matrix.  The dimensions must be [time x regressors]
% contrast:   a matrix of contrasts.  Each contrast is a row of the matrix.
% flags.doWhiten:  prewhiten data using myprewhiten.m (AR1)
% flags.header:   optional header in case you pass in the data directly.
%
% outputs:
%
% Tmap_????.img   : The t-test for each contrast specified in the matrix
%                  (rows) evaluated at each voxel.  It's in AVW format.
% Zmap_????.img   : the corresponding Z score associated with the t test
% spmJr.mat       : A .mat file containing the following variables used in
%                   the analysis:
%               - beta_est (the parameter estimates for each regressor)
%               - DesMat (the design matrix used in the estimation)
%               - contrast (the contrast matrix)
%               - df (the degrees of freedom in the Z score calculation)
%               - vCon (the estimated variance of the contrast of parameter estimates.
% That sounds more complicated than it is, doesn't it?  You've estimated a parameter,
% ie - the amplitude corresponding to a regressor.  This is a measure of
% the variance or uncertainty of that estimate and it's calculated from the
% variance of the data at that voxel and from the design matrix
%

%names = dir(sprintf('%s*',root));
if isstr(root)
    names = dir(sprintf('%s*',root));
    str = names(1).name;
    [p, root, suffix,v] = fileparts(str);
    %	suffix = names(1).name(end-3:end);
    if suffix=='.nii'
        [all_data, h] = read_img(names(1).name);
        %h = nii2avw_hdr(h);
    else
        all_data = read_img_series(root);
        hnames = dir(sprintf('%s*.hdr',root))
        h = read_hdr(hnames(1).name);
    end
    fprintf('\n Done reading the data. crunching ...');
else
    all_data=root;
    h = flags.header;
end

% Do optional things here:
if nargin>3
    flags
    if flags.doWhiten
        raw = all_data;
        [Yw Xw r] = roweprewhiten(raw, DesMat);
        %tmp = Yw - mean(Yw,1) + mean(all_data,1);
        %all_data = tmp;
        Yw(1,:) = mean(all_data,1);
        all_data = Yw;
        DesMat = Xw;
        % NB that I'm not prewhiteing DesMat !!
    end
end

Ncon = size(contrast,1);
Npix = size(all_data, 2);
tmap = zeros( Ncon, Npix );
zmap = zeros( Ncon, Npix);
vCon = zeros( Ncon, Npix);
beta_est = zeros( size(DesMat,2), Npix);
betaCon = zeros( Ncon, Npix);
var_est = zeros(1, Npix);
Tol = 10^(-16);
df = nan(1, Npix);
Y = zeros(size(all_data,1),1);
%%%%%%
% df = df-2;
%%%%

warning off

fprintf('\n Estimating Beta parameters and variance ...');


all_data(all_data==0) = nan;


for pix=1:size(all_data,2)

    if ~mod(pix,1000)
        fprintf('\rEstimating Parameters ... %f ', 100*pix/size(all_data,2));
    end
    
    % weed out the time points with Nans
    Y = all_data(:,pix);
    inds = find(isfinite(Y));
    
    Y = Y(inds);
    X = DesMat(inds,:);

    % keep track of the new size of things:
    N = size(Y,1);
    p = size(X,2);
    


    % if we have wnough degrees of freedom at this pixel (75% of th etime points are OK)
    % do the calculations ... otherwise it's a zero.
    if N > 0.75*size(all_data,1)
    
        df(pix) = N-p;
        xtx_inv = pinv(X);
        beta_est(:,pix) = xtx_inv*Y;
        
        var_est(pix) = var(Y(pix));

        % calculate stats for the new data
        for n=1:size(contrast,1)
            %var_est(pix) = (Y - X*beta_est(:,pix))'* (Y - X*beta_est(:,pix)) / (N-p);
            vCon(n, pix) = contrast(n,:) * xtx_inv * var_est(pix) * xtx_inv' * contrast(n,:)';        
        end

    end
end
fprintf('\rCalculating T maps ... ');
for n=1:size(contrast,1)
    betaCon(n,:) = (beta_est' * contrast(n,:)') ;
    tmap(n,:) = (beta_est' * contrast(n,:)') ./ sqrt(vCon(n,:))';

end

fprintf('\rMaking Z maps from t maps ... ');
for pix=find(isfinite(df));
    zmap(:,pix) = spm_t2z(tmap(:,pix),df(pix));
end
%tmap = (beta_est' * contrast') ./ sqrt(vCon)';

tmap(find(isnan(tmap)))=0;
tmap(find(isinf(tmap)))=0;


zmap = reshape(zmap,Ncon, Npix);
            
pvals= 1-cdf('norm', zmap, 0,1);
pvals(find(isinf(pvals)))=nan;
pvals(find(abs(pvals)< eps))=nan;


fprintf('\n Writing output files (Tmap, Zmap) ...');

if ~isempty(h)
    for n=1:Ncon
        % make sure that we write stats maps as floats.
        outh = h;
        outh.tdim = 1;
        outh.datatype=16;
        outh.bits = 32;
        outh.glmax = max(tmap(n,:));
        outh.glmin = min(tmap(n,:));

        write_hdr( sprintf('Tmap_%04d.hdr', n), outh);
        write_img_data( sprintf('Tmap_%04d.img',n), tmap(n,:), outh);

        write_hdr( sprintf('log10P_%04d.hdr',n), outh);
        write_img_data( sprintf('log10P_%04d.img',n), -log10(pvals(n,:)), outh);

        outh.glmax = max(vCon(n,:));
        outh.glmin = min(vCon(n,:));
        write_hdr( sprintf('ConVar_%04d.hdr', n), outh);
        write_img_data( sprintf('ConVar_%04d.img',n), vCon(n,:), outh);

        outh.glmax = max(zmap(n,:));
        outh.glmin = min(zmap(n,:));
        write_hdr( sprintf('Zmap_%04d.hdr',n), outh);
        write_img_data( sprintf('Zmap_%04d.img',n), zmap(n,:), outh);

		outh.glmax = max(betaCon(n,:));
        outh.glmin = min(betaCon(n,:));
        write_hdr( sprintf('ConBhat_%04d.hdr',n), outh);
		write_img_data( sprintf('ConBhat_%04d.img',n), betaCon(n,:), outh);
	
		
        warning on
    end

    % write out some other files ...
    outh.tdim = size(beta_est,1);
    write_hdr( 'Bhats.hdr', outh);
	write_img_data( 'Bhats.img', beta_est', outh);

    outh.tdim = size(betaCon,1);
	write_hdr( 'ConBhats.hdr', outh);
	write_img_data( 'ConBhats.img', betaCon', outh);
	
	write_hdr( 'ConVar_hats.hdr', outh);
	write_img_data( 'ConVar_hats.img', vCon', outh);
    
    outh.tdim = 1;
    write_hdr( 'DFreedom.hdr', outh);
	write_img_data( 'DFreedom.img', df, outh);

end

fprintf('\nSaving Intermediate data to spmJr.mat file ...');
save spmJr beta_est contrast DesMat vCon df zmap tmap   var_est

fprintf('\n...Done');
return





