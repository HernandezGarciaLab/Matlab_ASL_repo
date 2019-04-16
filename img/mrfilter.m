function out=mrfilter(indata, s)
%
% function out = mrfilter( 3D_image, pixel_sizes)
% 
% This filter prodices a Gaussian weighted sum of the neighbors
% this weighted sum is weighted ALSO by a spatial derivative of time images
% The result is a Gaussian smoothing kernel that PRESERVES THE EDGES a
% little better
% 

if nargin<2
    s = [1 1 1];
end

% Gaussian smoothing kernel coefficients
k = exp(-s/2);


[xdim ydim zdim] = size(indata);
tmp = zeros(xdim+2, ydim+2, zdim+2);
tmp(2:end-1, 2:end-1, 2:end-1) = indata;

in = tmp;

smin = zeros(size(in));
[xdim ydim zdim] = size(in);
% smoothed version of the image
den = (1+ 2*sum(k));
for n=2:xdim-1,
    for m=2:ydim-1,
        parfor l=2:zdim-1,

            smin(n,m,l) = in(n,m,l) + ...
                k(1) * in(n+1,m,l) + ...
                k(1) * in(n-1,m,l) + ...
                k(2) * in(n,m+1,l) + ...
                k(2) * in(n,m-1,l) + ...
                k(3) * in(n,m,l+1) + ...
                k(3) * in(n,m,l-1);
         
            smin(n,m,l) = smin(n,m,l) / den;
        end
    end
end

% compute the gradient of the smoothed image
[grdx grdy grdz] = gradient(smin,s(1), s(2), s(3));

grdx=abs(grdx);
grdy=abs(grdy);
grdz=abs(grdz);

% the kernel weights are determined by the inverse of the gradient in order
% to preserve the edges:
wx = 1/7 + 1./grdx;
wy = 1/7 + 1./grdy;
wz = 1/7 + 1./grdz;

wx(isinf(wx)) = 0;
wy(isinf(wy)) = 0;
wz(isinf(wz)) = 0;
% 
% wx(:) = 1;
% wy(:) = 1;
% wz(:) = 1;

out = in;

% apply gaussian filter that is further weighted by the inverse of the gradients
for n=2:xdim-1,
    for m=2:ydim-1,
        parfor l=2:zdim-1,

            out(n,m,l) = in(n,m,l) + ...
                k(1) * wx(n,m,l)*in(n+1,m,l) + ...
                k(1) * wx(n,m,l)*in(n-1,m,l) + ...
                k(2)* wy(n,m,l)*in(n,m+1,l) + ...
                k(2)* wy(n,m,l)*in(n,m-1,l) + ...
                k(3) * wz(n,m,l)*in(n,m,l+1) + ...
                k(3) * wz(n,m,l)*in(n,m,l-1);
         
            out(n,m,l) = out(n,m,l) / (1+...
                k(1)*wx(n,m,l) + ...
                k(1)*wx(n,m,l) + ...
                k(2)*wy(n,m,l) + ...
                k(2)*wy(n,m,l) + ...
                k(3)*wz(n,m,l) + ...
                k(3)*wz(n,m,l) + eps);
        end
    end
end

out(isinf(out))=0;
out(isnan(out))=0;

out = out(2:end-1, 2:end-1, 2:end-1);


return
