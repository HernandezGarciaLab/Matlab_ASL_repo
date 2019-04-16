% $Id: docprec.m 240 2012-09-23 21:55:16Z klitinas $

if ((scaninfo.revflg > 0) && (args.rsa ~= 2))
	% for reverse spiral
	datin = [];
	for prnum = 1:npr
		ptr = (coilnum-1)*(concat+1)*npr + (prnum-1)*(concat+1) + 1;
		datin = [datin (dat(end:-1:1,ptr).').*conj(kdens)];
	end
	datgr = reshape(kbgrid_mex(-ky,kx,real(datin),imag(datin),nim*OVER,kb_gridl*OVER,kbweights(:)),[nim nim]*OVER);
	% [kkx kky] = meshgrid([-nim/2:nim/2-1]);
	% datgr = griddata(real(kinfo.k),imag(kinfo.k),datin,kkx,kky);
	% datgr(isnan(datgr)) = 0;
	datgr = datgr.*fftshmask;
	if (rtype == 'ft')
		% for standard Fourier (gridding) recon
		imtmp = ifft2(datgr.*apod);
		imkb = wc.*imtmp(subim,subim);
	else
		% for time segmented recon
		imtmp = ifft2(squeeze(datgr.*tints(:,:,1)));
		imkb = imtmp(subim,subim);
		for nt = 1:L
			imtmp = ifft2(datgr.*tints(:,:,nt+1));
			imkb = imkb + imtmp(subim,subim).*exp(-i*2*pi*fm(:,:,slnum+1)*nt*tau);
		end
		imkb = imkb.*wc;
	end
	im1 = (imkb).*fftshmask(subim,subim);
	im1nz = 1;
else
	im1nz = 0;
end % if (scaninfo.revflg > 0)

if ((scaninfo.revflg ~= 1) && (args.rsa == 1))
	% for forward  spiral
	datin = [];
	for prnum = 1:npr
		ptr = (coilnum-1)*(concat+1)*npr + (prnum-1)*(concat+1) + concat + 1;
		datin = [datin (dat(:,ptr).').*kdens];
	end
	datgr = reshape(kbgrid_mex(-ky,kx,real(datin),imag(datin),nim*OVER,kb_gridl*OVER,kbweights(:)),[nim nim]*OVER);
	datgr = datgr.*fftshmask;
	if (rtype == 'ft')
		% for standard Fourier (gridding) recon
		imtmp = ifft2(datgr.*apod);
		imkb = wc.*imtmp(subim,subim);
	else
		% for time segmented recon
		imtmp = ifft2(squeeze(datgr.*tints(:,:,1)));
		imkb = imtmp(subim,subim);
		for nt = 1:L
			imtmp = ifft2(datgr.*tints(:,:,nt+1));
			imkb = imkb + imtmp(subim,subim).*exp(i*2*pi*fm(:,:,slnum+1)*nt*tau);
		end
		imkb = imkb.*wc;
	end
	imkb = (imkb).*fftshmask(subim,subim);
end % if (scaninfo.revflg > 0)

return
