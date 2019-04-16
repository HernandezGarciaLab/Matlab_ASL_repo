input = 'rarun_05.nii';

[raw h] = read_img(input);

spraw = raw;
for n=1:h.tdim
	fprintf('\rspatial smoothing ... %d', n);
    s = raw(n,:);
    s=reshape(s,[h.xdim, h.ydim, h.zdim]);
    s = mrfilter(s,[h.xsize, h.ysize, h.zsize]);
    spraw(n,:) = s(:)';
end

tspraw = timesmooth (spraw);

write_img('blurry.img',tspraw,h);
