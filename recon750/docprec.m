% 

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

%if ((scaninfo.revflg ~= 1) && (args.rsa == 1))
if ((scaninfo.revflg ~= 1)) % && (args.rsa == 2))
    % for forward  spiral
    datin = [];

    % LHG 12/12/2017:  navigator echo correction for multi-shot
    if args.phasefact
        for prnum = 1:npr
            ptr = (coilnum-1)*(concat+1)*npr + (prnum-1)*(concat+1) + concat + 1;
            % nav correction:
            if prnum==1
                refPoint = dat(1:10,ptr);
                datin = [datin (dat(:,ptr).').*kdens];
                
            else
                
                navcorrection =  mean(refPoint ./ dat(1:10,ptr)) ;
                
                if navcorrection==0, navcorrection=1; end
                if isnan(navcorrection), navcorrection=1; end
                if isinf(navcorrection), navcorrection=1; end
                
                tmpdat = dat(:,ptr) * navcorrection;

                % for debugging: 
                if (~isempty(find(isnan(tmpdat))))
                    phnum
                    coilnum
                    disp('found a NAN')
                    find(isnan(tmpdat))                   
                    tmpdat(isnan(tmpdat)) = 0;
           
                    figure(55)
                    plot(angle(dat(:,ptr))); hold on
                    plot(angle(tmpdat)); hold off
                    axis([1 400 -pi pi])
                end
                
                datin = [datin (tmpdat.').*kdens ];

     
            end
            
        end
        %
        %{
        %1/9/19
        shot=1;
        navcorrection=1;
        for shot=1:npr
            ptr = shot + (coilnum-1)*npr;
            if shot==1
                refPoint = dat(2,ptr);
            end
            navcorrection = angle(refPoint / dat(2, ptr));  % forces the first point in all the shots to be the same
            navcorrection = exp(-i*navcorrection);  % forces the first point in all the shots to be the same
            
            %navcorrection = (refPoint / dat(1, ptr)) ; % forces the first point in all the shots to be the same
            
            tmpdat = dat(:,ptr) * navcorrection;
            
            fprintf('\nshot=%d  ptr = %d correction=%f + i*%f', ...
                shot, ptr, real(navcorrection), imag(navcorrection));
            
            datin = [datin (tmpdat.').*kdens ];
            
        end
        %}
    else
        % no phase correction  for multishot
        for prnum = 1:npr
            ptr = (coilnum-1)*(concat+1)*npr + (prnum-1)*(concat+1) + concat + 1;
            datin = [datin (dat(:,ptr).').*kdens];
        end
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

% 
% if SHOWME==3
%     imagesc(abs(datgr)); 
%     title(sprintf('Slice %d , Coil %d', slnum, coilnum)); 
%     colorbar
%     pause(0.5);
%     drawnow
% end
    
return
