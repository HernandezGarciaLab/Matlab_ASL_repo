function [DurbinWatson, DW_pval] = DurbinWatson(data)
% function [DurbinWatson, DW_pval] = DurbinWatson(data)
%
%
% Testing for independence of the component - is it autocorrelated?
% in AR1 model, lag0 = rho * lag1
% so we estimate rho and  its variance
%
%
data = data - mean(data);
data = reshape(data, length(data), 1);

lag0 = data(2:end);
lag1 = data(1:end-1);
T = length(data) ;

invlag1 = pinv(lag1);
rho = invlag1 * lag0;
VarEstRho = invlag1 * var(lag0) * invlag1'

% this is the DurbinWatson test:
DurbinWatson = sum ( (lag0 - lag1).^2)  / sum(lag0.^2)

% The H statistic is normally distributed
whos
h = (1 - 0.5*DurbinWatson)*sqrt( T / (1 - T*VarEstRho))
%DW_pval = 1 - normcdf(0, h, sqrt(VarEstRho) );

return
