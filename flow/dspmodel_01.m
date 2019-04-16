% this script checks the Buxton model against the modifications of the 
% Liu model to see if we can interpret my version of f as perfusion
% 12/6/08
lambda = 0.9;
alpha = 0.9;
Ttrans = 1.2 *1e3;
T1a = 1.6 * 1e3;
T1 =1.2 * 1e3;
f = 60 /6000 * 1e-3 ;  % change units to ml/ms/g from ml/min/100g
alphaprime = alpha*exp(-Ttrans/T1a);
Ttag = 5000;
TR = 10000;
Tdelay = 1300;

% Buxton Model from 1998
M0=1000;
c = zeros(1,15000);
t = [0:15000];

% retention function including T1 effects
retn = exp(-(f/lambda + 1/T1) .* t);
retn = retn / sum(retn);

% input function
for t=1:2*TR:length(c);
    c(t:t+Ttag) = 1;
end

dM = 2*alphaprime*M0*f * conv(c  , retn) ;
dM = dM(1:length(c));

plot(dM)
max(dM)

% the above convolution is something like
t = [0:15000];
mydM2 = 2*alphaprime*f*M0 *(1 - exp(-(f/lambda + 1/T1).* t));
hold on; plot(mydM2,'g') ; hold off

% My model is for steady state!
control = M0;
tag = (M0*(1-f) + M0*f*(1-2*alphaprime));
mydM = (control-tag)

