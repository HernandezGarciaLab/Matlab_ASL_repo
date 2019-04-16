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

	%beta_est = (pinv(x'*x))*x'*y;
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