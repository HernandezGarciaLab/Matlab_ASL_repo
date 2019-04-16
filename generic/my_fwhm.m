function result = my_fwhm(data);
%function result = my_fwhm(data);

mx = max(data(:));
w = find(data(:) >=mx/2);
result = size(w);
return