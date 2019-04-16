function spmJr (root, DesMat, contrast)

% spmJr (file_root, Desmat, contrast_matrix)
%
% The extremely quick and dirty SPM analysis
%
%   (c) 2006 Luis Hernandez-Garcia 
%   University of Michigan
%   report bugs to:  hernan@umich.edu
%
% The program solves the linear model specified in DesMat for the
% parameters by ordinary least squares.  It calculates T scores and Z scores
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
%
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

names = dir(sprintf('%s*',root));
if isstr(root)
    names = dir(sprintf('%s*',root));    
    suffix = names(1).name(end-3:end);
    if suffix=='.nii' 
        [all_data, h] = read_img(names(1).name);
        h = nii2avw_hdr(h);
    else
        all_data = read_img_series(root);
        hnames = dir(sprintf('%s*.hdr',root))
        h = read_hdr(hnames(1).name);
    end
	fprintf('\n Done reading the data. crunching ...');
else
        all_data=root;
end

Ncon = size(contrast,1);

tmap = zeros( Ncon, size(all_data, 2));
vCon = zeros( Ncon, size(all_data, 2));
Tol = 10^(-16);
df = size(all_data,1) - size(DesMat,2)+1;

warning off

fprintf('\n Estimating Beta parameters and variance ...');

xtx_inv = pinv(DesMat);
beta_est = xtx_inv*all_data;
V = var(all_data);

for n=1:size(contrast,1)
    fprintf('\n Contrast n. %d ...',n);

    for pix=1:size(all_data,2)
        vCon(n,pix) = contrast(n,:) * xtx_inv * V(pix) * xtx_inv' * contrast(n,:)';

    end
    
    tmap(n,:) = ((beta_est' * contrast(n,:)') ./ sqrt(vCon(n,:))')';
end



tmap(find(isnan(tmap)))=0;
tmap(find(isinf(tmap)))=0;
zmap = tmap;
zmap = spm_t2z(tmap(:),df);
zmap = reshape(zmap,Ncon, size(all_data, 2));

fprintf('\n Writing output files (Tmap, Zmap) ...');

if isstr(root)
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

    outh.glmax = max(vCon(n,:));
    outh.glmin = min(vCon(n,:));
    write_hdr( sprintf('ConVar_%04d.hdr', n), outh);
    write_img_data( sprintf('ConVar_%04d.img',n), vCon(n,:), outh);

    outh.glmax = max(zmap(n,:));
    outh.glmin = min(zmap(n,:));
    write_hdr( sprintf('Zmap_%04d.hdr',n), outh);
    write_img_data( sprintf('Zmap_%04d.img',n), zmap(n,:), outh);
    warning on
  end
end

fprintf('\nSaving Intermediate data to spmJr.mat file ...');
save spmJr beta_est contrast DesMat vCon df zmap tmap

fprintf('\n...Done');
return





