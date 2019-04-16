function amap = cplx_angio(root, threshold);
% function amap = cplx_angio(root, threshold);

[mdata h] = read_img(root);
pdata = read_img(['p_' root]);


Npix = size(mdata,2);
amap = zeros(Npix,1);

for pix=1:Npix
	rhos = corrcoef( mdata(:,pix) , pdata(:,pix) );
	amap(pix) = rhos(2,1);
end

if isfield(h,'pixdim')
	h = nii2avw_hdr(h);
end
amap = reshape(amap, h.xdim, h.ydim, h.zdim);

return