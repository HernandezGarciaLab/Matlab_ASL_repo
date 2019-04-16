function slices(root, wscale)
hnames = dir(sprintf('%s*.hdr',root));
inames = dir(sprintf('%s*.img',root));

M = [];

for count=1:size(hnames,1)
    fprintf('\nReading %s',hnames(count).name)
    h=read_hdr(hnames(count).name);
    im = read_img_data(h,inames(count).name);
    im=reshape(im ,h.xdim,  h.ydim*h.zdim);
    M = [M im'];
end

if nargin==2
	show(M, wscale)
else
	show(M)
end

xlabel('Time Points')
ylabel('slices')
