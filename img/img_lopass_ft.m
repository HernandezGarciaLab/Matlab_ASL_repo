function img_lopass_ft(fname, cutoff)
% function img_lopass(fname, cutoff_fraction)
% zero out the frequencies above the cutoff_fraction in the frequency
% domain 
% (frequency scale :  Nyquist = 1)


[raw hdr] = read_nii_img(fname);

out = raw;

[nframes npix] = size(raw);
ncut = round(cutoff * nframes/2);

parfor p=1:npix
    tmp = raw(:,p);
    ftmp = fft(tmp);

    ftmp(ncut+1:end-ncut) = 0;
    out(:,p) = abs(ifft(ftmp));
    
end


write_nii(['l' fname], out, hdr,0);

return

        
        
        