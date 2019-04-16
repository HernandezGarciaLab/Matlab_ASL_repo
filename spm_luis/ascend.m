function ascend(rootname, [xyz], DesMat)
%function ascend(rootname, [x,y,z], DesMat)

Thres1 = 500;  % mask out pixels below this value
% either we filter or pre-whiten
doWhiten = 0;
doFilter=1;

if doWhiten==1
    doFilter=0;
else
    doFilter=1;
end
x = xyz(:,1);
y = xyz(:,2);
z = xyz(:,3);


h = read_hdr(rootname);
data = read_img_series(rootname(1:end-8));
ind = sub2ind([h.xdim, h.ydim, h.zdim], x,y,z);
exemplar = data(:,ind);

MI = zeros(1,size(data,2));
asc = zeros(1,size(data,2));
H_asym = zeros(1,size(data,2));
rho = zeros(1,size(data,2));

if doWhiten
    % whitening the noise in the data
    exemplar = whiten(exemplar , DesMat);
end

for pix=1:size(data,2)
    if data(5,pix) > Thres1

        tseries = data(:,pix); 
        if doWhiten
            tseries = whiten(tseries, DesMat);
        end
       doFilter 
        
       [a, mi, H2, r] = causal03(exemplar',tseries',doFilter);

        asc(pix) = a;
        H_asym(pix) = H2;
        rho(pix)=r;
        MI(pix) = mi;
    end
end

% show histograms of the results.
subplot(221)
hist(asc(:),100);title('Ascendency')
%axis([-0.2 0.2 0 50])
subplot(222)
hist(H_asym(:),100);title('Histogram Asymmetry')
%axis([-0.2 0.2 0 50])
subplot(223)
hist(rho(:),100); title('Correlation COeff')
%axis([-1 1 0 50])
subplot(224)
hist(MI(:),100); title('Mutual Information')
%axis([-1 1 0 50])


asc = reshape(asc,h.xdim, h.ydim,h.zdim);
MI = reshape(MI,h.xdim, h.ydim,h.zdim);
H_asym = reshape(H_asym,h.xdim, h.ydim,h.zdim);
rho = reshape(rho,h.xdim, h.ydim,h.zdim);

write_hdr('MI.hdr',h);
write_hdr('Rho.hdr',h);
write_hdr('Asc.hdr',h);
write_hdr('H_aym.hdr',h);
write_img('MI.img',MI*1000,h);
write_img('Rho.img',rho*1000,h);
write_img('Asc.img',asc*1000,h);
write_img('H_asym.img',H_asym*1000,h);
save ascendency

return

