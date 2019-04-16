% This script will 
% filter the P files to remove RF leakage spikes
% reconstruct a turbo set of ASL images
% perform the pairwise subtraction and averaging (aslsub)
% smooth those images in space
% produce signal as a function of TR plot
% show histogram of the different TRs
%
% execute this script from a directory that contains
% all the P files...
close all
fprintf('\nExecuting  ...')
doFilter=0;
isExcite = 1;
navg=8;
skip = 2;
order = 1;

!rm vol*

if isExcite==0
    filterProg='filterraw';
    recon='gsp20a';
    fastrec=1;
    year=2004;
else
    filterProg='filterrawEX';
    recon='gsp21a';
    fastrec=0;
    year=2005;
end


str = sprintf('! gsp21a -A %s', Pstr)
eval(str)

names=dir('vol*.hdr')
root=names(1).name;
root=root(1:end-8)
    
aslsub(root,navg,1,size(names,1), skip, order)
    

% display in slices and as a time series plot
slices('sub_',[-100 100])

