function ge_asl_2timeseries(root )
% function smoother (root)
%
% rearranges the data into time series that casl_pid_02.m can handle
%
%M0 = data(:,2);
%deltaM = data(:,1);

[data h] = read_nii_img(root);


odata = zeros(3, size(data,2));

odata(1,:) = data(:,2);
odata(2,:) = data(:,1);
odata(3,:) = 0;

h.dim(1) = 4;
h.dim(5) = 3;

write_nii(['s' root], odata, h); 

return