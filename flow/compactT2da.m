% Created by Daniel Rowe
% Compute complex activation statistics
% Ycomp     = complex Y data n by p
% X         = design matrix nx(q+1) magnitude & phase
% C         = contrast matrix r1x(q+1) magnitude and phase
% This is for Rowe 2005 d vs a
% Implementation of Lee et al. MRM
% [fstatda,BhatT2,sigmahat] = compactT2da(Ycomp,X);

function [fstatda,BhatT2,sigmahat] = compactT2da(Ycomp,X,C);

[n,p]=size(Ycomp);
%sizeX=size(X); %C=[zeros(1,sizeX(1,2)-1),1];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Hotellings Complex Mag/Phase Activation %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
W = inv(X'*X);
invCWCt=inv(C*W*C');
%H=eye(n)-X*W*X';
BhatT2 = W*X'*Ycomp;
sigmahat = zeros(p,1);
fstatda=zeros(p,1);

for count=1:p
    %sigmahat(count,1)=(real(Ycomp(:,count))'*H*real(Ycomp(:,count))+imag(Ycomp(:,count))'*H*imag(Ycomp(:,count)))/2/(n-sizeX(1,2));
    % use MLE
    %sigmahat(count,1)=(real(Ycomp(:,count))'*H*real(Ycomp(:,count))+imag(Ycomp(:,count))'*H*imag(Ycomp(:,count)))/2/n;
    sigmahat(count,1) = ...
        (Ycomp(:,count)-X*BhatT2(:,count))'*...
        (Ycomp(:,count)-X*BhatT2(:,count))/(2*n); % ' does Hermetian
    
    if sigmahat(count,1)~=0
        fstatda(count,1) = ...
            C*[real(BhatT2(:,count)),imag(BhatT2(:,count))] ...
            *invCWCt ...
            *[real(BhatT2(:,count)),imag(BhatT2(:,count))]'*C'...
            /sigmahat(count,1);
    end
end

fstatda=(n-2)/(2*n-2)*fstatda;
