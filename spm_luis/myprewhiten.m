function [Yw,Xw,estrho] = myprewhiten(Y,X);
% function [Yw,Xw,estrho] = myprewhiten(Y,X);
%
% Created by Daniel Rowe For Luis Hernandez-Garcia
% seriously by Luis HG for speed.
%
% Prewhiten for AR(1) noise
% Y      = n by p data
% X      = design matrix n by (q+1)
%
% Yw is new, whitened data
% Xw is new whitened design matrix
% estrhoimg is image of AR(1) corr parameters
% Useage is

tm = clock;
warning off
if ~isempty(X)
    %%% individual univariate Regression Significance i.e. t-statistics
    % the model is Y=XB+E
    [Nframes, Npix]=size(Y);
    [Nframes, Nregs]=size(X);,
    Nregs = Nregs;,
    %xydim=sqrt(p);
    resid = Y - X* pinv(X)*Y; % Compute residuals
    %resdind=resid;               % if need to keep residuals
else
    resid = Y;
    resid = resid - mean(resid,1);
end

estrho = zeros(1,Npix);
DurbinWatson = zeros(1,Npix);
Yast=zeros(Nframes, Npix);
Xast=zeros(Nframes, Nregs);

% Estimate autocorrelation coeff. at each pixel of Y matrix
fprintf('\nprewhitening data: %d by %d ...', Nframes, Npix);
for pix = 1:Npix

    lag0 = resid(2:end, pix);
    lag1 = resid(1:end-1, pix);

    invlag1 = pinv(lag1);
    estrho(pix) = -invlag1 * lag0;

    %VarEstRho = invlag1 * var(lag0) * invlag1'
    % this is the DurbinWatson test:
    % 
    % DurbinWatson(pix) = sum ( (lag0 - lag1).^2)  / sum(lag0.^2);

	% make a vector with all the correlations for each lag:
	rhovec = zeros(1,Nframes);
	for c=1:Nframes
		rhovec(c) = estrho(pix)^c;
	end
	
	% stick all the correlations into the autocorrelation matrix
    Kmat = spdiags( ...
        ones(Nframes,1)*[rhovec] , ...
        [0:-1:-Nframes+1], ...
        Nframes, Nframes );
    % invert the autocorrelation matrix
    W = (inv(Kmat));
	%W = W*W;
	% apply the whitening matrix to the original data
    Yw(:,pix) = W*Y(:,pix);
	

end

% must also prewhiten the design matrix. 
% (watch out: different design matrix at every pixel!)
Xw = W*X;

thetime=etime(clock,tm)
fprintf('... done prewhiteing');
return