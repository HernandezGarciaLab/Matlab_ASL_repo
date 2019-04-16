function data=read_bytes(name)
pfile = fopen(name,'r');
data=fread(pfile);

z = size(data)
data = data(72:z(1));
fclose(pfile);
return
