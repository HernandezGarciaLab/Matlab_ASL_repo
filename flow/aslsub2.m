function aslsub2(root, navg, first, last, skip)
%function aslsub2(root,navg,first, last, skip)
%
% Do all subtractions for a series of AST images 
% works for 4D data files only.
%
% root - rootname of the files
% navg - number of averages per point
% first - first image to be used in the averages
% last  - last image to use in the averages
% skip  - is an aditional parameter to skip pair of subtractions when averaging
%
% note: (last-first)/2 must be a multiple of navg.
%
% this version returns the raw difference
%

str = sprintf('%s.hdr',root);
h=read_hdr(str);
total=2*navg;
incount=1;
outcount=1;
c=[];
t=[];

iscomplex=0;
if nargin==4
    iscomplex=1;
end
    
raw=read_img(h , sprintf('%s.img', root));
c = raw(first:2:last, :);
t = raw(first + 1 : 2: last, :);

% do the subtraction (% units)
s = (c -t);
whos

out=[];
for count = 1 : navg: size(s,1) 
    % do the averaging:
    fprintf('\rAveraging from %d to %d', count+skip, count+navg-1);
    tmp = mean(s(count+skip : count+navg-1 , :), 1);
    out = [out; tmp];
end
h.tdim = h.tdim/(2*navg);    
str=sprintf('sub_%s.hdr', root);
write_hdr(str,h);
    
str=sprintf('sub_%s.img',root);
fprintf('\nWriting ... %s ... ', str);
    
write_img(str,out,h);
     
    
fprintf('\n.....Done\n');

return
