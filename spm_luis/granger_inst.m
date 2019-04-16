function [Fab , Fba, chi2] = granger(a, b, DesMat, Nlag,  doPlots)
%
% function [Fab , Fba, chi2] = granger(a, b, DesMat, Nlag, doPlots)
%
% perform the Granger causality test on time courses (a and b)
% DesMat contains the known regressors as columns (design matrix)
% Nlag is the amount of lag considered as part of the causal structure.
%
% the models to estimate are
% b = c + b_AR*Beta + a_AR*Gamma + err1
% b = c + b_AR*Beta + err2
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
a = a - mean(a);
b = b - mean(b);

%%

duration = length(a);
a_AR = zeros(duration,Nlag);
b_AR = zeros(duration,Nlag);



for r=1:Nlag
    % Lag the time series by r points
    a_AR(:,r) = circshift(a,r);
%   a_AR(1:r,r) = 0;
    b_AR(:,r) = circshift(b,r);
%   b_AR(1:r,r) = 0;
end

% the models to estimate are
% b = c + b_AR*Beta + a_AR*Gamma + err1
% b = c + b_AR*Beta + err2

% computing F(a->b) based on our ability to model signal B with 
% the AR structure of signal A

% Xab is the full model:  both signals contribute to it
% Xab = [DesMat b_AR a_AR ];
% 10.9.07 include instantaneous terms 
%  Xabi = [DesMat  b_AR a_AR a ];
%  Xbai = [DesMat  b_AR a_AR b ];

Xab = [DesMat  b_AR  a_AR a ];
Xba = [DesMat  b_AR  a_AR b ];

% Xb is the model for node B without contribution from A
Xb = [DesMat b_AR  ];

% Xa is the model for node A without contribution from B
Xa = [DesMat a_AR ];

if doPlots
    subplot(311)
    imagesc(Xab);
    title('big model for both signals')

    subplot(312)
    imagesc(Xb);
    title('smaller  model for signal B')

    subplot(313)
    imagesc(Xa);   
    title('smaller model for A')
    drawnow
end

% Estimate the AR model for B
RSSb=sum((b-Xb*(Xb\b)).^2);

% Estimate the full model in time course B including contributions from A
RSSb0=sum((b-Xab*(Xab\b)).^2);

% Estimate the AR model for A
RSSa=sum((a-Xa*(Xa\a)).^2);

% Estimate the full model in time course A including contributions from B
RSSa0=sum((a-Xba*(Xba\a)).^2);

%%
% % Estimate the full model in time course B including contributions from A
% [t, beta_est, var_est, RSS] = my_glm(Xabi, b', ones(size(Xabi,2),1) );
% RSSb0i=RSS;
% 
% % Estimate the full model in time course A including contributions from B
% % [t, beta_est, var_est, RSS] = my_glm(Xab, a', ones(size(Xab,2),1) );
% [t, beta_est, var_est, RSS] = my_glm(Xbai, a', ones(size(Xbai,2),1) );
% RSSa0i=RSS;
%%

%
% Fab = ((RSS2-RSS1b)/Nlag) / (RSS1b/(duration-2*Nlag-1)) ;
% Fba = ((RSS3-RSS1a)/Nlag) / (RSS1a/(duration-2*Nlag-1));
%
chi2 = duration*(RSSb-RSSb0) / RSSb0 ;
Fab = log(RSSb/RSSb0);
Fba = log(RSSa/RSSa0);
%Fab = RSSb/RSSb0;
%Fba = RSSa/RSSa0;

return
