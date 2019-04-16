function [mymap, D]= act_lightbox(root1, root2, wscale1, wscale2, rows)
%function [mymap, D]= act_lightbox(root1, root2, wscale1, wscale 2, rows)
%
%   (c) 2005 Luis Hernandez-Garcia
%   University of Michigan
%   report bugs to:  hernan@umich.edu
%
% This program displays the slices with superimposed activation maps
% root1 :  either the name of a file for the underlay image
% 	or could also be a 3D matrix that you want to display in slices
%	the program checks to see if it's a string or a matrix...
% root2:  same thing for the overlay statistical map.
% wscale1: window scale factor for display of the underlay
% wscale2: window scale factor for display of the color overlay
% rows: number of rows of slices in the lightbox
%
% the function returns the colormap of the overlay and the composite data

doColorBars=1;
global RT_MODE
RT_MODE = 0;

% read in the underlay.  This is im1
if isstr(root1)
	[im,h] = read_img(root1);
	if isfield(h,'magic')
		h=nii2avw_hdr(h);
	end
	if h.tdim==1
		im1 = reshape(im,h.xdim, h.ydim, h.zdim);
	else
		fprintf('\n\nThis is a time series.  Cannot lightbox it');
		return
	end
else
	im1 = root1;
	h.xdim=size(im1,1);
	h.ydim=size(im1,2);
	h.zdim=size(im1,3);

end

% read in the activation map.  This is im2
if isstr(root2)
	[im2,h] = read_img(root2);
	if isfield(h,'magic')
		h=nii2avw_hdr(h);
	end
	if h.tdim==1
		im2 = reshape(im2,h.xdim, h.ydim, h.zdim);
	else
		fprintf('\n\nThis is a time series.  Cannot lightbox it');
		return
	end
else
	im2 = root2;
	h.xdim=size(im2,1);
	h.ydim=size(im2,2);
	h.zdim=size(im2,3);

end

if nargin==2
	rows=[];
	wscale1=[];

	wscale2=[];
end

if isempty(rows)
	rows = floor(sqrt(h.zdim));
end
cols=ceil(h.zdim/rows);


% scale the underlay to match up the window level.  we create a mask
% that blocks out any thing below the lower limit of the window
imask = zeros(size(im1));
imask(abs(im1)>wscale1(1)) = 1;

% same thing is done with the positive activation map
smask = zeros(size(im2));
smask(im2>wscale2(1)) = 1;

% ditto for the negative values of the negative activations
nmask = zeros(size(im2));
nmask(im2 < -wscale2(1)) = 1;

% create a negative activation map from the raw activation map
nim2 = -im2; % neg. activations

% scale the three images by the specified window levels
% anything above the upper end, gets mapped out to the highest intensity
% anything below the lower end, gets mapped out to zero
im1 = (im1 - wscale1(1))*255 / (wscale1(2) - wscale1(1));
im1(im1>255) = 255;
im1(im1<1) = 1;

im2 = (im2 - wscale2(1))*255 / (wscale2(2) - wscale2(1));
im2(im2>255) = 255;
im2(im2<1) = 1;

nim2 = (nim2 - wscale2(1))*255 / (wscale2(2) - wscale2(1));
nim2(nim2>255) = 255;
nim2(nim2<1) = 1;

% make the overlay image by adding the images together plus an offset:
D = im1.*imask.*(~smask).*(~nmask) + ...
    smask.*(256 + im2) + ...
    nmask.*(512 + nim2);


M1=[];


for r=1:rows
	Mrow = [];

	for c=1:cols
		sl = c + cols*(r-1);
		if sl<=h.zdim
			Mrow = [Mrow  D(:,:,sl)'];
		else
			Mrow = [Mrow  zeros(h.ydim, h.xdim)];
		end

	end
	M1 = [M1 ; Mrow];
end

image(M1)
axis image    
axis xy

if RT_MODE~=1

    mymap = make_colormap;
    colormap(mymap);

    grid off
    axis off

end
    

    
if doColorBars
    ncbar_labels=3;
    Ncolors = 256;

    c1 = colorbar('SouthOutside');
    set(c1,'XTick',[linspace(1,Ncolors-1,ncbar_labels)  ],...
        'XTickLabel',round([linspace(wscale1(1),wscale1(2), ncbar_labels) ]), ...
        'XLim', [0 Ncolors-1],...
        'FontSize',12);

    c1 = colorbar('WestOutside');
    set(c1,'YTick',[linspace(Ncolors+1,2*Ncolors,ncbar_labels) ],...
        'YTickLabel',round([linspace(wscale2(1), wscale2(2), ncbar_labels)]), ...
        'YLim', [Ncolors+1 2*Ncolors], ...
        'FontSize',12);

    c1 = colorbar('EastOutside');
    set(c1,'YTick',[linspace(2*Ncolors+1,3*Ncolors,ncbar_labels) ],...
        'YTickLabel',round([linspace(-wscale2(1), -wscale2(2), ncbar_labels)]), ...
        'YLim', [2*Ncolors+1 3*Ncolors], ...
        'FontSize',12);
end

if isstr(root1)
	set(gcf,'Name',root1)
end

if RT_MODE
    set(gca,'Position',[0.01 0.01 0.99 0.99])
end

return

%%
function mymap = make_colormap

mygray = [0:255]' * [1 1 1];

myhot = [128.5:0.5:255]' * [1 0 0] ;
tmp =   [128.5:0.5:255]' * [0 1 0] ;
tmp(:,1) = 256;

myhot = [myhot; tmp];
tmp =   ([0:255]/2)' * [0 0 1]; 
tmp(:,1:2) = 256;
myhot =  [myhot;  tmp;];
myhot = myhot(1:3:end, :);

myblue = myhot;
myblue(:,1) = myhot(:,3);
myblue(:,3) = myhot(:,1);

mymap = [mygray; myhot; myblue]/256;

Ncolors = size(myhot,1);
% if isstr(root)
%       set(gcf, 'Name', root)
% end


return
