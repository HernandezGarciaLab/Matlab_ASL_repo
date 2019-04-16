function zflipper(root, keepName)
% function zflipper(root, keepName)
% makes the images flip along the z direction
%
if nargin<2
	keepName=0;
end
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

	for z=1:h.zdim
		out2(:,:,z) = d2(:,:,h.zdim-z+1);
	end

	out(t,:) = out2(:)';
end

if keepName
	if isNIFTI
		write_nii(root,out, avw2nii_hdr(h),0);
	else
		write_img([root '.img'], out, h);
	end

else
	if isNIFTI
		write_nii(['r' root],out, avw2nii_hdr(h),0);
	else
		write_img(['r' root '.img'], out, h);
	end
end

return
