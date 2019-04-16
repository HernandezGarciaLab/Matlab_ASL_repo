function block_sub( rootname, on_scans )
%function block_sub( rootname, on_scans )

h = read_hdr(sprintf('%s.hdr', rootname));
r = read_img(h, sprintf('%s.img', rootname));

ON=zeros(1,size(r,2));
OFF=ON;
n0=0;
n1=0;

fprintf('\n')
for count=1:h.tdim
    if find(on_scans==count)
	fprintf('\n Adding scan %d to the ON ...',count)
        ON = ON + r(count,:);
	n1=n1+1;
    else
	fprintf('\n Adding scan %d to the OFF ...',count)
        OFF = OFF + r(count,:);
	n0=n0+1;
    end
end
fprintf('\n')

d = ON/n1 - OFF/n0;

h2=h;
h2.tdim = 1;

write_hdr(sprintf('b_%s.hdr',rootname),h2);
write_img(sprintf('b_%s.img',rootname), d, h2);

return
