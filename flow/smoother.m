function smoother2(root , fwhm)
% function smoother (root , fwhm)
%
% uses Matlab's smooth3 function on a time series
%
[data h] = read_img(root);
% if ~exist('h.tdim')
% 	h = nii2avw_hdr(h);
% end
odata = zeros(size(data));

for t=1:h.tdim
	in = reshape(data(t,:), h.xdim, h.ydim, h.zdim);
	tmp = smooth3(in, 'gaussian', [ 1 1 1 ]*fwhm);
	odata(t,:) = tmp(:);
end

write_img(['s' root], odata, h);
