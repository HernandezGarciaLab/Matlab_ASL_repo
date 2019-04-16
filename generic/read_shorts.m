function data=read_shorts(name, Nshorts)
pfile = fopen(name,'r');
data=fread(pfile,Nshorts,'short');

fclose(pfile);
return
