function result = whiten(data, DesMat, rho, w)
% function result = whiten(data, DesMat, rho,w)
%
% % first remove the known effects from the data
% [t, beta_est, vBeta] = myLinReg(DesMat,data,1);
% residual = data - DesMat*beta_est;
% 
% % Get the covariance of the residual and invert it
% Get the covariance of the residual and invert it
% V = cov(residual);
% %W = pinv(V^1/2);
% %W = WKfun('mkW',[],V);
% W = WKfun('AR+WN',rho,w,length(data)) * V ;
% 
% % Apply the whitening matrix
% result = W*data;


nrg0 = sum(abs(data));

% first remove the known effects from the data
c = ones(1,size(DesMat,2));
[t, beta_est, vBeta] = myLinReg(DesMat,data,c);
residual = data - DesMat*beta_est;

% Get the covariance of the residual and invert it
V = cov(residual);
%W = pinv(V^1/2);
%W = WKfun('mkW',[],V);
W = WKfun('AR+WN',rho,w,length(data)) * V ;

% Apply the whitening matrix
result = W*data;
nrg2 = sum(abs(result));
result = result*nrg0/nrg2;

return
