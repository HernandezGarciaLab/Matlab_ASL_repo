
TR = 1.5;
%tlen = length(data);
tlen = 300
rho = 0.8;
VarR = 1;
noise_amp=1;

% BOLD effects
Xbe = zeros(tlen,1);
isi = [1:30 60:90 120:150 180:210 240:tlen];

Xbe(round(isi))=1;

Xbe = conv(Xbe,spm_hrf(TR));
Xbe = Xbe(1:tlen);
Xbe = Xbe/max(Xbe);
Xbe = Xbe;

%%% Build ASL design mtx

% modulation of the effect
mm = ones(size(Xbe));
mm(1:2:end)=-1;
mm = mm/2;

Xfe= Xbe .* mm;


% baseline perfusion signal
Xbf = ones(size(Xbe)) .*mm;

% baseline BOLD signal:
Xbb = ones(size(Xbe));


% put it all together:
% note that in the baseline case we use only the tag to prevent
% too much colinearity with the activation vector
X = [Xbb Xbf Xbe Xfe];

% absolutely phony data:

data = sum(X,2);

% a better way to create AR1 noise?
% note - now we vary SNR by changing the amplitude of the effect
% Vo = spm_Q(rho,tlen);  % Correlation matrix
Vo = WKfun('AR+WN',rho,VarR,tlen);
% This is just a safety measure,to force homogeneous variance:
Vo = WKfun('Cov2Cor',Vo);
% Variance-covariance matrix
V = Vo * noise_amp^2;
% W = V^(-1/2) to make inversions easier down the line...
W = WKfun('mkW',[],V);

data = Vo*data;

t=0:tlen-1;

Bhat = pinv(W*X)*W*data;
effect_size = Bhat(4);

% recall that W = V^(-1/2)
var_Bhat = pinv(W*X)*W*V*W'*(pinv(W*X))';
var_Bhat = diag(var_Bhat);

eff = 1./var_Bhat;
eff_rel = eff / eff(2);

% Power calculation given mean, std.dev, and known effect size
% we'll test the power of estimation of the second B param.
alpha = 0.05;
df = length(X) - length(Bhat);


% find which value of beta_hat corresponds to the
% significance level alpha
% in the null dustribution:
tcrit =  spm_invTcdf(1-alpha, df);
bcrit = tcrit * sqrt(var_Bhat);
q = spm_Ncdf(bcrit, effect_size, sqrt(var_Bhat));

Spower = 1-q;

% power of this specific test, assuming that the effect size is the Bhat
q = spm_Ncdf(Bhat, Bhat, sqrt(var_Bhat));

Spower = 1-q;
