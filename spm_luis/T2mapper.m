function T2mapper(rootname1 , rootname2)
% function Tmapper(rootname1, rootname2)
%
%      (c)Luis Hernandez-Garcia at U Michigan
%      last edit: 2-7-2006
%
% two sample T test calculator for SPM images avoiding the mask issues in SPM99
% accounting for unequal variances and df.
%
% this function takes a set of images with a common rootname
% and calculates:
%
% df.img:
%    the number of available measurements at each pixel
%    (not NaN's or Infs): this is the  degrees of freedom 
%    at that pixel
% mean1.img, mean2.img:
%     the mean of the pixels excluding NaNs and Infs
% var1.img, var2.img:
%     the variance of the pixels exluding NaNs and Infs
% tscore.img:
%     the t score wherever possible, taking into account the 
%     available number of measurements.  
%     If there is only one measurement, we call it a NaN.  
%     (not much of a  t-test if there is only one measurement.
% Zscore.img:
%
% USAGE example:  Tmapper('rfx_controls_', 'rfx_patients_')
%
% (when doing RFX, it's useful to put links to the individual
% contrast images in the same directroty)
%
% warning:  it's slow in the Z score computation! 
%

%global SPM_scale_factor

warning off

names = dir(sprintf('%s*.hdr',rootname1));
h = read_hdr(names(1).name);
fprintf('\rreading ...%s', rootname1);
raw1 = read_img_series(rootname1);

fprintf('\rreading ...%s', rootname2);
raw2 = read_img_series(rootname2);

Npix = size(raw1,2);
Nimg1 = size(raw1,1);
Nimg2 = size(raw2,1);

% count the number of useful numbers at each pixel
% pop. #1
fprintf('\ncomputing mean1 ...')
tmp = zeros(size(raw1));
tmp(find(raw1)) = 1;
n1 = sum(tmp,1);
n1(find(n1==0)) = 1; % remove 0s from n1 

raw1(find(tmp==0)) = 0;
sum1 = sum(raw1,1);
mean1 = sum1./n1;

fprintf('\ncomputing and adjusting variance s1...')
maskraw1 = (raw1~=0); % a mask from raw1
m1_2D = ones(Nimg1,1)*mean1 .* maskraw1; % masked 2D mean
v1 = sum((m1_2D-raw1).^2) ./ (n1-1);
v1(find(n1==1)) = 0; 

% pop. #2
fprintf('\ncomputing mean2 ...')
tmp = zeros(size(raw2));
tmp(find(raw2))=1;
n2 = sum(tmp,1);
n2(find(n2==0)) = 1; % remove 0s from n2 

raw2(find(tmp==0))=0;
sum2 = sum(raw2,1);
mean2 = sum2./n2;

fprintf('\ncomputing and adjusting variance s2...')
maskraw2 = (raw2~=0); % a mask from raw2
m2_2D = ones(Nimg2,1)*mean2 .* maskraw2; % masked 2D mean
v2 = sum((m2_2D-raw2).^2) ./ (n2-1);
v2(find(n2==1)) = 0; 

s1 = sqrt(v1); s2 = sqrt(v2); 
s1(find(s1<1)) = 0; s2(find(s2<1)) = 0;  

% compute the statitics
fprintf('\ncomputing t score  ...')
tscore = (mean1-mean2) ./ sqrt( s1.^2 ./n1 + s2.^2 ./ n2);
tscore(find(isnan(tscore)))=0;
tscore(find(isinf(tscore)))=0;

df =  (s1.^2./n1 + s2.^2 ./ n2) .^2 ...
    ./((s1.^2./n1).^2.* (1./(n1-1)) + (s2.^2./n2).^2.*(1./(n2-1)) );

df(df<=0)=0;
df(isnan(df))=0;


SPM_scale_factor=1;
h.datatype = 16;
h.bits =32;

mkdir('T2'); 
cd('T2'); 
% write the files....
fprintf('\nWriting Output files  ...')
write_hdr('tscore.hdr',h);
write_img_data('tscore.img',tscore,h);

write_hdr('var1.hdr',h);
write_img_data('var1.img',s1,h);

write_hdr('var2.hdr',h);
write_img_data('var2.img',s2,h);

write_hdr('mean1.hdr',h);
write_img_data('mean1.img',mean1,h);

write_hdr('mean2.hdr',h);
write_img_data('mean2.img',mean2,h);

write_hdr('df.hdr',h);
write_img_data('df.img',df,h);


fprintf('\ncomputing Z score  ...\n')
zscore = zeros(size(tscore));
for pix=1:Npix
    if (abs(tscore(pix))>=0.01) & (df(pix)>0)
        fprintf('\rpix ... %d of %d',pix,Npix);
        zscore(pix) =  spm_t2z(tscore(pix),df(pix));
    end
end

write_hdr('Zscore.hdr',h);
write_img_data('Zscore.img',zscore,h);

return


