function [t, beta_est, vCon] = myLinReg(x,y,c)
%function [t, beta_est, vCon] = myLinReg(x,y,c)
%
% statistic is the resulting T score of the comparison
% x(row,column) is the design matrix
%      each column is a condition, Each row is a time point.
% c(1,column) is a matrix of contrasts
%      each row is a contrast
% y(rows,1) is the vector of data
%      a single column. Each row is a time point.
%
% this version will NOT stick an intercept into the model... Watch out.
% it handles several contrasts
%
%y=y+1000;
%x = [ones(size(y,1) , 1)  x];

% 	p = size(x,2);
% 	n = size(x,1);

t = zeros(size(c,1),1);
vCon = zeros(size(c,1),1);

xtx_inv = pinv(x);
beta_est = xtx_inv*y;

% 	RSS = y - x*beta_est;
% 	RSS = sum(RSS.^2);
%
% 	var_est = RSS/(n-p);

V = var(y);

for n=1:size(c,1)
    
    vCon(n) = c(n,:) * xtx_inv * V * xtx_inv' * c(n,:)';
    t(n) = (beta_est' * c(n,:)') ./ sqrt(vCon(n));
    
end
%    beta_est = beta_est(1:end);
return
