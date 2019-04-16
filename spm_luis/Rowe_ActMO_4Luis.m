% Created and Copyright by Daniel B. Rowe
% Compute t,f, and chi2 statistics for magnitude-only activation
% Y      = n by p data
% X      = design matrix n by (q+1)
% C      = r by (q+1) contrast matrix
% Bhat   = (q+1) by p coefficient matrix
% sigma2hat = p vector of unbiased variances
% tStats  = t statistics with n-q-1 df
% fStats  = F statistics with r and n-q-1 df
% Useage is
% [Bhat,sigma2hat,tStats,fStats] = Rowe_ActMO(Y,X,C);
function [Bhat,sigma2hat,tStats,fStats,cStats] = Rowe_ActMO(Y,X,C);

%%% individual univariate Regression Significance i.e. t-statistics
%Y=XB+E
[n,p] = size(Y); 
[qq] = size(X,2);
q = qq-1;
df = n-q-1;

Bhat = zeros(qq,p);
sigma2hat = zeros(p,1); 
tStats = zeros(p,1);
fStats=zeros(p,1);
[r]=size(C,1);

W=inv(X'*X);
Bhat=W*X'*Y;
M=C'*inv(C*W*C')*C;

if (r==1)
   for j=1:p
      sigma2hat(j,1) = (Y(:,j)-X*Bhat(:,j))'*(Y(:,j)-X*Bhat(:,j)) / df;
      if sigma2hat(j,1)~=0;
         tStats(j,1) = (C*Bhat(:,j) )/sqrt(sigma2hat(j,1)*C*W*C');
      end
   end
   fStats=tStats.^2;
   
elseif(r>=2)
   for j=1:p
      sigma2hat(j,1) = (Y(:,j)-X*Bhat(:,j))'*(Y(:,j)-X*Bhat(:,j)) / df;
      % can't do t-stats for r>1!
      fStats(j,1) = (Bhat(:,j)'*M*Bhat(:,j) / r) / sigma2hat(j,1));
   end
end

cStats = n*log(1+r/df.*fStats);