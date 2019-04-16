function Tscore = imgConnect(hdr, data, xyz, DesMat)
% function Tscore = imgConnect(header, timeseries_data, xyz_coords,DesMat)
%
% Compute connectivity (T-score) time series of images specified by
% rootname (this can be one of the images in the timeseries, or just the
% root part of the file names)
%
% x,y,z are the voxel coordinates of the region that we
% want to use for extraction of the seed time course.
%
% Desmat is the design matrix containing the effects that
% can be modeled by the experimental conditions
%
% (c) 2011 Luis Hernandez-Garcia 
% University of Michigan
% report bugs to:  hernan@umich.edu
%
%

%Nlag = 7;
doPlots = 0;
doDetrend = 0;
doGlobal = 1;

x = xyz(:,1);
y = xyz(:,2);
z = xyz(:,3);


fprintf('\nBegin Connectivity Analysis ..')
fprintf('\n indexing ...\n')
ind = sub2ind([hdr.xdim, hdr.ydim, hdr.zdim], x,y,z);

seed = data(:,ind);
% average time series over pixels if we select several pixels
% in the seed ROI.
fprintf('\n averaging ...\n')
seed = mean(seed,2);

seed = seed - mean(seed);
seed = seed / norm(seed);

if doDetrend
    % filter the seed here
    seed = mydetrend(seed')';
end

if isempty(DesMat)
    DesMat = ones(size(seed));
end

if doGlobal
    globalseries = mean(data,2);
    globalseries = globalseries - mean(globalseries);
    globalseries = globalseries/norm(globalseries);
    DesMat = [DesMat globalseries ];
end

X = [seed DesMat]; 
contrast = zeros(1,size(X,2));
contrast(1) = 1;

% Trying to avoid some issues with memory on 32 bit machines:
X=single(X);
data=single(data);

fprintf('\n Estimating ...\n')
xtx_inv = pinv(X);
beta_est = xtx_inv*data;
 
oldfig = gcf;
%{
% Let's display the estimates at each pixel
figure(45)
subplot(221)
tmp = reshape(beta_est(1,:), [hdr.xdim, hdr.ydim, hdr.zdim]);
lightbox(tmp); 
colorbar
title('Estimated coefficient for the time course (regressor 1)')
 
subplot(222)
tmp = reshape(beta_est(2,:), [hdr.xdim, hdr.ydim, hdr.zdim]);
lightbox(tmp); 
colorbar
title('Estimated coefficient for the baseline (regressor 2)')
%}

%residuals = data - X*beta_est;
V = var(data);
N = size(data,1);
p = size(beta_est,1);

fprintf('\n Computing T scores ...\n')

for pix = 1:length(V)
    Tscore(pix) = beta_est(1,pix) / ...
        sqrt(contrast * xtx_inv * V(pix) * xtx_inv' * contrast' + eps);
end
%{
% Display the residual variance after the fit

subplot(223)
tmp = reshape(V, [hdr.xdim, hdr.ydim, hdr.zdim]);
lightbox(tmp); 
colorbar
title('Estimated Variance of the Residual')
 
% display the T score of the second regressor
subplot(224)
tmp = reshape(Tscore, [hdr.xdim, hdr.ydim, hdr.zdim]);
lightbox(tmp); 
caxis([-20 20])
colorbar
title('T score for the first regressor')
%}


fprintf('\n Computing p-values ...\n')
pval = 1 - spm_Tcdf(Tscore,length(seed)- size(X,2) -1);

mx = mean(x);
my = mean(y);
mz = mean(z);


Tscore = reshape(Tscore, [hdr.xdim, hdr.ydim, hdr.zdim]);
%subplot(224)
%hist(Tscore(Tscore~=0),100);title('Distribution of T scores')



% show histograms of the results.

%lim = abs(4*std(Tscore(:)));
%figure; 
%lightbox(Tscore, [-lim lim], ceil(sqrt(hdr.zdim)));
%figure(oldfig)


	
fprintf('\n writing results ... connect_T.img ...')
global SPM_scale_factor
SPM_scale_factor = 1/1000;
hdr.tdim=1;
hdr.datatype = 4;

write_hdr('connect_log10P.hdr',hdr);
write_img('connect_log10P.img',-log10(pval)/SPM_scale_factor, hdr);

write_hdr('connect_T.hdr',hdr);
write_img('connect_T.img',Tscore/SPM_scale_factor,hdr);

fprintf(' Done\n')

return
