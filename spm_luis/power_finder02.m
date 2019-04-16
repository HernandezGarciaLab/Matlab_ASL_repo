function Result = power_finder02(x_effect,  x_var, alpha,  Spower_threshold, N_subjects, bf )
% function Result = power_finder02( x_effect,  x_var, alpha,  Spower_threshold, Nsubjects, bf)
%
% computes the Number of measurements
% to achieve a given Spower for a t-test accross
% several images of every voxel.
%
% Luis Hernandez
% University of Michigan
% Last Edit 1 - 12 -2011
%
% The null hypothesis is that each images has a value equal
% to the mean value of all the images in the group.
% The alternative hypothesis is that they are not (double sided test)
% a p-value less than alpha means that they are different.
%
% This function computes the probability of being right if we reject the
% null hypothesis of being equal, based on a given effect size.
%
% Arguments and defaults:
%   x_var:  variance of the data (this coule be variance of paramater estimates). cols = pixels
%   alpha: 	significance level (0.05)
%   bf :   	Bonferroni correction factor.
%   x_effect:   Effect size to be assumed when calculating the Spower -
%               image of parameter estimate
%   Spower_threshold:       Desired Spower level
%
%  Result=[current_Spower N Spower];




% x_effect = read_img(x_effect);
% x_var = read_img(x_var);

sigma_x = sqrt(x_var);;
alpha = alpha/(bf*2);  % 2-tailed Significance level after Bonferroni correction
Spower = 0;

% find critical Z score for this significance level(alpha)
% under the null distribution.
xcrit =  norminv(1-alpha, 0, sigma_x);

% what is the probability of getting that critical Z-score under alternative distribution  
q = spm_Ncdf(xcrit, x_effect, sigma_x);
Spower = 1-q;
current_Spower = Spower;

% Loop for an increasing number of subjects (up to three times as many subjects as we have...)
% set the upper bound to 50 data points required.
N = N_subjects;
while ( ( N < 50)   & (Spower < Spower_threshold)  )
    
    N = N+1;
    sigma_xn = sigma_x /(sqrt(N / N_subjects));
    
    % find critical Z score for this significance level(alpha)
    % under the null distribution.
    xcrit =  norminv(1-alpha, 0, sigma_xn);

    % what is the probability of getting that critical Z-score under alternative distribution  
    %q = normcdf(xcrit, x_effect, sigma_xn);
    %Spower = 1-q;

    q = spm_Ncdf(xcrit, x_effect, sigma_xn);
    Spower = 1-q;
    
%     fprintf('\n N=  %d   sigma_x = %2.2f   Effect = %2.2f xcrit = %2.2f       Power= %2.2f ', ...
%         N, sigma_xn,  x_effect, xcrit,  Spower*100);

end


Result=[current_Spower N Spower];



return

