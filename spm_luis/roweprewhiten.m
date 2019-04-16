function [Yast,Xast,estrho] = rowepw(Y,X);
% function [Yast,Xast,estrho] = rowepw(Y,X);
%
% Created by Daniel Rowe For Luis Hernandez-Garcia
% Prewhiten for AR(1) noise
% Y      = n by p data
% X      = design matrix n by (q+1)
% Yast is new data
% Xast is new design matrix
% estrhoimg is image of AR(1) corr parameters
% Useage is
% [Yast,Xast,estrhoimg] = rowepw(Y,X);

tm = clock;
%%% individual univariate Regression Significance i.e. t-statistics
%Y=XB+E
[n,p]=size(Y);
[n,qq]=size(X);,
q=qq-1;,
%xydim=sqrt(p);
resid=(eye(n)-X*inv(X'*X)*X')*Y; % Compute residuals
%resdind=resid;               % if need to keep residuals

% Autocorrelation statistics %%%%%%%%%%%%%%%%%%%%%%%%
dwstat=zeros(p,1);
%dwimg=zeros(xydim,xydim);
estrho=zeros(p,1);
for count2=1:p
    temp1=0;
    temp2=0;
    for count1=1:n
        if (count1>1)
            temp1=temp1+(resid(count1,count2)*resid(count1-1,count2)); % lag i,i-1 Prod
        end
        temp2=temp2+(resid(count1,count2))^2;                      % lag 0 SumSq
    end%
    if temp2~=0% in case variance is zero!
        estrho(count2,1)=temp1/temp2;
    end
    dwstat(count2,1)=2*(1-estrho(count2,1)); % large sample approximation
end
%dwimg=reshape(dwstat,xydim,xydim);
%estrhoimg=reshape(estrho,xydim,xydim); % make image of rhos

P=eye(n);
for count=1:p
    P(1,1)=sqrt(1-estrho(count,1)^2);
    for count2=1:n%%
        for count1=1:n%
            if (count1-count2==1)
                P(count1,count2)=-estrho(count,1);
            end
        end%
    end%%
end

Yast=zeros(n,p);, Xast=zeros(n,q+1);
Yast=P*Y;
Xast=P*X;
thetime=etime(clock,tm)
%keyboard