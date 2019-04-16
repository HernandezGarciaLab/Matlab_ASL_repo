function beta2flow(betafile, TR, Ttrans, pid, Ttag, inv_alpha, isSubtracted)
% function beta2flow(betafile, TR, Ttrans, pid, Ttag, inv_alpha, isSubtracted)
%
% Takes the parameter estimates of a GLM for ASL data and turns them into 
% perfusion values.
%
% important assumptions:
% - if data are unsubtracted, beta_0 is the intercept = the baseline (Mcontrol)
%     we assume betas(1,:) = beta_0 map
% - at 3Tesla, constants are approxiamated as:
%     partition coeff. lambda = 0.9;
%     gray matter T1 = 1.4;
%     arterial blood T1a = 1.65;
% - output units are in 100* ml/min/100g

lambda = 0.9;
T1 = 1.25;
T1a = 1.65;
T1app=1/(1/T1 + 0.015/lambda);



[betas h] = read_img(betafile);
if isSubtracted
	c = read_img('mean_con');
else
	c = betas(1,:) ; % beta_0 is the intercept = the baseline (Mcontrol)
end

Nbetas = size(betas,1);

mask = zeros(size(c));
mask(find(c>0.2*max(c(:))))=1;

M0 = c/(1 - exp(-TR/T1));

% This is equation 3 from Alsop et al: JCBFM 16, 1236-1249,1996
%den = T1app*2*M0*inv_alpha/lambda * exp(-Ttrans*(1/T1a-1/T1app))*exp(-pid/T1a);

% modification by Wang et al MRM 48,2,p242-254, 2002:
%den = T1app*2*M0*inv_alpha/lambda * ...
%    (exp(-Ttrans*(1/T1a-1/T1app)) - exp((Ttrans-pid-Ttag)/T1app))...
%    *exp(- pid/T1a);

% looking at equation 1, delta_a and delta should be almost the same, we
% can drop a term.
den =  2 * M0* inv_alpha / lambda ...
    *( T1app*exp(-Ttrans/T1a) * ( exp( (Ttrans-pid)/T1app ) - exp( (Ttrans-Ttag-pid)/T1app)));

den = repmat(den, Nbetas,1);
mask = repmat(mask, Nbetas,1);

f = betas./den * 6000;
f = f.*mask;

f(find(isnan(f))) = 0;

write_img('ExpFlows.img',f ,h);
write_hdr('ExpFlows.hdr',h);