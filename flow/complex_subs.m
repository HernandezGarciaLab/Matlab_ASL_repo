%Do all subtractions for a series of AST images using the old pulse sequence
%Assumes the first files are the control and all others are tags of different duration
%Greg Lee 5/12/02  I created this version to do complex subtractions.

%string example

h=read_hdr('T1.hdr');
c=0;
navg =5;
total=2*navg;


curve = []; 

count=1;
times= [0 1 2 3 4 5];
for i=1:6
    
    str=sprintf('c%d=0;',i);
    eval(str);
    
    for avg=1:navg
        str=sprintf('sl1.%03d',total*(i-1)+2*avg);
        cmag = readim(str,[64 64],0);  %read in magnitude image
        str=sprintf('sl1.phs.%03d',total*(i-1)+2*avg);
        cphase = readim(str,[64 64],0)./1000; %read in phase image and convert to radians
        
        str=sprintf('c%d=cmag+exp(-j*cphase)+c%d;',i,i);  
        eval(str);
    end
    str=sprintf('c%d=c%d/navg;',i,i);  %the SS image
    eval(str);
    
    str=sprintf('t%d=0;',i);
    eval(str);
    for avg=1:navg
        str=sprintf('sl1.%03d',total*(i-1)+2*avg-1);
        tmag = readim(str,[64 64],0);  %read in magnitude image
        str=sprintf('sl1.phs.%03d',total*(i-1)+2*avg-1);
        tphase = readim(str,[64 64],0)./1000; %read in phase image and convert to radians
        
        str=sprintf('t%d=tmag+exp(-j*tphase)+t%d;',i,i);
        eval(str);  
    end
    str=sprintf('t%d=t%d/navg;',i,i);  %the NS image
    eval(str);
    
    str=sprintf('p%d=abs(t%d-c%d);',i,i,i);
    eval(str);
    
    str=sprintf('sub%04d.hdr',i);
    write_hdr(str,h);
    
    str=sprintf('sub%04d.img',i);
    str=sprintf('write_img_data(''%s'',p%d,h);',str,i);
    eval(str);
    
    str=sprintf('curve = [curve; mean(mean(mean(p%d(21:38,22:40,1)))) ];',i);
    eval(str);
    
    time=times(i)*1000;
    str=sprintf('subplot(4,4,i),show(p%d(:,:,1)),title(''times(%d)'');',i,time);
    eval(str);
end


%curve2=[curve([7 6 5 1 2 3 4])];

figure(2), plot(times,curve)

