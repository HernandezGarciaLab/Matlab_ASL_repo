% Created by Daniel Rowe
% Compute complex activation statistics
% Ycomp     = complex Y data n by p
% X         = design matrix nx(q+1) same for magnitude & phase
% C         = contrast matrix rx(q+1) for both magnitude and phase
% This is for Rowe 2005 d vs a complex mag&phase act
% [fstatda] = Rowe_Fda(Ycomp,X);
% fstatda is the test statistic that
% under the null hypothesis produces F stat with
% 2 numerator and 2n-2 denominator degrees of freedom

function [fstatda] = Rowe_Fda(Ycomp,X,C);

[n,p]=size(Ycomp); 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
W=inv(X'*X);, invCWCt=inv(C*W*C');, 
BhatRI=W*X'*Ycomp;
sigmahat=zeros(p,1);, fstatda=zeros(p,1);
for count=1:p
    sigma2hat(count,1)=(Ycomp(:,count)-X*BhatRI(:,count))'*(Ycomp(:,count)-X*BhatRI(:,count))/(2*n); % ' does Hermetian
    if sigma2hat(count,1)~=0
    fstatda(count,1)=C*[real(BhatRI(:,count)),imag(BhatRI(:,count))]*invCWCt*[real(BhatRI(:,count)),imag(BhatRI(:,count))]'*C'/sigma2hat(count,1);
    end
end
fstatda=(n-2)/(2*n-2)*fstatda;
