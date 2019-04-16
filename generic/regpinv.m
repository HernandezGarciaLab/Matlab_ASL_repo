function px = regpinv(x, r)
% function px = regpinv(x, r)
% This function returns the regularized pseudo inversed of X
% with the regularization factor r
% specifically

px = inv(x'*x + r*eye(size(x,2)))*x';

% replace NaN's with zeros
px(isnan(px)) = 0;

return
