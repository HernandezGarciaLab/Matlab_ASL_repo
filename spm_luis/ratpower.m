x_mean=61;  % assume this is the effect size
x_sigma=(68^2 + 68^2)^0.5;
df = 30;


x_mean=10
x_sigma=20
df = 55*4 - 100 - 6 -1

t = x_mean/(x_sigma/sqrt(df));
zdata = spm_t2z(t,df-1)

pval = 0.001;
p=1;
z=0;

while p >= pval
    
    p = 1-spm_Ncdf(z);
    z=z+0.01;

    beta = spm_Ncdf(z,zdata,1);

end

beta
zcrit= z
stpower = 1-beta
