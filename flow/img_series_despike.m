function img_series_despike(filename, DespikeLevel)
% function img_series_despike(filename, DespikeLevel)

[raw hdr] = read_img(filename);
 
mraw = mean(raw,2);   % image means
stdmraw = std(mraw);  % std of image means
mmraw = mean(mraw);   % grand mean

badinds = find( abs(mraw - mmraw) > DespikeLevel *stdmraw)
fprintf('found %n spike images', length(badinds));


% replace the images in the badinds with the average of their neighbors
old = raw;

for m=1:length(badinds)
    n = badinds(m)
    if (n>1) & (n<hdr.tdim)
        tmp = (old(n-1,:) + old(n+1,:))/2;
        raw(n,:) = tmp;
    end
    
    if n==1
       raw(n,:) = old(2,:);
    end
    
    if n==hdr.tdim
        raw(n,:) = old(hdr.tdim-1,:);
    end
end


write_img(['d_' filename], raw, hdr);

%{
% Deugging:   show me the changes to verify

m=mean(raw(:));
s=std(raw(:));

subplot(311)
imagesc(old)
caxis([ m-2*s  m+2*s])

subplot(312)
imagesc(raw)
caxis([ m-2*s  m+2*s])

subplot(313)
imagesc(old-raw)
caxis([-s  s])
%}


return
