function aslsub_fsl(root, navg, first, last, skip,  iscomplex)
%function aslsub_fsl(root,navg,first, last, skip, [,iscomplex])
%
% Do all subtractions for a series of AST images 
% Assumes the files are AST pairs, wher the the control is the first image 
% and all others are tags of different duration
%
% root -  a single 4D file with the ASL time series
% navg - number of averages per point
% first - first image to be used in the averages
% last  - last image to use in the averages
% skip - number of frame pairs to skip in the subtraction (redundant) 
% iscomplex - indicate whether these are complex images
%
% note: (last-first)/2 must be a multiple of navg.
%
% this version returns the raw difference

str = sprintf('%s.hdr',root);
fprintf('\nReading RAW image...%s', str);
h=read_hdr(str)
str = sprintf('%s.img',root);
raw = read_img(h, str);
total=2*navg;
incount=1;
outcount=1;
c=[];
t=[];
out=[];

iscomplex=0;
if nargin==4
    iscomplex=1;
end
    

for incount = first :2: last-1
    
    % read the control ...
    
    fprintf('\nTAGGED image ...%d', incount);
    c = [c ; raw(incount,:)];
    
    % read the tag...
    
    fprintf('\nCONTROL image ...%d', incount+1);
    t = [t; raw(incount+1 , :) ];
    
end
% do the subtraction (% units)
s = (c -t);
whos s c t
for count = 1 : navg: size(s,1) 
    % do the averaging:
    fprintf('\nAveraging %d to %d ...', count+skip, count+navg-1);
    tmp = mean(s(count+skip : count+navg-1 , :), 1);
    out = [out; tmp];
     
    
end
h.tdim = size(out,1);
str=sprintf('s%s.hdr',root);
write_hdr(str,h);
str=sprintf('s%s.img',root);
fprintf('Writing ... %s ... ', str);
write_img(str,out,h);
fprintf('\n.....Done\n');

return
