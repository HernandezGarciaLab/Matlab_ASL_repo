function gscaler(root)

h = read_hdr(sprintf('%s.hdr',root));
in = read_img(h, sprintf('%s.img', root));
out=in;

for t=1:h.tdim

    tmp = in(find(~isnan(in(t,:))));
    out(t,:) = 100* in(t,:)/mean(tmp);
end

write_hdr(sprintf('g_%s.hdr', root), h)
write_img(sprintf('g_%s.img', root), out, h);

return
    
    