function aslsub_sur(root, first, last,iscomplex, order)
% function aslsub_sur(root, first, last,iscomplex, order)
%
% Do all subtractions for a series of AST images
% using surround subtraction .  The kernel is [ -1 2 1 ] 
% if the input is N points long, the output is N-2 long
% 
% Assumes the files are AST pairs, wher the the control is the first image 
% and all others are tags of different duration
%
% root - rootname of the files
% first - first image to be used in the averages
% last  - last image to use in the averages
% iscomplex - indicate whether these are complex images
% order  - if set to 1, multiplies the output by -1, in case 
%			the tag-control order is reversed
%
% note: (last-first)/2 must be a multiple of navg.
%
% this version returns the raw difference

warning off
%str = sprintf('%s%04d.hdr',root, first);
%h=read_hdr(str);
incount=1;
outcount=1;
%iscomplex = 0;

if ~isempty(dir([root '*.nii*']))
    [raw, h] = read_nii_img([root '.nii']);
    h = nii2avw_hdr(h);

elseif ~isempty(dir([root '*.img']))
    [raw, h] = read_img([root '.img']);

else
    [raw, h] = read_img_series(root);
end

if iscomplex
    fprintf('\nBuilding Complex images\n');
    
    if ~isempty(dir(['p_' root '*.nii*']))
        [praw, h] = read_nii_img(['p_' root '.nii']);
        h = nii2avw_hdr(h);
        
    elseif ~isempty(dir(['p_' root '*.img']))
        [raw, h] = read_img([root '.img']);
    
    else
        [praw, h] = read_img_series(['p_' root]);
        raw = raw.* exp(-i .* praw/1000);
    end
end

raw = raw(first:last, :);

tlen = size(raw,1);
D4 = zeros(tlen-2,tlen);
for count=1:tlen-2
    D4(count,count)=(-1)^(count-1);
    D4(count,count+1)=2*(-1)^(count);
    D4(count,count+2)=(-1)^(count-1);
end

% do the subtraction 
s = D4 * raw /2;

if order==0
	s = -1*s;
end

whos raw s c t
Noutframes = tlen-2;
 
out = zeros(Noutframes, h.xdim*h.ydim*h.zdim);
h.tdim = Noutframes;
if iscomplex
	write_img('sub.img',abs(s),h);
	write_img('p_sub.img',1000*angle(s),h);
else
	write_img('sub.img', s ,h);
end

globalmean = mean(s,2);
save subglobalmean.txt globalmean -ascii
save SurSubMat D4

cons = raw(1:2:end,:);
tags = raw(2:2:end,:);

h.tdim=size(cons,1);
write_img('tagged.img',tags,h);
write_img('control.img',cons,h);

h.tdim = 1;
mc = mean(cons,1);
mt = mean(tags,1);
ms = mean(s,1);
if iscomplex
	write_img('mean_sub.img',abs(ms),h);
	write_img('p_mean_sub.img',1000*angle(ms),h);
	write_img('mean_con.img',abs(mc),h);
	write_img('p_mean_con.img',1000*angle(mc),h);
	write_img('mean_tag.img',abs(mt),h);
	write_img('p_mean_tag.img',1000*angle(mt),h);
else
	write_img('mean_sub.img',ms,h);
	write_img('mean_con.img',mc,h);
	write_img('mean_tag.img',mt,h);
end
    
fprintf('\n.....Done\n');
clear c t s
warning on
return
