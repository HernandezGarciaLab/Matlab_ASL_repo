clear all
h=read_hdr('perf001.hdr');
c = read_img2(h,'perf001.img');
curve = [];
for count=1:11
	str=sprintf('perf%03d.img',count)
	t=read_img2(h,str);
	p=t-c;
	%curve = [curve; mean(mean(mean(p(28:36,28:36,1:end)))) ]
	curve = [curve p(20,35,5)]
	subplot 211,show(p(:,:,5));
	subplot 212,show(t(:,:,5));
	pause
end

