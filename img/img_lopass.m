function img_lopass(fname, kernel)
% function img_lopass(fname, kernel)

[raw hdr] = read_nii_img(fname);

out = raw;

if isempty(kernel)
    kernel = exp(-[-4:4].^2/4);
end

[nframes npix] = size(raw);
kernel = kernel/sum(kernel);
klen = length(kernel);

parfor p=1:npix
    tmp = conv(raw(:,p), kernel); 
    out(:,p) = tmp(1:nframes);
end

out(1:klen/2+1,:) = raw(1:klen/2+1,:);

write_nii(['l' fname], out, hdr,0);

return

        
        
        