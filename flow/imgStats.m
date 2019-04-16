function imgStats(root)
% ! gsp21a -A P*
% ! avwmerge -t raw vol*.img
% ! rm vol*.img vol*.hdr
% imgStats('raw');

[raw, h] = read_img_series(root);
mraw = mean(raw,1);
sraw = std(raw,[],1);
maxmin = [max(mraw) min(mraw)]
hist(mraw(:));

h.tdim = 1;
write_img('mean.img',mraw,h);
write_img('stddev.img',sraw,h);

fprintf('\n.....Done\n');


return
