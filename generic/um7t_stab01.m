function um7t_stab01(pathname)

spike_thresh = 1 ;


% first read in the file and translate it into NII format
[data h ] = fdf2nii(pathname, 0);

data = (reshape(data,  h.dim(2)*h.dim(3)*h.dim(4), h.dim(5)))';

roi = [30:34, 30:34, 4:6];
inds = sub2ind( [h.dim(2), h.dim(3), h.dim(4)], roi);

% test # 1 - look for spikes in the time series:
vdata = var(data);
ddata = zeros(size(data));

for t=2:size(data,1)
	ddata(t,:) = data(t, :) - data(t-1,:);
	
	tmp1 = reshape(ddata(t,:), h.dim(2), h.dim(3), h.dim(4));
	tmp2 = reshape(data(t,:), h.dim(2), h.dim(3), h.dim(4));

	figure(33)
	subplot(322)
	lightbox(tmp1,[-3000 3000],3);
	title(['Difference image ' num2str(t)])
	
	subplot(321)
	lightbox(tmp2, [0 120000], 3);
	title(['Image ' num2str(t)])
	drawnow
end

stab_plot = data(:, inds);

x=[0:length(stab_plot)-1]';
y = mean(stab_plot,2);
stdDev = std(y);

[p s] = polyfit( x,y , 3); 
y2 = polyval(p,x);

subplot(323)
plot(stab_plot)
hold on
plot(x,y2,'k') 
title('ROI and fitted mean of the ROI')


subplot(326)
stab_plot = stab_plot - repmat(mean(stab_plot), size(stab_plot,1),1);

lightbox(reshape(vdata, h.dim(2), h.dim(3), h.dim(4)), [0 1e6],3);
title('The Variance Map')

mstab_plot = mean(stab_plot,2);

fstab_plot = fftshift(fft(fftshift(mstab_plot)));
subplot(325)
w = linspace(-1,1,length(fstab_plot));
plot(w, abs(fstab_plot))
title('FFT of the ROI')



subplot(324)
cla
axis off
text(0.06, 0.8,['standard deviation = ' num2str(stdDev,3)])
text(0.06, 0.6,['poly coeffs = ' num2str(p,3)])
text(0.06, 0.4, date)


title('Stats')




