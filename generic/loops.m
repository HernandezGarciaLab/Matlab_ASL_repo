
figure
hold on
axis([-pi pi -1 1]);

t=linspace(-pi, pi);


title ('using a for loop')
for i = 1:5
    w = 0.3*i;
    y = sin(w *t);
    plot(t, y)
    drawnow
    
end



pause

cla
title('Using a while Loop')
hold on
i=1;
while (w<2)
    w = 0.3*i;
    y = sin(w *t);
    plot(t, y,'r')
    drawnow
    i=i+1;
end
hold off

pause





str1 = 'file';
for i=1:10
   outstr = sprintf('%s%04d.img', str1,i);
   fprintf('\rThe new file name is ...%s', outstr);
   
end

pause






% Using for loops should be avoided in Matlab
a=zeros(100,100);
for x=1:100
    for y = 1:100
        r = sqrt( (x-50)^2 + (y-50)^2 );
        a(x , y) = r ;
    end
end

for f=1:-0.05:0.005
    
    for x=1:100
        for y = 1:100
            b(x , y) = sinc(a(x,y) * f);
        end
    end
    imagesc(b)
    title ('Sinc function in 2D')
    drawnow
    
end


pause
  
    
for f=1:-0.05:0.005

    b = sinc(a *f);
    imagesc(b);
    drawnow
    
end

