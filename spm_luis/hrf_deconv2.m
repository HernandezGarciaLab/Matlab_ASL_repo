 function [func_hat, var_hat] = hrf_deconv2(data, IRF)
% function [func_hat, var_hat] = hrf_deconv(data, IRF)
%
% deconvolves the hrf from a time series, given:
%
% data - (of course)this needs to be a column
% IRF -  the IRF to deconvolve from the data 
% 
% the function uses a linear regression approach to 
% deconvolve the function.
%
% note - it also adds another regressor to the matrix in order to 
% estimate the DC offset.  This is not reported in the final estimate
%
% it returns:
% fun - the resulting HRF function
% v - the variance estimate for the function
%
%data = data + 100;

IRF = reshape(IRF,length(IRF),1);
data = reshape(data,length(data),1);
data = [data; zeros(size(data))];

x = zeros(size(data));
reg = zeros(size(data));
reg(1:length(IRF)) = IRF;
% make design matrix out of shifted IRFs
for t=1:length(data)/2
    reg = circshift(reg,1);    
    x = [x reg];
end


% add a regressor to estimate the baseline 
x = [x ones(length(data),1)];

[func_hat, var_hat]= linreg(x,data);

baseline = func_hat(end);
func_hat = func_hat(1:end-1);
% add the baseline back in.
func_hat = func_hat + baseline;
return

function [beta_est, var_est] = linreg(x,y)
%function [beta_est, var_est] = linreg(x,y)
%
% gives the least squares estimate for beta in the 
% problem :
%           y = x*beta + error
%
%
% x is the design matrix
% y is the vector of data
% beta_est is the parameter estimates
% var_est is the estimate of the variance on those betas
%
	
	p = size(x,2);
	n = size(x,1);

%	beta_est = (pinv(x'*x))*x'*y;
    beta_est = pinv(x)*y;
    
	RSS = y - x*beta_est;
	RSS = sum(RSS.^2);

	var_est = RSS/(n-p);
	%cov_beta = var_est * xtx_inv;

	% ---- %

	%v = var_est*(c' * xtx_inv * c);
	%t = (beta_est' * c) ./ sqrt(v);

	%save glm.mat beta_est var_est

	% For testing only.  Change this when you are done !!!
	%t = beta_est' * c;
	%t = v;
	%t = RSS;

return
