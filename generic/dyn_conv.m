function result = dyn_conv(n,fun1, fun2)
% function result = dyn_conv(n,fun1, fun2)
%
% dynamic convolution function (convolution of time-variant fonctions)
% computes a convolution point by point so that you can change one
% of the functions with time.  this is equivalent to
% doing: 
%     c = conv(a,b)
%     result = c(n)
%
% 
    %n=n-1;
    
    n1 = max(size(fun1));
    n2 = max(size(fun2));
    
    nz = max([n1 n2]);
 
    tmp1 = zeros(3*nz,1);
    tmp1(nz+1:nz+n1) = fun1;
    
    
    tmp2 = zeros(3*nz,1);
    tmp2(nz-n2+1 +n:  nz+n ) = fun2(end:-1:1);
     
    
%     subplot 211, plot(tmp1)
%     subplot 212, plot(tmp2)
%     drawnow 
    result = sum(tmp1 .* tmp2);
    
return


