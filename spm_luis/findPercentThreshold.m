function result=findPercentThreshold(data, percent, bins);
%function result=findPercentThreshold(data, percent, bins);
% this is a short function to determine what value of a data set represents
% the point where you get the top XX percent of the data.
% e.g - what t score in the data should I suse as a threshold in order
% get the top 10% of the voxels

[N Val] = hist(data,bins);
dataIntegral = cumsum(N);
nrg = dataIntegral(end);
inds = find(dataIntegral/nrg > 1-  percent/100 ); 
result = Val(inds(1));
return
