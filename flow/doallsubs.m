function doallsubs(root,navg,points, iscomplex)
%function doallsubs(root,navg,points [,iscomplex])
%
% Do all subtractions for a series of AST images 
% Assumes the files are AST pairs, wher the the control is the first image 
% and all others are tags of different duration
%
%  The first pair is skipped in every set of averages.
%
% root - rootname of the files
% navg - number of averages per point
% points - number of time points in the series
% iscomplex - point out whether these are complex images
% 
% this version returns the % signal change *100

str = sprintf('%s001.hdr',root);
h=read_hdr(str);
total=2*navg;
count=1;
iscomplex=0;
if nargin==4
    iscomplex=1;
end

for count=1:points
    t=zeros(h.xdim,h.ydim,h.zdim);
    c=zeros(h.xdim,h.ydim,h.zdim);
    for avg=3:navg
        % control images ...
        str=sprintf('%s%03d.img',root,total*(count-1)+2*avg-1);
        fprintf('\nReading CONTROL image...%s', str);
        tmp = read_img2(h,str);
               
        if (iscomplex==1)
            str=sprintf('p_%s%03d.img',root,total*(count-1)+2*avg-1);
            phs = read_img2(h,str) ./ 1000;
            phs = unwrap(phs);
            tmp = tmp.*exp(-j.*phs);
        end
        
        c = c + tmp;
    
        % tag images ... 
        str=sprintf('%s%03d.img',root,total*(count-1)+2*avg);
        fprintf('\nReading TAG image...%s', str);
        tmp = read_img2(h,str);
        
        if (iscomplex==1)
            str=sprintf('p_%s%03d.img',root,total*(count-1)+2*avg);
            phs = read_img2(h,str) ./ 1000;
            phs = unwrap(phs);
            tmp = tmp.*exp(-j.*phs);
        end
        
        t=t+tmp;
    end
    
    c = c./(navg-1);
    t = t./(navg-1);
       
      
    if (iscomplex==1)
        
        % write the phase of the subtraction image ...
        str=sprintf('p_sub_%03d.img',count);
        fprintf('\nWriting ... %s ... in units of 1000*(radians)', str)
        write_img_data(str,angle(s)*1000,h);
        str=sprintf('p_sub_%03d.hdr',count);
        write_hdr(str,h);
        
        % write the change in phase due to the tag:  i.e : next to nothing
        % this should help find if there is a phase problem.
        
        delta_phi = (angle(t)-angle(c));
        
        str=sprintf('delta_phase_%03d.img',count);
        fprintf('\nWriting ... %s ... in units of 1000*(radians)', str)
        write_img_data(str,angle(delta_phi)*1000,h);
        str=sprintf('delta_phase_%03d.hdr',count);
        write_hdr(str,h);
        
    end
    
    % calculate the % signal change.
    s = (t-c)*10000./c;
    % throw away pixels without tissue signal
    s(find(abs(c)<50)) = 0;
    
    str=sprintf('sub_%03d.hdr',count);
    write_hdr(str,h);
    str=sprintf('sub_%03d.img',count);
    fprintf('\nWriting ... %s ... in units of 100*(percent change)', str);
    write_img_data(str,s,h);
    
    
    
end
fprintf('\r.....Done\n');

return
