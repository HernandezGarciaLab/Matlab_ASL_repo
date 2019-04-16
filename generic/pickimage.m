function pickimage(data)
%function pickimage(data)
% data = squeeze(data);
% imagesc(data)
% while 1 
%     [j,k] = ginput(1); 
%     disp(data(round(j),round(k))); 
% end

data = squeeze(data);
imagesc(data)
while 1
    [k,j] = ginput(1); 
    fprintf('\ncoords: %d,  %d ... %03f',round(j),round(k),data(round(j),round(k))); 
end