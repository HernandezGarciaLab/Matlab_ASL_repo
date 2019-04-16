%function statistic = my_glm(x,y,c)
% statistic is the resulting T score of the comparison
% x(row,column) is the design matrix
%      each column is a condition, Each row is a time point.
% c(1,column) is a vector of contrasts
%      a single row
% y(rows,1) is the vector of data
%      a single column. Each row is a time point.
% Luis Hernandez code. 
%
%	statistic.t        = t;
%	statistic.beta_est = beta_est;
%	statistic.var_est  = var_est;
%	statistic.cov_beta = cov_beta;
%
% modified by RCWelsh a little.
%
% 
%
function [statistic] = my_glm(x,y,c)

	x = [ones(size(x,1) , 1)  x];
	c = [0 c];
	
	p = size(x,2);
	n = size(x,1);

	xtx_inv = pinv(x);
	beta_est = xtx_inv*y;

	RSS = y - x*beta_est;
	RSS = sum(RSS.^2);

	var_est = RSS/(n-p);
	cov_beta = var_est * xtx_inv;

	% ---- %

%	v = var_est*(c' * xtx_inv * c);
%	t = (beta_est' * c) ./ sqrt(v);
%	v = var_est*(c * xtx_inv * c');

    V = var(y);
    v = c*xtx_inv * V * xtx_inv'*c';

    t = (beta_est' * c') ./ sqrt(v);

	statistic.t        = t;
	statistic.beta_est = beta_est;
	statistic.var_est  = v;
	statistic.cov_beta = cov_beta;
	
	%save glm.mat 

	% For testing only.  Change this when you are done !!!
	%t = beta_est' * c;
	%t = v;
	%t = RSS;

return
