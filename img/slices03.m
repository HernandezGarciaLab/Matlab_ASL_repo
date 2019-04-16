function [M h]=slices03(root, wscale)
M = [];
    [im h] = read_img(root);

for count=1:size(im,1)

    tmp=reshape(im(count,:) ,h.xdim,  h.ydim*h.zdim);
    %M = [M abs(tmp)'];
    M = [M (tmp)'];
    
end

%M = abs(M);

if nargin==2
	imagesc(M)
    caxis(wscale)
else
	imagesc(M)
end


axis image
colormap gray(256)

xlabel('Time Points')
ylabel('slices')

colorbar