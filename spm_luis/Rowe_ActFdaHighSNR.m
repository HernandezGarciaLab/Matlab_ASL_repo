% Created by Daniel Rowe so includeme please!
% Large SNR approximation Mag and Phase Act of 
% Rowe, D.B.:  Modeling both the magnitude and phase of 
% complex-valued fMRI data. NeuroImage 25(4):1310-1324, 2005.
% but still cite above.
% Under H0 this produces an F stat with 2r and 2n-2(q+1) df
% where q+1 is the number of columns in X
% and r is the number of rows in C
% Don't forget this is only for LARGE SNR!

function [FdaSNR,BhatFdaSNR,GammahatFdaSNR,sigma2hatFdaSNR] = Rowe_ActFdaHighSNR(Ycomp,X,C);

[n,p]=size(Ycomp); q=size(X,2)-1;, df=2*n-2*(q+1);
CC=[[C,zeros(size(C,1),size(C,2))];[zeros(size(C,1),size(C,2))],C];
[r]=size(CC,1);
BhatFdaSNR=zeros(q+1,p);, GammahatFdaSNR=zeros(q+1,p);
sigma2hatFdaSNR=zeros(p,1);, FdaSNR=zeros(p,1);
demeanphase=1;
if (demeanphase==1)
    phibar=zeros(1,p);
    if(abs(Ycomp(1,1))~=0)
        phibar=angle(sum(Ycomp./abs(Ycomp)));
    else
        for count=1:p
            if abs(Ycomp(:,count))~=0
                phibar(1,count)=angle(sum(Ycomp(:,count)./abs(Ycomp(:,count))));
            end
        end
    end
    Ycomp=Ycomp.*kron(ones(n,1),exp(-i*phibar));
end
Y=abs(Ycomp);, Yphi=angle(Ycomp);
clear Ycomp
W=inv(X'*X);, BhatFdaSNR=W*X'*Y;,
for count=1:p
    if Y(1,count)~=0;
        GammahatFdaSNR(:,count)=inv(X'*diag(Y(:,count).^2)*X)*X'*diag(Y(:,count).^2)*Yphi(:,count);
        sigma2hatFdaSNR(count,1)=(Y(:,count)-X*BhatFdaSNR(:,count))'*(Y(:,count)-X*BhatFdaSNR(:,count))+(Yphi(:,count)-X*GammahatFdaSNR(:,count))'*diag(Y(:,count).^2)*(Yphi(:,count)-X*GammahatFdaSNR(:,count));
        FdaSNR(count,1)=(CC*[BhatFdaSNR(:,count);GammahatFdaSNR(:,count)] )'*inv(CC*[W,zeros(q+1,q+1);zeros(q+1,q+1),inv(X'*diag(Y(:,count).^2)*X)]*CC')* ( CC*[BhatFdaSNR(:,count);GammahatFdaSNR(:,count)] )/sigma2hatFdaSNR(count,1);
    end
end
FdaSNR=FdaSNR*df/r;
if (demeanphase==1)
    GammahatFdaSNR(1,:)=angle(exp(i*GammahatFdaSNR(1,:)).*exp(i*phibar));
end
sigma2hatFdaSNR=sigma2hatFdaSNR/df;

