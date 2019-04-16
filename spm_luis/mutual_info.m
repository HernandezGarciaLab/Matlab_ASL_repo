function mi = mutual_info(a , b)
% function mi = mutual_info(a , b)

% first compute a joint histogram so we can extract the different
% joint probabilities
Nbins = length(a)/10;
jointhist = jhist(a,b, Nbins);

% now compute the mutual information  
% This code is lifted from spm_mireg.m
% the definition (from Mathworkd) is 
% I(X,Y) = sum_y(sum_x(P(X,y)*log2(P(x,y)/(P(X)*P(Y))))
% so it's not exactly the same...
H  = jointhist/(sum(jointhist(:))+eps);
s1 = sum(H,1);
s2 = sum(H,2);
H  = H.*log2((H+eps)./(s2*s1+eps));
mi = sum(H(:));


