function [BIC]=vector_AR_BIC(A,B,max_r);
% -----------------------------------
% Usage: [alpha,Omega]=vector_AR_BIC(A,B,r);
% -----------------------------------
% Estimates a vector autoregressive model
% and computes model order according to BIC
% -----------------------------------
% Inputs:   A,B:       Tx1 time series  
%         max_r:       maximal order for BIC
% -----------------------------------
% Output:     r:       Optimal BIC order
% ----------------------------------
% Magnus Orn Ulfarsson, 2007.
% -----------------------------------
T=length(A);
for r=1:max_r,
    x=[A(r+1:end)'; B(r+1:end)'];
    Z=zeros(1+2*r,T-r);
    Z(1,:)=ones(1,T-r);
    for i=1:r,
        Z(2*i:2*i+1,:)=[A(r-i+1:end-i)'; B(r-i+1:end-i)'];
    end
    beta_hat = x*Z'*inv(Z*Z');
    RSP = (x - beta_hat*Z)*(x-beta_hat*Z)';
    Omega=RSP/(T-r);
    l=svd(Omega);
    BIC(r)=sum(log(l))+4*r*log(T)/T;
end
figure(1)
plot(BIC),
[g,r]=min(BIC);

    





