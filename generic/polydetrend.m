function [result, coeffs] = polydetrend(data, order, dim)
% this function fits and subtracts a fourth order polynomial from the data.
% INPUT: 
%       data: 2D array to be detrended
%       dim = 1, detrend as column vectors; dim = 2, as row vectors
%       order: order of the polynomial

if nargin == 2
    if size(data, 1) == 1
        dim = 2;
    elseif size(data, 2) == 1
        dim = 1; 
    else
        dim = 1; 
    end
end
RC = size(data); % row and column
num = RC(dim); 
t = linspace(0, num, num);

if dim ==1  % as column vectors
    for ind = 1:RC(2)
        [coeffs(ind,:), error] = polyfit(t, data(:,ind)', order);
        result(:,ind) = data(:,ind) - polyval(coeffs(ind, :), t)';
    end
else        % as row vectors
    for ind = 1:RC(1)
        [coeffs(ind,:), error] = polyfit(t, data(ind,:), order);
        result(ind, :) = data(ind, :) - polyval(coeffs(ind, :), t);
    end        
end
save coeffs
return
