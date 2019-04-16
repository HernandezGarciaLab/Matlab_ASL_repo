function img_flipper(root , dim)
% function img_flipper (root , dim)
%
% uses Matlab's smooth3 function on a time series
%
[pth root ext] = fileparts(root);

[data h] = read_img(root);

%if ~exist('h.tdim')
%	h = nii2avw_hdr(h);
%end

odata = zeros(size(data));

if h.tdim==1
    odata = flipdim(data, dim);
   odata = odata(:);

else
    for t=1:h.tdim
        in = reshape(data(t,:), h.xdim, h.ydim, h.zdim);
        tmp = flipdim(in, dim);
        odata(t,:) = tmp(:);
    end
end

if ext =='.nii'
    h=avw2nii_hdr(h);
    write_nii([root ext], odata, h,0);
else
    write_img([root ext], odata, h);
end