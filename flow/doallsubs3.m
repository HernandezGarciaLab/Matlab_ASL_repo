function doallsubs2(root,navg,points, iscomplex)
%function doallsubs2(root,navg,points [,iscomplex])
%
% Do all subtractions for a series of AST images 
% Assumes the files are AST pairs, wher the the control is the first image 
% and all others are tags of different duration
%
% root - rootname of the files
% navg - number of averages per point
% points - number of time points in the series
% iscomplex - point out whether these are complex images
%
% this version returns the absolute value of the difference

str = sprintf('%s001.hdr',root);
h=read_hdr(str);
total=2*navg;
count=1;
iscomplex=0;
if nargin==4
    iscomplex=1;
end
skip = 1;
    

for count=1+skip:points
    
        % read the control ...
        
        str=sprintf('%s%03d.img',root,count*2 -1 );
        fprintf('\nReading CONTROL image...%s', str);
        c = read_img2(h,str);
        
        % read the tag...
        
        str=sprintf('%s%03d.img',root,count*2 );
        fprintf('\nReading TAG image...%s', str);
        t = read_img2(h,str);
        
        % do the subtraction (% units)
        s = (c -t);
        s(find(abs(c)<50)) = 0;
        
%         as = abs(s);
%         subplot 131, imagesc(c)
%         subplot 132, imagesc(s , [0 1000])
%         subplot 133, imagesc(as, [0 1000])
%         whos s as
%         pause
%         
    
    str=sprintf('sub_%03d.hdr',count);
    write_hdr(str,h);
    
    str=sprintf('sub_%03d.img',count);
    fprintf('\nWriting ... %s ... ', str);
    
    write_img_data(str,(s),h);
    
    
    
end
fprintf('\n.....Done\n');

return
