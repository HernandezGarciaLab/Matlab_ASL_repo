function aslsubd(root, navg, first, last, skip, order, iscomplex)
%function aslsubd(root,navg,first, last, skip_Npairs, [order [,iscomplex])
%
% this version detrends the data first
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
%
% complex case ...outputs:
%
% control / p_control = mag/phase of control images
% tagged / p_tagged = mag/phase of tagged images
% mean_con / p_mean_con = mag/pahse of the mean control timeseries
% sub / p_sub  = time series of magnitude/phase of the  of the pairwise vector diffs.
% mean_sub / p_mean_sub = mean of the magn/phase time course of pairwise vector diffs
% magDiff / phaseDiff = time series of pairwise diffs in magnitude/phase
% mean_phaseDiff / mean_magDiff = mean of the pairwise magnitude/phase subtractions
%


if nargin==1
    navg = 1;
    first = 1;
    last=size(raw,1);
    skip=0;
    order=0;
    if ~isempty(dir(['p_' root '*']))
        iscomplex=1;
    else
        iscomplex=0;
    end
end
warning off
%str = sprintf('%s%04d.hdr',root, first);
%h=read_hdr(str);
total=2*navg;
incount=1;
outcount=1;
%iscomplex = 0;
nargin
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

    end

    raw = raw.* exp(-i .* praw/1000);
end
if nargin==5
	iscomplex=0;
end
if nargin==4
	order=1;
end

if iscomplex

	% 5/5/08 - in the complex data, we mean center the phase of the time series
	% to reduce phase wraps.  Note that this is happening before
	% subtraction	
%     [Nframes, p] = size(raw);
% 	phibar = mean(praw,1);
% 	phibar = repmat(phibar, Nframes,1);
% 	raw = raw ./ exp(i*phibar);


% 	for j=1:p
% 		% divide comp ts by mag ts, sum each new ts, compute angle
% 		% unitvecs = raw(:,j) ./ abs(raw(:,j));
% 		% phibar(1,j) = angle( mean(unitvecs) );
% 		phibar(1,j) = angle( mean(raw(:,j)) );
% 		% divide orig ts by unit mag ts with mean angle
% 		raw(:,j) = raw(:,j) ./ exp(i*phibar(1,j));
% 	end
	fprintf('\n ... mean centered phase');
end

doDetrend=1;
if doDetrend
	fprintf('\n detrending ...');
	time=(linspace(0,1,size(raw,1)))';
	
	for p=1:size(raw,2)
		buf = raw(:,p);
		coefs = polyfit(time,buf,3);
		coefs(1) = 0;
		buf = buf-polyval(coefs, time);
		raw(:,p) = buf;
	end
	fprintf('done');
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

% allocate space for output
whos raw s c t
Noutframes =(last-first+1)/(2*navg);
out = zeros(Noutframes, h.xdim*h.ydim*h.zdim);
t2 = zeros(Noutframes, h.xdim*h.ydim*h.zdim);
c2 = zeros(Noutframes, h.xdim*h.ydim*h.zdim);


% do the averaging:
index=1;
for count = skip+1 : navg: last/2 ;

	fprintf('\nAveraging pairs %d to %d ...', count, count+navg-1);
	c2(index,:) = mean(c(count : count+navg-1 , :), 1);
	t2(index,:) = mean(t(count : count+navg-1 , :), 1);
	index = index+1;
end

% adjust the size of the buffer
c = c2;
t = t2;

% do the  pairwise subtraction
s = c-t;
% write our the intermediate files
h.tdim = size(c,1);

write_img('sub.img',abs(s),h);
write_img('tagged.img',abs(t),h);
write_img('control.img',abs(c),h);

if iscomplex
    
    % compute pairwise phase differences
    pd = angle(c) - angle(t);
    % compute pairwise magnitude differences
    md = abs(c) - abs(t);

    write_img('p_sub.img',1000*angle(s),h);
    write_img('p_tagged.img',1000*angle(t),h);
    write_img('p_control.img',1000*angle(c),h);

	write_img('phaseDiff.img',1000*pd,h);
    write_img('magDiff.img',md,h);
end

% do the grand means over time
globalmean = mean(s,2);
save subglobalmean.txt globalmean -ascii

h.tdim = 1;

ms = mean(s,1);
mc = mean(c,1);
mt = mean(t,1);

write_img('mean_sub.img',ms,h);
write_img('mean_con.img',mc,h);
write_img('mean_tag.img',mt,h);

vms = var(s,0,1);
write_img('var_sub.img', vms  , h);

if iscomplex
    h.tdim=1;
	% compute the mean absolute change in phase between control and tag for
	% each pair of images
	mpd = mean(pd,1);
	write_img('mean_phaseDiff.img', 1000 * mpd , h);

	mmd = mean(md,1);
	write_img('mean_magDiff.img', mmd , h);

	vpd = var(pd,0,1);
	write_img('var_phaseDiff.img', vpd * 1e6 , h);

	vmd = var(md,0,1);
	write_img('var_magDiff.img', vmd  , h);

	write_img('mean_sub.img',abs(ms),h);
	write_img('mean_con.img',abs(mc),h);
	write_img('mean_tag.img',abs(mt),h);
    
	write_img('p_mean_sub.img',1000*angle(ms),h);
	write_img('p_mean_con.img',1000*angle(mc),h);
	write_img('p_mean_tag.img',1000*angle(mt),h);

end


fprintf('\n.....Done\n');
clear c t s
warning on
return
