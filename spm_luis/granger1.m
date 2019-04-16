function [Fab , Fba, chi2] = granger1(a, b, Xmodel, Nlag,  doPlots)
%
% function [Fab , Fba, chi2] = granger(a, b, Xmodel, Nlag, doPlots)
%
% perform the Granger causality test on time courses (a and b)
% Xmodel contains the known regressors as columns (design matrix)
% Nlag is the amount of lag considered as part of the causal structure.
%
% the models to estimate are
% b = c + b_model*Beta + a_model*Gamma + err1
% b = c + b_model*Beta + err2
%
% High Fab tests indicate that A Granger-causes B
% High F = Fab - Fba also indicates it with more stat. power?
%
% (c) 2006 Luis Hernandez-Garcia 
% University of Michigan
% report bugs to:  hernan@umich.edu
%

% first make sure the dimensions of the data are right:
a = reshape(a,length(a),1);
b = reshape(b,length(b),1);

%%  10.9.07 : mean center,
%a = a - mean(a);
%b = b - mean(b);
%%

T = length(a);
a_model = zeros(T,Nlag);
b_model = zeros(T,Nlag);

for r=1:Nlag
    % Lag the time series by r points
    a_model(:,r) = circshift(a,r);
    a_model(1:r,r) = 0;
    b_model(:,r) = circshift(b,r);
    b_model(1:r,r) = 0;
end

% the models to estimate are
% b = c + b_model*Beta + a_model*Gamma + err1
% b = c + b_model*Beta + err2

% computing F(a->b) based on our ability to model signal B with 
% the AR structure of signal A

% Xab is the full model:  both signals contribute to it
% Xab = [Xmodel b_model a_model ];
% 10.9.07 include instantaneous terms 
Xab = [Xmodel b_model a_model a];
Xba = [Xmodel b_model a_model b];

if doPlots
    subplot(311)
    imagesc(Xab);
    title('big model for both signals')
end

% Xb is the model for node B without contribution from A
Xb = [Xmodel b_model ];
if doPlots
    subplot(312)
    imagesc(Xb);
    title('smaller  model for signal B')
end
RSSb=sum((b-Xb*(Xb\b)).^2);

%[t, beta_est, var_est, RSS] = my_glm(Xb, b', ones(size(Xb,2),1) );
%RSSb=RSS;


% Xa is the model for node A without contribution from B
Xa = [Xmodel a_model];
if doPlots
    subplot(313)
    imagesc(Xa);   
    title('smaller model for A')
end
RSSa=sum((a-Xa*(Xa\a)).^2);
%[t, beta_est, var_est, RSS] = my_glm(Xa, a', ones(size(Xa,2),1) );
%RSSa=RSS;

% Estimate the full model in time course B including contributions from A
RSSb0=sum((b-Xab*(Xab\b)).^2);
%[t, beta_est, var_est, RSS] = my_glm(Xab, b', ones(size(Xab,2),1) );
%RSSb0=RSS;

% Estimate the full model in time course A including contributions from B
% [t, beta_est, var_est, RSS] = my_glm(Xab, a', ones(size(Xab,2),1) );
RSSa0=sum((a-Xba*(Xba\a)).^2);
%[t, beta_est, var_est, RSS] = my_glm(Xba, a', ones(size(Xba,2),1) );
%RSSa0=RSS;
%
% Fab = ((RSS2-RSS1b)/Nlag) / (RSS1b/(duration-2*Nlag-1)) ;
% Fba = ((RSS3-RSS1a)/Nlag) / (RSS1a/(duration-2*Nlag-1));
%
chi2 = T*(RSSb-RSSb0) / RSSb0 ;
Fab = log(RSSb/RSSb0);
Fba = log(RSSa/RSSa0);
%Fab = RSSb/RSSb0;
%Fba = RSSa/RSSa0;

return
