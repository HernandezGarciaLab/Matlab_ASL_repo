function flip = doubleangle( im1name, im2name)

%function flip = doubleangle( im1, im2)
% 
% flip angle measurement using the double angle formula
% im1name: image collected with flip angle= theta
% im2name: image collected with flip angle = 2*theta
% 
% flip : resulting image of flip angles at each pixel
%       flip = acos(im2 ./(2*im1));
%

[im1 h] = read_img(im1name);
[im2 h] = read_img(im2name);

if h.tdim>1
    im1 = mean(im1,1);
    im2 = mean(im2,1);
else
    im1 = im1(:);
    im2 = im2(:);
end

msk = im2;
th = 0.9*std(im2);
msk(im2< th) = 0;
msk(msk>0) = 1;

flip = acos(im2 ./(2*im1));
flip = rad2deg(flip) .* msk;

h.tdim = 1;
write_img('flipmap100.img', abs(flip) * 100, h);
flip = reshape(flip, h.xdim, h.ydim, h.zdim);

save flipang.mat flip

return