function [clean junkcomps] = compcor12(dirty, hdr, Ncomps, X)
% function [clean junkcomps] = compcor12(dirty, hdr [,Ncomps] [,DesMat])
%
% written by Luis Hernandez-Garcia at UM (c) 2012
%
% the dirty input data should be a matrix : Tframes by Npixels
% The hdr is just to let us know the dimensions of the images
%
% sample usage:
%   [dirty hdr] = read_img('dirtyFiles.img');
%   [clean junkcoms] = compcor12(dirty, hdr);
%   write_img('cleanFile.img', clean, hdr);
%
% Preferred method: you can put the junkcomps into the
% design matrix of a GLM.  In that case, it may be good
% to orthogonalize the junk regressors (J) from the
% original matrix (X), like this:
%
%   for n=1:Ncomps
%       J2(:,n) = J(:,n) - X*pinv(X)*J(:,n)
%   end
%

if nargin<3
    Ncomps = 10;
end

TopPercentSigma = 20;

fprintf('\nFinding the top %d components of the pixels with the top %d of the variance\n...',Ncomps, TopPercentSigma)

if isfield(hdr,'originator')
    hdr=nii2avw_hdr(hdr);
end

sigma = std(dirty,1);
msk = ccvarmask(sigma, TopPercentSigma);
%msk = ones(size(sigma));

figure;
subplot(211)
lightbox(reshape(sigma,hdr.xdim, hdr.ydim, hdr.zdim));
title('std. dev. map')
subplot(212)
lightbox(reshape(msk,hdr.xdim, hdr.ydim, hdr.zdim));
title('pixels for compcor');
set(gcf,'Name', 'Compcor Uses the Noisiest voxels')

mdirty = dirty .* repmat(msk, hdr.tdim,1);
mdirty(isinf(mdirty))=0;
mdirty(isnan(mdirty))=0;

[u, s,v]=svd(mdirty',0);

figure
subplot(211), plot(diag(s)); title('Eigenvalues')
junkcomps = v(:,1:Ncomps);
subplot(212)
plot(junkcomps), title (sprintf('First %d components',Ncomps));
set(gcf,'Name', 'SVD identified Noise components')

% mean center the components:
junkcomps = junkcomps - repmat(mean(junkcomps,1), hdr.tdim,1);

if nargin==4
    if ~isempty(X)
        fprintf('\ndecorrelating from design matrix\n...')
        
        % decorrelate the junk components from the design matrix (desired effects)
        for n=1:size(junkcomps,2)
            junkcomps(:,n)= junkcomps(:,n) - X*pinv(X)*junkcomps(:,n);
        end
    end
end

bhat = pinv(junkcomps)*dirty;
clean = dirty - junkcomps*bhat;
cc_sigma = std(clean,1);

figure;
subplot(211)
lightbox(reshape(sigma,hdr.xdim, hdr.ydim, hdr.zdim));
title('std. dev. map BEFORE')
subplot(212)
lightbox(reshape(cc_sigma,hdr.xdim, hdr.ydim, hdr.zdim));
title('std. dev. map AFTER');
set(gcf,'Name', 'Compcor Reduction in Noise')


return

function msk = ccvarmask(varimage , th)
% makes a mask that preserves the data with the top TH percentage of the
% values

ordered = sort(varimage(:));
Nintgrl = cumsum(ordered)/sum(ordered(:)) * 100;
thval = find(Nintgrl>100-th);
%subplot(211), plot(ordered); title('Ordered Std. Deviations')
%subplot(212), plot(Nintgrl); title('Intrageted , Normalized Std. Deviations')

thval = ordered(thval(1))
msk = varimage;
msk(msk < thval) = 0;
msk(msk>=thval) = 1;
return
