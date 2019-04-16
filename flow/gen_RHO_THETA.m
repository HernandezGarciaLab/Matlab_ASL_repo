dacmax = hex2dec('7ffe');

NPOINTS = 50;
rf1 = hanning(NPOINTS);
tmp = abs(rf1);
tmp = tmp * dacmax / max(tmp);
tmp = 2*round(tmp/2);
plot(tmp)


% first write it as intt16
filename = sprintf('myHanning%d.bin',NPOINTS);
fp = fopen(filename,'wb','b');
fwrite(fp, tmp, 'int16');
fclose(fp);


% then use GE software to put in proper format
str = sprintf('!xlatebin -o myHanning%d.rho myHanning%d.bin', NPOINTS, NPOINTS);
eval(str)


%%

rf1 = ones(NPOINTS,1);
tmp = abs(rf1);
tmp = tmp * dacmax / max(tmp);
tmp = 2*round(tmp/2);
plot(tmp)


% first write it as intt16
filename = sprintf('myRect%d.bin',NPOINTS);
fp = fopen(filename,'wb','b');
fwrite(fp, tmp, 'int16');
fclose(fp);


% then use GE software to put in proper format
str = sprintf('!xlatebin -o myRect%d.rho myRect%d.bin', NPOINTS, NPOINTS);
eval(str)


