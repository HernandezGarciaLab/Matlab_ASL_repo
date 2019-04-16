function aslsub(root, navg, first, last, skip, order, iscomplex)
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
% order - 0 --> tag,control,... ,   1--> control,tag,...
% iscomplex - indicate whether these are complex images
%
% note: (last-first)/2 must be a multiple of navg.
%
% this version returns the raw difference

warning off
%str = sprintf('%s%04d.hdr',root, first);
%h=read_hdr(str);
total=2*navg;
incount=1;
outcount=1;
%iscomplex = 0;
nargin
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
    end
    tmp = zeros(size(praw));
    for v=1:size(praw,2)
        tmp(:,v) = mydetrend( praw(:,v),0);
    end
    fprintf('\nDetrending Phase Data');
    raw = raw.* exp(-i .* tmp/1000);
end

% splitting data into control and tagged channels:
c = raw(first:2:last , :);
t = raw(first+1:2:last , :);

% swapping order of acquisition if necessary
if order==0
    tmp = t;
    t = c;
    c = tmp;
end

% do the  pairwise subtraction 
s = c-t;

% allocate space for output
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

% write our the intermediate files
h.tdim = size(out,1);
write_img('tagged.img',abs(t),h);
write_img('control.img',abs(c),h);

if iscomplex
    % write out intermediate files
    write_img('p_tagged.img',1000*angle(t_out),h);
	write_img('p_control.img',1000*angle(c_out),h);
	
    % subtraction images:  magnitude and phase of the subtraction
	write_img('sub.img',abs(out),h);
	write_img('p_sub.img',1000*angle(out),h);

    % compute pairwise phase differences
    outp = angle(c_out) - angle(t_out);
    write_img('pd_sub.img',1000*outp,h);
	
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
    % compute the mean absolute change in phase between control and tag for
    % each pair of images
    ms2 = mean(outp,1);
    write_img('p_mean_sub2.img', 1000 * ms2 , h);
    
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
warning on
return
