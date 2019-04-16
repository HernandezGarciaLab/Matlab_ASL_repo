function mask_stats(root,threshold)
% function mask_stats(root,threshold)
%
% this function thesholds a set of images named 'root*.img'
% at the specified level and writes out the result to the files
% named thresh???.img (numbered 1 through...number of files)
%
global SPM_scale_factor

hfiles=dir(strcat(root,'*.hdr'));
imgfiles = dir(strcat(root,'*.img'));
numfiles=size(imgfiles,1)


for count=1:numfiles
    h=read_hdr(hfiles(count).name);
    img = read_img_data(h, imgfiles(count).name) * SPM_scale_factor;
    out_img=img;
    
    out_img(find(img < threshold))=0;
    out_img(find(isnan(img)))=0;

    str=sprintf('thresh%03d.img',count);
    write_img_data(str,out_img./SPM_scale_factor,h);
    str=sprintf('thresh%03d.hdr',count);
    write_hdr(str,h);
end