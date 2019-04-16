function f = casl_pid(ctlname, tagname, inv_alpha, Ttag, TR, pid, Ttrans, T1)
% function f = casl_pid(ctlname, tagname, inv_alpha, Ttag, TR, pid, Ttrans, T1)

%Ttag = 3.7;
%TR = 6;

c = read_img(ctlname);
t = read_img(tagname);

mask = zeros(size(c));
mask(find(c>0.2*max(c(:))))=1;

lambda = 0.9;
T1a = 1.65;
T1app=1/(1/T1 + 0.01/lambda);

M0 = c/(1 - exp(-TR/T1));

% This is equation 3 from Alsop et al: JCBFM 16, 1236-1249,1996
%den = T1app*2*M0*inv_alpha/lambda * exp(-Ttrans*(1/T1a-1/T1app))*exp(-pid/T1a);

% modification by Wang et al MRM 48,1,p242-254, 2002:
%den = T1app*2*M0*inv_alpha/lambda * ...
%    (exp(-Ttrans*(1/T1a-1/T1app)) - exp((Ttrans-pid-Ttag)/T1app))...
%    *exp(- pid/T1a);

% looking at equation 1, delta_a and delta should be almost the same, we
% can drop a term.
den =  - 2 * M0* inv_alpha / lambda ...
    *( T1app*exp(-Ttrans/T1a) * ( exp( (Ttrans-pid)/T1app ) - exp( (Ttrans-Ttag-pid)/T1app)));



f = (t-c)./den * 6000;
f = f.*mask;

h = read_hdr(ctlname);
write_img('Flow.img',f *100 ,h);
global SPM_scale_factor
SPM_scale_factor = 0.01;
write_hdr('Flow.hdr',h);

return
