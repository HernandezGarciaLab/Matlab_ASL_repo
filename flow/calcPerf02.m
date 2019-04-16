function [f vf] = calcPerf( cfile, tfile, outfile, TR, Ttag, pid, Ttrans, inv_alpha)
%
%function [f variancef]= calcPerf( cfile, tfile, outfile, TR, Ttag, pid, Ttrans, inv_alpha)
%
% This function uses the model in
%  Wang et al MRM 48,2,p242-254, 2002
% to calculate the mean perfusion over the time course. 
% 
% the models:
% num = contro-tag
% den = T1app*2*M0*inv_alpha/lambda * ...
%    (exp(-Ttrans*(1/T1a-1/T1app)) - exp((Ttrans-pid-Ttag)/T1app))...
%    *exp(- pid/T1a);
% flow = num/den;
warning off;
lambda = 0.9;
T1 = 1.25;
T1a = 1.65;
T1app=1/(1/T1 + 0.015/lambda);


[c h] = read_img(cfile);
[t h] = read_img(tfile);

%For variance Calculations
c1=c;
t1=t;
%
c = mean(c,1);
t = mean(t,1);

h.tdim = 1;

mask = zeros(size(c));
mask(find(c>0.2*max(c(:))))=1;

M0 = c/(1 - exp(-TR/T1));

% This is equation 3 from Alsop et al: JCBFM 16, 1236-1249,1996
%den = T1app*2*M0*inv_alpha/lambda * exp(-Ttrans*(1/T1a-1/T1app))*exp(-pid/T1a);

% modification by Wang et al MRM 48,2,p242-254, 2002:
%den = T1app*2*M0*inv_alpha/lambda * ...
%    (exp(-Ttrans*(1/T1a-1/T1app)) - exp((Ttrans-pid-Ttag)/T1app))...
%    *exp(- pid/T1a);

% looking at equation 1, delta_a and delta should be almost the same, we
% can drop a term.
den =  2 * M0* inv_alpha / lambda ...
    *( T1app*exp(-Ttrans/T1a) * ( exp( (Ttrans-pid)/T1app ) - exp( (Ttrans-Ttag-pid)/T1app)));


f = (c-t)./den .* mask * 6000;



den1=[];
mask1=[];
for i=1:size(c1,1)
    den1=[den1; den];
    mask1=[mask1; mask];
end
f_all = (c1-t1)./den1 .* mask1 * 6000;
[alaki h2] = read_img('act_con.img');
h2.tdim=size(f_all,1);
write_img('f_all.img',f_all,h2);
vf=var(f_all,1);
f = mean(f_all,1);

%h.datatype = 32;
%h.bits = 32;

write_img('f.img', f, h);
write_img('fv.img',vf,h);