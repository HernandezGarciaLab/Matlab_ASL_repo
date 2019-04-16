function spmJr_cplx (root, X, contrast)

% spmJr (file_root, Desmat, contrast_matrix)
%
% The extremely quick and dirty SPM analysis with complex analysis
%
%   (c) 2008 Luis Hernandez-Garcia
%   University of Michigan
%   report bugs to:  hernan@umich.edu
%
% Hotelling's T^2 test .  reference Lee MRM '07
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
		[mdata, h] = read_img(names(1).name);
		h = nii2avw_hdr(h);
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
		h = nii2avw_hdr(h);
	else
		pdata = read_img_series(sprintf('p_%s*',root));
		hnames = dir(sprintf('p_%s*.hdr',root))
		h = read_hdr(hnames(1).name);
	end
	fprintf('\n Done reading the phase data. crunching ...');

	all_data = mdata .* exp(-i* pdata/1000);

else
	all_data=root;
end

Yreal = real(all_data);
Yimag = imag(all_data);

[Nframes, Npixels] = size(Yreal);


Ncon = size(contrast,1);

% compute some of the parts the will get used over and over later in the
% loop now to save time
BhatR = pinv(X)*Yreal;
BhatI = pinv(X)*Yimag;
XTXinv = inv(X'*X);

%compute rediduals
residsR = Yreal - X*BhatR;
residsI = Yimag - X*BhatI;

% allocate space for results:
fmap = zeros(Ncon,Npixels);
T2map = zeros(Ncon, Npixels);
pvals = zeros(Ncon,Npixels);



for pix=1:Npixels

	if all_data(1,pix) ~= 0
		CovMat = cov(residsR(:,pix), residsI(:,pix));
		BhatRI = [BhatR(:,pix) BhatI(:,pix)];
		for n=1:Ncon
			C = contrast(n,:);
			p1 = length(C);
			p2 = length(find(C));

			vCon = CovMat*(C*XTXinv*C');
			% Hotelling's T^2 score is the ratio of the contrast
			% parameter estimates to the their variance
			T2map(n, pix) = C * BhatRI * inv(vCon) * BhatRI' * C';
			fmap(n,pix) = T2map(n,pix) * (Nframes-p1)/ (Nframes-1) / p2;
			pvals(n,pix) = 1-fcdf(fmap(n,pix),p1,  Nframes);

		end
	end
end


pvals(pvals==1) = NaN;
pvals(pvals==0) = NaN;

fprintf('\n Writing output files (Fmaps) ...');


if isstr(root)
	for n=1:Ncon
		% save the best damn time course (the one with the higest F score)
		ind = find(fmap(n,:) ==max(fmap(n,:)));
		bdtc(:,n) = all_data(:,ind);
		% make sure that we write stats maps as floats.
		outh = h;
		outh.tdim = 1;
		outh.datatype=16;
		outh.bits = 32;

		write_hdr( sprintf('HotellingT_%04d.hdr', n), outh);
		write_img_data( sprintf('HotellingT_%04d.img',n), T2map(n,:), outh);


		write_hdr( sprintf('Fmap_%04d.hdr',n), outh);
		write_img_data( sprintf('Fmap_%04d.img',n), fmap(n,:), outh);

		write_hdr( sprintf('log10P_%04d.hdr',n), outh);
		write_img_data( sprintf('log10P_%04d.img',n), -log10(pvals(n,:)), outh);

		warning on
	end
end

fprintf('\nSaving Intermediate data to spmJr.mat file ...');
save spmJr_cplx BhatRI contrast X T2map fmap pvals bdtc

fprintf('\n...Done');
return

% unused code:

C = contrast(n,:)
p1 = length(C);
p2 = length(find(C));
invCWCt = inv(C*W*C');

sigma2hat(pix) = ...
	(Ycomp(:,pix) - X*BhatRI(:,pix))'*...
	(Ycomp(:,pix) - X*BhatRI(:,pix));...
	%{ toy problem
vCon = ...
	(y - X*(BhatRI.*C'))' *...
	(y - X*(BhatRI.*C')) * ...
	(p1-p2);

sigma2hat = ...
	(y - X*BhatRI)'*...
	(y - X*BhatRI) * ...
	(Nframes-p2);...

F =  vCon / sigma2hat
pval = 1-fcdf(F, p1-p2, Nframes-p2)
%}

if sigma2hat(pix)~=0
	% compute the residual variance of reduced model
	vCon(pix,n) = ...
		(Ycomp(:,pix) - X*(BhatRI(:,pix).*C'))' *...
		(Ycomp(:,pix) - X*(BhatRI(:,pix).*C'));

	% F score is variance of the contrast  parameter estimates
	% over the total residual variance.
	% see stat4GLMPrint.pdf slide 29 and 33
	fmap(n,pix) = (vCon(pix,n) - sigma2hat(pix) )./ sigma2hat(pix);
end

