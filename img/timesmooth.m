function out = timesmooth(in);
%
% function out = timesmooth(in);
% This function uses this Gaussian kernel to smooth a time series of images along the item dimension
% k = exp(-[2 1 0 1 2]./2);
% 

k = exp(-[2 1 0 1 2]./2);

out = in;

for t=3:size(in,1)-2
    out(t,:) = (1/sum(k)) * (...
        k(1)*out(t-2,:) + ...
        k(2)*out(t-1,:) + ...
        k(3)*out(t-0,:) + ...
        k(4)*out(t+1,:) + ...
        k(5)*out(t+2,:) );
end

return
