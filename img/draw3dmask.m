function msk = draw3dmask(img);
% function msk = draw3dmask(img);
% free hands a binary mask for a 3D data set one slice at at time

msk = zeros(size(img));
for sl=1:size(img,3)
    imagesc(img(:,:,sl));
    axis xy
    title(sprintf('Slice %d out of %d', sl, size(img,3)));
    h=imfreehand();
    tmp=createMask(h);
    msk(:,:,sl) = tmp;
end
    
    