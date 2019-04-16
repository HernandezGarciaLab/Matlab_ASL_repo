masterDir = '/data/fmri.shared/rfx/overlays';

thdr = read_hdr('/data/fmri.shared/scalpedT1.hdr');
tdata = read_img_data('/data/fmri.shared/scalpedT1.img', h);
tscale = mean(templ);
tdata = tdata*tscale;

for sub=1:Nsub

        h = read_hdr(hfiles(sub).name)
        d = read_img_data(ifiles(sub).name, h);
        dscale = mean(d);
        d = d*tscale;

        write_hdr(sprintf('err%02d.hdr',sub),h);
        write_img_data(sprintf('err%02d.img',sub), tdata - d , h);

end

