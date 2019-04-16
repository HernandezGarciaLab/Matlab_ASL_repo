function M=slices02(root, wscale, dims)
M = [];

if (nargin <3 && ischar(root))
    [im h] = read_img(root);

    xdim = h.xdim;
    ydim = h.xdim;
    zdim = h.zdim;
    tdim = size(im,1);

else

    xdim = dims(1);
    ydim = dims(2);
    zdim = dims(3);
    tdim = dims(4);

    im = root;
end

for count=1:tdim

    tmp=reshape(im(count,:) , xdim,  ydim*zdim);
    %M = [M abs(tmp)'];
    M = [M (tmp)'];
end

if nargin>1
        show(M, wscale)
else
        show(M)
end

colormap gray(256)
axis image
xlabel('Time Points')
ylabel('slices')