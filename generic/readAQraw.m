function raw2 = readAQraw(file, Ndat, Nchanl);

file = dir(file);

Ntraces = file.bytes/Ndat/8/Nchanl;

fp=fopen(file.name,'rb');
raw = fread(fp,Ntraces*2*Ndat,'float64');
fclose(fp)

raw2 = reshape(raw,Ndat,Ntraces*2);

imagesc(raw2);



end
