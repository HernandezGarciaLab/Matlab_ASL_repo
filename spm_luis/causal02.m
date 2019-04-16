function [Pratio, mi, H_asymmetry, rho] = causal02(a,b);
%function [Pratio, mi, H_asymmetry, rho] = causal02(a,b);
% detrend
doPlots=0;



%dummy = smoothdata(a, 1, 0.3, 4 , 1);

a = smoothdata(a, 1, 0.3, 4);
b = smoothdata(b, 1, 0.3, 4);

a = mydetrend(a);
b = mydetrend(b);

% normalize
a = a./sum(abs(a));
b = b./sum(abs(b));

aRange=[0 inf];
bRange =[0 Inf];

[Pa_b, Pb_a, jointhist, Pa, Pb, Pab ] = cprob(a,aRange, b, bRange);
Pratio = Pa_b/Pb_a;

if doPlots
    figure
    subplot(211)
    plot(a), hold on, plot(b,'r'), hold off, legend('A','B'),  title('Timeseries'),fat
    line([ 1 length(a)], [aRange(1) aRange(1)]);
    subplot(212)
    imagesc(jointhist);
    amin = min([a b]);
    amax = max([a b]);
    a_delta = (amax - amin) / Nbins;

    mytixlabel = round([amin:a_delta*5:amax]*10)/10;
    mytix = 1:5:Nbins;
    set(gca,'XTick',mytix)
    set(gca,'YTick',mytix)
    set(gca,'XTickLabels',mytixlabel)
    set(gca,'YTickLabels',mytixlabel)
    hand=line([0 Nbins],[0 Nbins])
    set(hand,'LineWidth',4,'Color','white')
    colorbar

    %surf(jhist)
    xlabel('B')
    ylabel('A')

    title('Joint Histogram')
    axis square, dofontsize(14)
end

% calculate the energy in the two sides of the histogram
AgtB=0;
BgtA=0;


for acount=1:length(jointhist)
    for bcount=acount:length(jointhist)
        BgtA = BgtA + jointhist(acount, bcount);
    end
    for bcount=1:acount
        AgtB = AgtB + jointhist(acount, bcount);
    end
end

H_asymmetry = (AgtB - BgtA)/(AgtB + BgtA);


% now compute the mutual information  (this code is lifted from spm_mireg.m
% the definition (from Mathworkd) is 
% I(X,Y) = sum_y(sum_x(P(X,y)*log2(P(x,y)/(P(X)*P(Y))))
H  = jointhist/(sum(jointhist(:))+eps);
s1 = sum(H,1);
s2 = sum(H,2);
H  = H.*log2((H+eps)./(s2*s1+eps));
mi = sum(H(:));

% get a corr. coefficient to top ot off
rho = corrcoef(a,b);
rho = rho(1,2);

save casual02vars
return




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