function zshifter(root, Nshift)
% function zshifter(root, Nshift)
% takes care of wrap around in 3D reconstructions along the z direction
%

isNIFTI = 0;

[pth nm ext] = fileparts(root);
if ext=='.nii'
	isNIFTI=1;
end

[d h] = read_img(root);
out = zeros(size(d));

for t=1:h.tdim

	d2 = d(t,:);
	d2 = reshape(d2,h.xdim, h.ydim, h.zdim);
	out2 = zeros(size(d2));
	out2 = circshift(d2,[0 0 Nshift]);
	out(t,:) = out2(:)';
end

if isNIFTI
	write_nii(root,out, avw2nii_hdr(h),0);
else
	write_img([root '.img'], out, h);
end



return
