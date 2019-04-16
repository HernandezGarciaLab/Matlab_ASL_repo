function result = jhist(a,b,Nbins)
% function result = jhist(a,b,Nbins)
%
% (c) 2005 Luis Hernandez-Garcia
% University of Michigan
% 
% Produces  a joint histogram of two signals, a and b
% using Nbins^2
%
a = reshape(a,1,length(a));
b = reshape(b,1,length(b));

amin = min([a b]);
amax = max([a b]);

a_delta = (amax - amin) / Nbins;

a_bins = amin + a_delta*[0:Nbins-1];
b_bins = a_bins; %bmin + b_delta*[0:Nbins-1];

result = zeros(Nbins);

for ca=1:Nbins
    ind = find(a > a_bins(ca)-a_delta/2 & a <= a_bins(ca)+a_delta/2 );
    btmp = b(ind);
    result(ca,:) = hist(btmp , b_bins);
end

return