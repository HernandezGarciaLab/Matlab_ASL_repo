function scaleflow()
pf =fopen('f.dat','r');;
pf2=fopen('6f.dat','w');
data = fread(pf,64*64,'int16');
fwrite(pf2,data*6,'int16');
fclose(pf);
fclose(pf2);
return
