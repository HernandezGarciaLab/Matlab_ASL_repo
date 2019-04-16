function avg = histo_series02(root, maskroot, threshold)
% function histo_series(root, maskroot, threshold)
%
% display histograms of a time series after masking
% (intended for doing transit times)
% 6/19/04
%

M = [];
if ~isempty(maskroot)
	[m h]= read_img(maskroot);
	m(find(m<threshold))=0;
	m(find(m>=threshold))=1;
else
	[m h]= read_img(root);
	m = m(end,:);
	m(find(abs(m)<threshold))=0;
	m(find(abs(m)>=threshold))=1;

end
lightbox(m);

m=m(:)';
avg=[];
figure
    [im h]= read_img(root);

    %im = abs(im);
    
    
for count=1:size(im,1)
	tmp = im(count,:);
	tmp = tmp.* m;
    avg=[avg ; mean(tmp(find(tmp)))];
	subplot(size(im,1) ,1,count)
    hist(tmp(find(tmp)),100);
    axis([-1050 1050 0 500])
end
figure
plot(avg)
grid on

return
