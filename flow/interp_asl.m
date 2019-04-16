function interp_asl( rootname, doMask )
%function interp_asl( rootname ,doMask )
%
% this function does the ASL suntraction after interpolation of the 
% data.  It uses the 4D Analyze format.
% it ignores the slice timing gaps.


hnames = dir(sprintf('%s*.hdr',rootname));
h = read_hdr(hnames(1).name);
r = read_img_series(rootname);

control2=zeros(size(r));
tag2 = control2;

NPIX=h.xdim*h.ydim*h.zdim;
if doMask
    mask = r(1,:);
    threshold = 0.2*max(mask);
    mask(find(mask < threshold))=0;
    mask(find(mask >= threshold))=1;


    h2=h;
    h2.tdim=1;
    write_hdr('mask.hdr' ,h2);
    write_img('mask.img', mask,h2);
end

t = 1:size(r,1);

fprintf('\n splitting the data into control and tag channels...');

tag =  r(1:2:end,:)  ;
t1 = 1:2:size(r,1);


control = r(2:2:end,:); 
t2 = 2:2:size(r,1);

fprintf('\n doing the sinc interpolation...')
if doMask==1
    for pix = 1:NPIX
        if  mask(pix)>0
            tag2(:,pix) = (interp1(t1, tag(:,pix) , t,'sinc', 'extrap'))';
            control2(:,pix) = (interp1(t2, control(:,pix), t ,'sinc', 'extrap'))';
        else
            tag2(:,pix) = 0;
            control2(:,pix) = 0;

        end
    end
else
    for pix = 1:NPIX
        tag2(:,pix) = (interp1(t1, tag(:,pix) , t,'sinc', 'extrap'))';
        control2(:,pix) = (interp1(t2, control(:,pix), t ,'sinc', 'extrap'))';
    end

end
fprintf('\n subtracting the channels ...')
h2=h;
d = abs(control2-tag2);
md = mean(d,1);
write_hdr('mean_interpsub.hdr' ,h2);
write_img('mean_interpsub.img', md*100,h2);
md = mean(d,2);
save mean_subreg.dat md -ascii

h2.tdim = size(d,1);
fprintf('\n writing the output to interpsub.img', rootname)
write_hdr('interpsub.hdr' ,h2);
write_img('interpsub.img', d*100,h2);

% write_hdr(sprintf('c_%s.hdr',rootname) ,h2);
% write_img(sprintf('c_%s.img',rootname), control2,h2);
% write_hdr(sprintf('t_%s.hdr',rootname) ,h2);
% write_img(sprintf('t_%s.img',rootname), tag2,h2);

return
