function x = chi(estimate , data )
%function x = chi(estimate , data )
%
%
estimate = reshape(estimate, size(data));
N = max(size(data));
x = (1/N)*sum ( (estimate - data).^2 ) / var(estimate) ;

return

