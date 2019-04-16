
Pfiles=dir('P*')

all = [];
for count=1:length(Pfiles)
    
    % do the recon
    testlabel3d(Pfiles(count).name);
    [s h]= read_img('mean_sub');
    all = [all ; s(:)'];

end

h.tdim = length(Pfiles);

write_img('all.img', all, h);


figure
slices02('all',[-150 150]) ;
axis image

hdr = read_hdr('all.hdr');
axis([1 hdr.xdim*hdr.tdim (hdr.zdim/2-2)*hdr.ydim (hdr.zdim/2+2)*hdr.ydim]);

