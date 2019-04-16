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
% this version returns the % difference 

str = sprintf('%s001.hdr',root);
h=read_hdr(str);
total=2*navg;
count=1;
iscomplex=0;
skip = 1; % this is intended to skip field map images....
if nargin==4
    iscomplex=1;
end

for count=1:points
    
    c=zeros(h.xdim,h.ydim,h.zdim);    
    t=zeros(h.xdim,h.ydim,h.zdim);
    s=zeros(h.xdim,h.ydim,h.zdim);
    delta_phi = zeros(h.xdim,h.ydim,h.zdim);
    
    for avg=1+skip:navg
        
        % read the control ...
        
        str=sprintf('%s%03d.img',root,total*(count-1)+2*avg-1);
        fprintf('\nReading CONTROL image...%s', str);
        ctmp = read_img2(h,str);

        if (iscomplex==1)
            str=sprintf('p_%s%03d.img',root,total*(count-1)+2*avg-1);
            phs = read_img2(h,str) ./ 1000;
            phs = unwrap(phs);
            ctmp = ctmp.*exp(-j.*phs);
        end
        
        c = c + ctmp;
        
        % read the tag...
        
        str=sprintf('%s%03d.img',root,total*(count-1)+2*avg);
        fprintf('\nReading TAG image...%s', str);
        ttmp = read_img2(h,str);
        
        if (iscomplex==1)
            str=sprintf('p_%s%03d.img',root,total*(count-1)+2*avg);
            phs = read_img2(h,str) ./ 1000;
            phs = unwrap(phs);
            ttmp = ttmp.*exp(-j.*phs);
            
            dptmp = (angle(ctmp)-angle(ttmp));
            delta_phi = delta_phi + dptmp;
            
        end
        
        t = t+ ttmp;
        

    end
    c = c./navg;
    t = t./navg;
    %s = 10000*(c -t)./c;
    %s = 100*(-c+t);
    s = (-c+t);
    
    if (iscomplex==1)
        
        % write the phase of the subtraction image ...
        str=sprintf('p_sub_%03d.img',count);
        fprintf('\rWriting ... %s ... in units of 1000*(radians)', str);
        write_img_data(str,angle(s)*1000,h);
        str=sprintf('p_sub_%03d.hdr',count);
        write_hdr(str,h);
        
        % write the change in phase due to the tag:  i.e : next to nothing
        % this should help find if there is a phase problem.
        delta_phi = delta_phi./navg;
        
        str=sprintf('delta_phase_%03d.img',count);
        fprintf('\rWriting ... %s ... in units of 1000*(radians)', str);
        write_img_data(str,angle(delta_phi)*1000,h);
        str=sprintf('delta_phase_%03d.hdr',count);
        write_hdr(str,h);
        
    end
    
    % throw away pixels without tissue signal
    %s(find(abs(c)<250)) = 0;
    
    str=sprintf('sub_%03d.hdr',count);
    write_hdr(str,h);
    str=sprintf('sub_%03d.img',count);
    fprintf('\nWriting ... %s ... in units of 100*(percent change)', str);
    write_img_data(str,(s),h);
    
    
    
end
fprintf('\n.....Done\n');

return
