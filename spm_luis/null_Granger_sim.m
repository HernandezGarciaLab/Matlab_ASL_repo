function result = null_Granger_sim

% pseudo code for jillian


s2 = 0.05;  % white noise level relative to signal

%%%%%%%% Define HRF %%%%%%%%%%
tau1=17;
tau2=42;
TP = 10;  % number of true positive events;
T = 200;  % duration of the time course:  change to match what we have...

% this is your true HRF
Hrf_A = HRF_mat(tau1, tau2, T);

% for s2 = 0:0.02:0.5  % iterate over noise level ?

allmTPR =[];
allmFPR =[];

for h_err = linspace(0,5,5)  % iterate over errors in the HRF model
	fprintf('    HRF error:  %f  \n', h_err);

	HB = HRF_mat(tau1+h_err, tau2, T);


		for count=1 %:50  % iterations for ROC samples

			% generate a neuronal activity function
			if events
			%%%%%% Define the event sequence %%%%%%%%%
			x = zeros(T,1);
			onsets = (T-15)* rand(TP,1) +1;
			x(round(onsets)) = 1;
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			else
				x = rand(T,1);
			end
			
			%%%%%%%%%% generate noise %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			n = sqrt(s2)*randn(T,1);
			s2eta=2.3/0.4*s2;
            w=filter(1-ARrho,[1 -ARrho],sqrt(s2eta)*randn(T,1));
            v=sqrt(s2)*randn(T,1);
            n=w+v;
            n=n*sqrt(0.12)/std(n);
			
			% convolve with HRF and add noise
			A = Hrf_A*x + n;
			A = A-mean(A);
			
			%%%%%%%%%% same thing for signal B %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			n = sqrt(s2)*randn(T,1);
			s2eta=2.3/0.4*s2;
            w=filter(1-ARrho,[1 -ARrho],sqrt(s2eta)*randn(T,1));
            v=sqrt(s2)*randn(T,1);
            n=w+v;
            n=n*sqrt(0.12)/std(n);
			B = Hrf_B*x + n;
			B = B-mean(B); 
			
			[Fa Fb chi2] = granger(A, B, [], 1, 1);
			grangerF( ) = Fab - Fba;
		end
end
%%
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

Xab = [DesMat  b_AR  a_AR  ];
Xba = [DesMat  b_AR  a_AR  ];

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

			
%%%%%%%%%%%
function H = HRF_mat(tau1, tau2, T)
% function H = HRF_mat(tau1, tau2, T)
%
% tau1 = dispersion of the reponse (in samples),
% tau2 = dispersion of undershoot (in samples),
% T = number of points in the timecourse
%
% this function generates an impulse reponse function and uses
% it to build a system matrix so that you can quickly make HRF
% timecourses instead of convolving.  You can use that system matrix
% also to solve the minimization problems



h = inline(' (t).^(tau1).*exp(-t)/gamma(tau1) - 0.1*(t).^(tau2).*exp(-t)/gamma(tau2)',...
    'tau1','tau2','t');
t = [0:2:2*T-2]';

hh = h(tau1,tau2, t+7);
hh = hh - mean(hh);
hh = hh/norm(hh);

% hh1 = hh;
% hh = zeros(size(t));
% hrf = spm_hrf(1);
% hh(1:length(hrf)) = hrf;


hh = hh - mean(hh);
hh = hh/norm(hh);

%plot(hh); hold on, plot(hh1,'r'), axis([0 30 -0.5 1])

H = toeplitz( [hh(1); zeros(T-1,1)], hh')';

H = H(:,1:T);
for i=1:T,
    H(:,i)=H(:,i)/norm(H(:,i));
end

H = H-ones(T,1)*mean(H);


return
