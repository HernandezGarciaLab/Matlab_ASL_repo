% This function is an attempt to linearize the kinetic eqiuation 
% in order to speed up the fit of transit time
%

t = linspace(0,2.5,10);
r1 = 1/1.4;
r1a = 1/1.6;
delta = 1.2;
f = 0.01;
m = 100;

signal = m*exp(-delta*r1a).*(1-exp(-(t-delta)*r1));

signal(t<delta) = 0;
plot(t,signal)

data = signal(signal>0.01);
t = t(signal>0.01);

data = data';
t =t';

X = [ones(size(t)) t (t.^2) ]
Xm = mean(X);
Xm(1) = 0;
X = X - repmat(Xm,length(t),1)

betahat = pinv(X)*data

yhat = X*betahat;

deltahat = -log(betahat(2)/m) / (r1a^2)

deltahat = -log(betahat(1)/m) / (r1a)
