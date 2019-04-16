function result=mydetrend( data)
% function result=mydetrend( data)
%
% disp('detrending with 3rd order polynomial')
%
disp('detrending with 3rd order polynomial')
t=[1:length(data)];
[coeffs, error] = polyfit(t,data,3)

result = data ...
    -coeffs(4) ...
    - coeffs(3)*t ...
    - coeffs(2)*t.^2 ...
    - coeffs(1)*t.^3;

save coeffs.mat coeffs error

return
