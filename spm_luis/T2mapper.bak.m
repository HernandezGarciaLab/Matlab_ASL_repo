function T2mapper(rootname1 , rootname2)
% function Tmapper(rootname1, rootname2)
%
%      Luis Hernandez-Garcia at U Michigan
%      2-12-2004
%
% Tmap calculator for SPM images avoiding the mask issues in SPM99
%
% this function takes a set of images with a common rootname
% and calculates:
%
% df.img:
%    the number of available measurements at each pixel
%    (not NaN's or Infs): this is the  degrees of freedom 
%    at that pixel
% mean.img:
%     the mean of the pixels excluding NaNs and Infs
% var.img:
%     the variance of the pixels exluding NaNs and Infs
% tscore.img:
%     the t score wherever possible, taking into account the 
%     available number of measurements.  
%     If there is only one measurement, we call it a NaN.  
%     (not much of a  t-test if there is only one measurement.
% pval.img
%     the corresponding p values to the tscores using the
%     degrees of freedom calculated earlier
%
% 10lnP:  
%     this one is just -10*ln(p)  for bettern display purposes.
%
% USAGE example:  Tmapper('rfx_')
%
% (when doing RFX, it's useful to put links to the individual
% contrast images in the same directroty)
%
% warning:  it's slow! 
%

warning off

names = dir(sprintf('%s*.hdr',rootname1));
Nfiles = size(names,1);

raw1 = [];
for count=1:Nfiles
	
	h = read_hdr(names(count).name);
	str = names(count).name;
	str(length(str)-3:end) = '.img';
	fprintf('\rreading ...%s', str);
	raw1 = [raw1 ; read_img_data(h, str)];

end

names = dir(sprintf('%s*.hdr',rootname2));
Nfiles = size(names,1);
raw2 = [];
for count=1:Nfiles
	
	h = read_hdr(names(count).name);
	str = names(count).name;
	str(length(str)-3:end) = '.img';
	fprintf('\rreading ...%s', str);
	raw2 = [raw2 ; read_img_data(h, str)];

end

whos raw1
Npix = size(raw1,2);

df=zeros(Npix,1);
ave=zeros(Npix,1);
vr=zeros(Npix,1);
tscor=zeros(Npix,1);
pval=zeros(Npix,1);
%tic

for count = 1:Npix
	tmp1 = raw1(:,count);
	tmp1 = tmp1(find(~isnan(tmp1)));	
	tmp1 = tmp1(find(~isinf(tmp1)));

	tmp2 = raw2(:,count);
	tmp2 = tmp2(find(~isnan(tmp2)));	
	tmp2 = tmp2(find(~isinf(tmp2)));

	if (~isempty(tmp1) &  ~isempty(tmp2))
		n1 = length(tmp1);
		a1 = mean(tmp1);
		n2 = length(tmp2);
		a2 = mean(tmp2);
		v = var([tmp1 ; tmp2]);
		if (n1==1 | n2==1) 
			t=NaN;
			p=NaN;
		else
			t = (a1-a2)/(sqrt(v)*sqrt(1/n1 + 1/n2));
			p = 1-spm_Tcdf(t,n1 + n2 -1);
		end
	else
		n2 = NaN;
		a2 = NaN;
		n1 = NaN;
		a1 = NaN;
		v = NaN;
		t = NaN;
		p = NaN;
	end
	if (rem(count,1000)==0)
		%toc
		%tic
		fprintf('\r*-%d of %d pixels', count, Npix);
	end
	df(count) =  n1+n2-1;
	ave2(count) = a2;
	ave1(count) = a1;
	vr(count) =  v;
	tscor(count) = t;
	pval(count)  = p;
%keyboard
end


write_hdr('tscore.hdr',h);
write_img_data('tscore.img',tscor,h);

write_hdr('pval.hdr',h);
write_img_data('pval.img',pval,h);

write_hdr('10lnP.hdr',h);
write_img_data('10lnP.img',-10*log(pval),h);

write_hdr('var.hdr',h);
write_img_data('var.img',vr,h);

write_hdr('mean1.hdr',h);
write_img_data('mean1.img',ave1,h);

write_hdr('mean1.hdr',h);
write_img_data('mean2.img',ave1,h);

write_hdr('df.hdr',h);
write_img_data('df.img',df,h);


return

