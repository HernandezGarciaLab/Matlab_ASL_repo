function result=make_gaussian(m,sd,pts)
%function result=make_gaussian(m,sd,pts)
%
% x = linspace(0,pts,pts);
% result = exp( - (x-m).^2 / sd);
% result = result/sum(result);
x = linspace(0,pts-1,pts);
result = exp( - (x-m).^2 / sd);
result = result/sum(result);
return
