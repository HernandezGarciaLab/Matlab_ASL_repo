% $Id: buildgrad.m 236 2012-09-20 21:09:24Z klitinas $

spup = 3;
opfov = 40/spup;
opxres = 320/spup;
gts = 2e-6;
gslew = 150;
gamp = 4; 
nl = 8;
[g,k,t,s]=spiralgradlx3(opfov,opxres,gts,gslew,gamp,nl);
