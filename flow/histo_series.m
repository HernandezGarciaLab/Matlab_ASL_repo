function avg = histo_series(root, maskroot, threshold)
% function histo_series(root, maskroot, threshold)
%
% display histograms of a time series after masking
% (intended for doing transit times)
% 6/19/04
%

hnames = dir(sprintf('%s*.hdr',root));
inames = dir(sprintf('%s*.img',root));

M = [];
if ~isempty(maskroot)
	h = read_hdr(sprintf('%s.hdr', maskroot));
	m = read_img_data(h,sprintf('%s.img', maskroot));
	m(find(m<threshold))=0;
	m(find(m>=threshold))=1;
else
	m=1;
end

avg=[];
figure
for count=1:size(hnames,1)
    h=read_hdr(hnames(count).name);
    im = read_img_data(h,inames(count).name);
    if size(m)==size(im)
	im = im.* m;
    end
    avg=[avg ; mean(im(find(im)))];
    subplot(size(hnames,1) ,1,count)
    hist(im,50)
    axis([-100 100 0 2000])
end
figure
plot(avg)
grid on

return
