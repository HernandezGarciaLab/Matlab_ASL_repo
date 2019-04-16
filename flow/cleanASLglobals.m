function outdata = cleanASLglobals(root);
% function outdata = cleanASLglobals(root);
%
% if the input data are not in a file with a header,
% I'll just assume that each slice is 64 x 64 pixels
%
% This function removes the fluctuation of each 
% slice's global mean signal from the data by 
% fitting a linear model with a baseline and the mean
% intensity of each slice over time.
% It doesn't remove the baseline, just the fluctuation 
% 
% this is the idea:
%	1 - X = [ ones slice_mean_over_time]
%	2 - y = X*beta
%	3 - estimate beta_hat
%	4 - set beta_hat_1 = 0;
%	5 - y_out = y - X*beta_hat
% 
% the output is a file called "demeaned_[root]"
%

if isstr(root)
[data h] = read_img(root);
slsize = h.xdim*h.ydim;
Nslices = h.zdim;
Nframes = h.tdim;

else
	data=root;
	slsize=64*64;  % assume this is the case
	Nslices = size(data,2)/slsize
	Nframes = size(data,1);
end

outdata = zeros(size(data));



for sl=1:Nslices
	myslice = data( :, (sl-1)*slsize +1: sl*slsize);
	myslicemeans = mean(myslice,2);
	myslicemeans = myslicemeans - mean(myslicemeans);
	
	X = [ones(Nframes,1)  myslicemeans];
	betahats = pinv(X)*myslice;
	betahats(1,:) = 0;
	%plot(myslice - X*betahats); drawnow
	outdata(:, (sl-1)*slsize +1: sl*slsize) = myslice - X*betahats;

end

if isstr(root)
	write_img(['demeaned_' root], round(outdata), h);
end

return