%fp = fopen('~/matlab/flow/hrfevery80.bin','rb');
fp = fopen('~/matlab/flow/gamma80.bin','rb');
func = fread(fp,6000,'float');
fclose (fp);
%func = (func*1.5 + 2)*90;
time = [0.1:0.1:600];

plot(time, func)
axis([0 600 0 320])
