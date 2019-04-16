function  write_rho(rf1, pulsename)

dacmax = hex2dec('7ffe');

fp = fopen([pulsename '.bin'],'wb','b');
tmp = abs(rf1);
tmp = tmp * dacmax / max(tmp);
tmp = 2*round(tmp/2);
fwrite(fp, tmp, 'int16');
fclose(fp);

str = ['!xlatebin -o ' pulsename '.rho ' pulsename '.bin'];
eval(str)

end