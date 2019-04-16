function out = ksmooth(in, nstd)
% function out = ksmooth(in, nstd)

w = (1/sqrt(2*pi))*exp(-(nstd.^2)/2);

k = w* ones(3);
k(2,2) = 1/sqrt(2*pi);
NRG = sum(k(:));

[n m] = size(in);
tmp = in;

for n=2:size(tmp,1)-1
    for m=2:size(tmp,2)-1
        
        buf = in(n-1:n+1 , m-1:m+1) .* k;
        tmp(n,m) = sum(buf(:)) / NRG;
        
    end
end

out = tmp;

return