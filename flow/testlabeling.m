function aslsub(root)
%function aslsub(root,navg,first, last, skip_Npairs, order [,iscomplex])
%
% Do all subtractions for a series of AST images 
% Assumes the files are AST pairs, wher the the control is the first image 
% and all others are tags of different duration
%
% root - rootname of the files
% navg - number of averages per point
% first - first image to be used in the averages
% last  - last image to use in the averages
% skip - number of frame pairs to skip in the subtraction (redundant)
% order - 0 --> odd-even ,   1-->(even-odd)
% iscomplex - indicate whether these are complex images
%
% note: (last-first)/2 must be a multiple of navg.
%
% this version returns the raw difference


warning off
root = 'vol'
navg = 8
first = 1
last = 16
skip = 0
order = 1
iscomplex = 0

addpath /home/fmrilab/asl_estro/abuseme/scripts/

%str = sprintf('%s%04d.hdr',root, first);
%h=read_hdr(str);
total=2*navg;
incount=1;
outcount=1;


if ~isempty(dir([root '*.nii*']))
    [raw, h] = read_nii_img(root);
    h = nii2avw_hdr(h);
else
    [raw, h] = read_img_series(root);
end
% complex subtraction is not implemented here yet
if nargin==5
    iscomplex=0;
end
if nargin==4
    order=1;
end
if iscomplex
    fprintf('\nBuilding Complex images\n');
    if ~isempty(dir(['p_' root '*.nii*']))
        [praw, h] = read_nii_img(['p_' root]);
        h = nii2avw_hdr(h);
    else
        [praw, h] = read_img_series(['p_' root]);
        raw = raw.* exp(-i .* praw/1000);
    end
end
c = raw(first:2:last , :);
t = raw(first+1:2:last , :);


% do the subtraction 

if order==0
    tmp = t;
    t = c;
    c = tmp;
end

s = c-t;
whos raw s c t
Noutframes =(last-first+1)/(2*navg);
 
out = zeros(Noutframes, h.xdim*h.ydim*h.zdim);
c_out = out;
t_out = out;
index=1;
for count = skip+1 : navg: size(s,1)-navg+1 ;
% do the averaging:
    fprintf('\nAveraging pairs %d to %d ...', count, count+navg-1);
    out(index,:) =   mean(s(count : count+navg-1 , :), 1);
    c_out(index,:) = mean(c(count : count+navg-1 , :), 1);
    t_out(index,:) = mean(t(count : count+navg-1 , :), 1);
    index = index+1;

end
h.tdim = size(out,1);
write_img('tagged.img',abs(t_out),h);
write_img('control.img',abs(c_out),h);
if iscomplex
	write_img('sub.img',abs(out),h);
	write_img('p_sub.img',1000*angle(out),h);
else
	write_img('sub.img',out,h);
end

globalmean = mean(out,2);
save subglobalmean.txt globalmean -ascii

h.tdim = 1;

ms = mean(s,1);
mc = mean(c,1);
mt = mean(t,1);
if iscomplex
	write_img('mean_sub.img',abs(ms),h);
	write_img('mean_con.img',abs(mc),h);
	write_img('mean_tag.img',abs(mt),h);
	write_img('p_mean_sub.img',1000*angle(ms),h);
	write_img('p_mean_con.img',1000*angle(mc),h);
	write_img('p_mean_tag.img',1000*angle(mt),h);
else
	write_img('mean_sub.img',ms,h);
	write_img('mean_con.img',mc,h);
	write_img('mean_tag.img',mt,h);
end
%write_hdr('mean_sub.hdr',h);
%write_hdr('mean_con.hdr',h);
%write_hdr('mean_tag.hdr',h);
    
fprintf('\n.....Done\n');
clear c t s

%return

%function [im, h]= lightbox(root, wscale, rows)
%function im = lightbox(root, [wscale],[ rows])
%
%   (c) 2005 Luis Hernandez-Garcia 
%   University of Michigan
%   report bugs to:  hernan@umich.edu
%  
% This program displays the slices in a 3D data set OR a time series
% root :  either the name of a file in a time series (could be asingle file)
% 	or could also be a 3D matrix that you want to display in slices
%	the program checks to see if it's a string or a matrix...
% wscale: window scale factor for display
% rows: number of rows of slices in the lightbox
%%This part runs the customized lightbox function

root = 'sub'
wscale =[-10 100]
rows = 3

if isstr(root)
	[im,h] = read_img(root);
	if isfield(h,'magic')
		h=nii2avw_hdr(h);
	end
        if h.tdim==1
		im = reshape(im,h.xdim, h.ydim, h.zdim);
	else
		fprintf('\n\nThis is a time series.  Cannot lightbox it');
		return
	end 
else
	im = root;
	h.xdim=size(im,1);
	h.ydim=size(im,2);
	h.zdim=size(im,3);

end

if nargin==1
	rows=[];
	wscale=[];
end
if isempty(rows)
	rows = floor(sqrt(h.zdim)) +1;
end
M=[];
cols=ceil(h.zdim/rows);

for r=1:rows
    Mrow = [];
    
    for c=1:cols
        sl = c + cols*(r-1);
        if sl<=h.zdim
            Mrow = [Mrow  im(:,:,sl)'];
        else
            Mrow = [Mrow  zeros(h.xdim, h.ydim)];
        end
        
    end   
    M = [M ; Mrow];
end
himg=figure(100);

if ~isempty(wscale)
    show(M, wscale)
else
    show(M)
end

xlabel('Time Points')
ylabel('slices')
grid off

saveas(himg,'asl.jpg')
return
warning on
pause


