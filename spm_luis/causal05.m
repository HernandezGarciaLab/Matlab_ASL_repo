function [dominance, ascend, mi, rho, d2] = causal05(a,b, doFilter);
%function [dominance, ascend, mi, rho, d2] = causal05(a, b, doFilter);
%
% (c) 2005 Luis Hernandez-Garcia 
% University of Michigan
% report bugs to:  hernan@umich.edu
%
% this function:
% 1) filters two time courses, normalizes and mean centers them
%    this version has a hard wired filter that removes top half of spectrum
% 2) binarizes them with an indicator function (indicator.m)
% 3) computes the dominance (ie - P(B|A) - P(A|B) 
% 4) computes a joint histogram of the 2 time courses (jhist..m)
% 5) computes the mutual information
% 6) computes the correlation coefficient
% 7) computes the ascendency
%
% d2 is dominance also, but computed from dominance scaled by the conditional
% probabilities.  Good sanity check
%

doPlots=0;
threshold = 1;
% global threshold
% bins for the dominanceendency
binsize = 2;
% bins for the joint histogram
Nbins = length(a)/10;

a = reshape(a,1, length(a));
b = reshape(b,1, length(b));

%dummy = smoothdata(a, 1, 0.3, 4 , 1);
if doFilter
    % the following filter taps were designed with this:
    % cutoff = 0.5;
    % N_coeffs = 10;
		% taps = remez(N_coeffs, [0 cutoff-0.05  cutoff+0.05  1], [1 1 0 0]);
	  taps=[0.0865 -0.0535 -0.1288  -0.0023 0.2976 0.4618 0.2976 -0.0023  -0.1288 -0.0535 0.0865];
    % taps for cutoff 0.3
    taps= [-0.1058 -0.0348 0.0416 0.1589 0.2661 0.3094 0.2661  0.1589 0.0416 -0.0348 -0.1058];
    if doPlots
         tmpa = a-mean(a);
         tmpb = b-mean(b);
         tmpa = tmpa/(sum(tmpa.^2));
         tmpb = tmpb/(sum(tmpb.^2));
    end
    a = filtfilt(taps,1,a);
    b = filtfilt(taps,1,b);

    a = mydetrend(a', 0);
    b = mydetrend(b', 0);
end
   
% zero mean the data
a = a - mean(a);
b = b - mean(b);

% normalize the energy
a = a/sum(a.^2);
b = b/sum(b.^2);


a_events = indicator(a, threshold, binsize);
b_events = indicator(b, threshold, binsize);

% Definition of Ascendancy in Patel's paper (HBM 2005)
% find the conditional and joint probs.
N = length(a_events);
thetas = zeros(1,4);
Nevents = zeros(1,4);

Nevents(1) = sum(a_events & b_events);
Nevents(2) = sum(a_events & ~b_events);
Nevents(3) = sum(~a_events & b_events);
Nevents(4) = sum(~a_events & ~b_events);

thetas = Nevents / N;

% My dominance calculation:  P(b|a) - P(a|b)
Pab = thetas(1);
% P(b|a) = P(ab) / P(a)
Pb_a  = thetas(1) / (thetas(1) + thetas(2));
% P(a|b) = P(ab) / P(b)
Pa_b  = thetas(1) / (thetas(1) + thetas(3));
dominance = Pb_a - Pa_b;

% Ascendancy calculation:
if thetas(2) > thetas(3)
    ascend = 1 - (thetas(1) + thetas(3))/(thetas(1) + thetas(2));
    d2 = -Pa_b*ascend;
else
    ascend = (thetas(1) + thetas(2))/(thetas(1) + thetas(3))-1;
    d2 = -Pb_a*ascend;
end


jointhist = jhist(a,b, Nbins);
    
if doPlots
    
    subplot(221)
    plot(a), hold on, plot(b,'r--'),  legend('A','B'),  title('Timeseries')
    plot(tmpa), hold on, plot(tmpb,'r--'),  legend('A','B'),  title('Timeseries')
    line([ 1 length(a)], [threshold*std(a) threshold*std(a)]);
    line([ 1 length(b)], [threshold*std(b) threshold*std(b)],'Color','r');
    axis tight 
    hold off
    subplot(223)
    stem(a_events), hold on, stem(b_events,'r--') , hold off
    title(sprintf('dominance : %f', dominance))


    subplot(222)
    imagesc(jointhist);
    amin = min([a b]);
    amax = max([a b]);
    a_delta = (amax - amin) / Nbins;

    mytixlabel = round([amin:a_delta*5:amax]*10)/10;
    mytix = 1:5:Nbins;
    set(gca,'XTick',mytix);
    set(gca,'YTick',mytix);
    set(gca,'XTickLabels',mytixlabel);
    set(gca,'YTickLabels',mytixlabel);
    hand=line([0 Nbins],[0 Nbins]);
    set(hand,'LineWidth',4,'Color','white');
    axis square
    colorbar

    %surf(jhist)
    xlabel('B')
    ylabel('A')

    title('Joint Histogram')
    axis square
    drawnow
end

% calculate the energy in the two sides of the histogram
AgtB=0;
BgtA=0;


%H_asymmetry = (AgtB - BgtA)/(AgtB + BgtA);
H_asymmetry = 0;

% now compute the mutual information  
% This code is lifted from spm_mireg.m
% the definition (from Mathworkd) is 
% I(X,Y) = sum_y(sum_x(P(X,y)*log2(P(x,y)/(P(X)*P(Y))))
% so it's not exactly the same...
H  = jointhist/(sum(jointhist(:))+eps);
s1 = sum(H,1);
s2 = sum(H,2);
H  = H.*log2((H+eps)./(s2*s1+eps));
mi = sum(H(:));

% get a corr. coefficient to top ot off
rho = corrcoef(a,b);
rho = rho(1,2);

save causal05vars
return

% Everything below is NOT used.  Just leftovers


% testing for delays in cross correlations
paradigm=zeros(1,duration);
for delay=20:50:duration
    h = make_hrf(delay,3,duration);
    paradigm  = paradigm + h;
end

a = paradigm;

paradigm=zeros(1,duration);
for delay=25:50:duration
    h = make_hrf(delay,3,duration);
    paradigm  = paradigm + h;
end
b = paradigm;

%put some noise in.
a=a+noise*randn(size(a));
b=b+noise*randn(size(b));

xc = xcorr(a,b);
figure
subplot(221)
plot(a),hold on, plot(b,'r'), title('Timeseries'), fat
subplot(222)
plot(xc), title('Cross correlation'),grid on, fat
subplot(223)
plot(abs(fft(xc))), title('FT(XC) magnitude'), fat
subplot(224)
plot(angle(fft(xc))), title('FT(XC) phase'), fat

% Granger Causality test
% form two auto-regressive models for the data (A)
% one contains only A, the other one contains A and B

Nlag=3;
a_model = zeros(length(a),Nlag);
b_model = zeros(length(a),Nlag);

for r=1:Nlag
    % Lag the time series by r  
    tmp = [zeros(1,r-1) a(1:end-r+1) ];
    a_model(:,r) = tmp';
    tmp = [zeros(1,r-1) b(1:end-r+1) ];
    b_model(:,r) = tmp';
end

% the models to estimate are
% b = c + b_model*Beta + a_model*Gamma + err1
% b = c + b_model*Beta + err2

t=my_glm([b_model a_model], b', ones(2*size(a_model,2),1) );
load glm
RSS1=RSS
figure
subplot(211)
bar(beta_est), title('Betas of the bigger model')
fat
axis([0 (Nlag+1)*2 -0.02 1])

t=my_glm(b_model, b', ones(size(b_model,2),1) );
load glm
RSS2=RSS
subplot(212)
bar(beta_est), title('Betas of the smaller model')
axis([0 (Nlag+1)*2 -0.02 1])
fat
F = ((RSS1-RSS2)/Nlag) / (RSS1/(duration-2*Nlag-1)) 
chi2 = duration*(RSS1-RSS2) / RSS1 
