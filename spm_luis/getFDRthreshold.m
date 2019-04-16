function [zID  zN] = getFDRthreshold(Zname, fdrate)
% function [zID, zN] = getFDRthreshold(Zname, fdrate)
% 
% Zname:  filename of Zmap in question
% fdrate: desired fase discovery rate (from 0 to 1)
%
% zID:  Z threshold, indep or pos. correl.
% zN :    Z threshold, no correl. assumptions
%
% this is adapted from 
% http://www.sph.umich.edu/~nichols/FDR/
%

[Zimg h]     = lightbox(Zname);


subplot(211)
lightbox(Zimg, [-3 3], 3);

Zimg(~isfinite(Zimg(:))) = [];
Zimg(~(Zimg(:))) = [];


P        = 1-cdf('norm',Zimg(:),0,1);

subplot(212)
[pID pN] = FDR(P,fdrate);

zID      = icdf('norm',1-pID,0,1)     % Z threshold, indep or pos. correl.
zN       = icdf('norm',1-pN,0,1)      % Z threshold, no correl. assumptions

return


%%
function [pID,pN] = FDR(p,q)
% FORMAT [pID,pN] = FDR(p,q)
% 
% p   - vector of p-values
% q   - False Discovery Rate level
%
% pID - p-value threshold based on independence or positive dependence
% pN  - Nonparametric p-value threshold
%______________________________________________________________________________
% $Id: FDR.m,v 1.1 2009/10/20 09:04:30 nichols Exp $


p = p(isfinite(p));  % Toss NaN's
p = p(find(p));  % toss zeros
p = sort(p(:));
V = length(p);
I = (1:V)';

cVID = 1;
cVN = sum(1./(1:V));

tmp = I/V*q/cVID;

pID = p(max(find(p<=I/V*q/cVID)));
pN = p(max(find(p<=I/V*q/cVN)));

plot(tmp,'r'); hold on; plot(p); hold off