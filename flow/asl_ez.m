function asl_ez( rootname )
%function asl_ez( rootname )

h = read_hdr(sprintf('%s.hdr', rootname));
r = read_img(h, sprintf('%s.img', rootname));

d = r(2:2:end,:) - r(1:2:end,:)  ;

h2=h;
h2.tdim = size(d,1);

write_hdr(sprintf('s_%s.hdr',rootname) ,h2);
write_img(sprintf('s_%s.img',rootname), d,h2);

return
