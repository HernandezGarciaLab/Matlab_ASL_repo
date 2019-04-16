function f = calcPerf( cfile, tfile, outfile, TR, Ttag, pid, Ttrans, inv_alpha)
%
%function f = calcPerf( cfile, tfile, outfile, TR, Ttag, pid, Ttrans, inv_alpha)
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

lambda = 0.9;
T1 = 1.25;
T1a = 1.65;
T1app=1/(1/T1 + 0.015/lambda);


[c h] = read_img(cfile);
[t h] = read_img(tfile);

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

h.datatype = 32;
h.bits = 32;

write_img( outfile, f, h);