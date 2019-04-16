function SufNec

option=2;
NTHR = 50; % this is the number of thresholds that gets used

switch(option)
    case 1
        
        % do two nodes:
        a = zeros(1000,1);
        b = zeros(1000,1);
        
        % generate two sets of random event times:
        a_inds = round(1000 * rand(20,1));
        a_inds2 = round(1000 * rand(20,1));
                
        xtra = round(1000*rand (20,1));
        
        % 
        a(a_inds) = 1;
        b(a_inds) = 1;        
        % if you want to see the random case do this instead:
        % b(a_inds2) = 1;
        % otherwise do this:
        % b(a_inds) = 1;
        
        
        % b(xtra) = 1;
        
        anoise = 0.05*randn(size(a));
        bnoise = 0.05*randn(size(a));
        
        a = a + anoise;
        b = b + bnoise;
        [Nab, Sab] = sufnec(a,b);
        
        Nab(isnan(Nab)) = 0;
        Sab(isnan(Sab)) = 0;
        
        Nintegral = sum(Nab(:))/NTHR
        Sintegral = sum(Sab(:))/NTHR
        
    case 2
        
        % do a five node network:
        X = Netsim;
        
        
        Nmat = zeros(5,5,50);
        Smat = zeros(5,5,50);
        
        AUCS = zeros(5,5);
        
        for n=1:5
            for m = 1:5
                [Nab Sab] = sufnec(X(:,n),X(:,m) );
                Nab(isnan(Nab)) = 0;
                Sab(isnan(Sab)) = 0;
                Nmat(n,m,:) = Nab;
                Smat(n,m,:) = Sab;
                AUCS(n,m) = ROC(Nab, Sab);
            end
        end
        
        Nmat = reshape(Nmat, 25,50);
        Smat = reshape(Smat, 25,50);
        
        % clean up the infs and NaNs
        for n=1:25
            tmp = Nmat(n,:);
            tmp = tmp(~isinf(tmp));
            tmp = tmp(~isnan(tmp));
            tmp = tmp(abs(tmp)<1);
            Nintegral(n) = mean(tmp);
        
            tmp = Smat(n,:);
            tmp = tmp(~isinf(tmp));
            tmp = tmp(~isnan(tmp));
            tmp = tmp(abs(tmp)<1);
            Sintegral(n) = mean(tmp);
        
        end
        
        Nintegral = reshape(Nintegral,5,5);
        Sintegral = reshape(Sintegral,5,5);
        
        
        
        figure(3)
        subplot(221)
        imagesc(Nintegral); title('Necessity')
        colorbar
        subplot(222)
        imagesc(Sintegral); title('Sufficiency')
        colorbar
        subplot(223)
        imagesc(AUCS); title('AUROC')
        colorbar
        
        colormap gray
        
        % Now try to see which direction is stronger 
        Nintegral2 = zeros(5,5);    
        Sintegral2 = zeros(5,5);    
        AUCS2 = zeros(5,5);
        for n=1:5
            for m=1:5
                Nintegral2(m,n) = Nintegral(m,n) - Nintegral(n,m);
                Sintegral2(m,n) = Sintegral(m,n) - Sintegral(n,m);
                AUCS2(m,n) = AUCS(m,n) - AUCS(n,m);
            end
        end
        
        % Eliminate the non-neighbors ... let's not worry about those
        mask = diag(ones(4,1),-1) + diag(ones(4,1),1);
        mask(1,5) = 1;
        mask(5,1) = 1;
        
        % Make it a binary decision: which way is the arrow?
        Nintegral2(Nintegral2<=0) = 0;
        Sintegral2(Sintegral2<=0) = 0;
        AUCS2(AUCS2<=0) = 0;

        Nintegral2(Nintegral2>0) = 1;
        Sintegral2(Sintegral2>0) = 1;
        AUCS2(AUCS2>0) = 1;
        
        Nintegral2 = Nintegral2 .*mask;
        Sintegral2 = Sintegral2 .*mask;
        AUCS2 = AUCS2 .*mask;
%         
        figure(87)
        subplot(221)
        imagesc(Nintegral2); title('Adj. Necessity')
        colorbar
        subplot(222)
        imagesc(Sintegral2); title('Adj. Sufficiency')
        colorbar
        subplot(223)
        imagesc(AUCS2); title('Adj. AUROC')
        colorbar
        
        colormap gray
        %
end
save DoSimVars

return
%%
function N = ncsty(A,B)
% Necessity = 1-P(B|~A);
%           = P(~B|~A)
% from Pearl's book (p. 292) , this is also
% PN = (P(B |A) - P(B|~A) ) / P(B|A)
%

An = ~A;
Bn = ~B;

p_A = sum(A) / length(A);
p_An = sum(An) / length(A);
p_AB = sum(A.*B)/length(A);
p_AnB = sum( An.*B)  / length(An) ;
p_AnBn = sum( An .* Bn ) / length(A) ;

p_BgA = p_AB/p_A;
p_BgAn = p_AnB/p_An;

%N = ( p_BgA - p_BgAn )/p_BgA;

N = p_AnBn / p_An;

return

%%
function S = sfcy(A,B)
% Sufficiency = P(B|A)
% alternative defn: N = P(B|A) - P(B|~A)
%
% from Pearl's Book, p. 292, this is also
%
% PS = (P(B|A) - P(B|~A))/(1-P(B|~A))
%

An = ~A;
Bn = ~B;

p_A = sum(A)/ length(A);
p_An = sum(An)/ length(An);
p_B = sum(B)/ length(B);
p_AB = sum(A .* B) / length(A);
p_AnBn = sum(An.*Bn) / length(An);
p_AnB = sum(An.*B) / length(An);
p_BgA = p_AB/p_A;
p_BgAn = p_AnB/p_An;

S = (p_BgA - p_BgAn)/(1-p_BgAn) ;

return

%%
function AUC = ROC(TPR, FPR)
% function AUC = ROC(TPR, FPR)

% plot the ROC:
figure(65)
plot(FPR,TPR)
xlabel('False Positive Rate')
ylabel('True Positive Rate')
title('ROC')
drawnow

% integrate the ROC curve using trapezoids
AUC = (TPR(2:end) + TPR(1:end-1) )/2 ;
AUC = AUC .* (FPR(2:end) - FPR(1:end-1));
AUC = sum(AUC);

return

function [Nab Sab] = sufnec(a,b)
Npts = 1000;
NTHR = 50;
doPlots = 0;

% scale the signal:
a = a /max(a); a=a-min(a);
b = b/max(b); b=b-min(b);

threshold =  linspace(0.5,3,NTHR);


stda = std(a);
stdb = std(b);

%stda = max(a)/100;
%stdb = max(b)/100;


%MI = mutual_info(a,b);

for n = 1:length(threshold)
    
    % BInarization part:  simple thresholding
    atmp = zeros(Npts,1);
    btmp = zeros(Npts,1);
    
    th = threshold(n);
    
    atmp(a< th*stda) = 0;
    atmp(a>=th*stda) = 1;
    
    btmp(b< th*stdb) = 0;
    btmp(b>=th*stdb) = 1;
    
    
    if doPlots
        figure(2)
        
        subplot(211)
        plot(a); hold on,
        line([0 Npts],[th*stda th*stda])
        stem(atmp);   hold off
        title('Node A')
        
        subplot(212),
        plot(b,'r');hold on,
        line([0 Npts],[th*stdb th*stdb])
        stem(btmp,'r'); hold off
        title('Node B')
    end
    Nab(n) =  ncsty(atmp,btmp);
    Sab(n) =  sfcy(atmp,btmp);

end

figure(4)
plot(threshold, Nab); hold on;
plot(threshold, Sab, 'r'); hold off
legend('Necessity', 'Sufficiency');
xlabel('Threshold (num. std. devs)')

return

%%


%%%
function Result = Netsim
Npts = 1000;

% activity in the node
X = zeros(Npts,5);
% inputs into the nodes
u = zeros(Npts,5);

% define an external influence on one of the nodes:
% random inputs into all nodes:
u = rand(Npts,5);
u(u<=0.99) = 0;
u(u>0) = 1;

% external inputs into nodes 3 and 5 are removed
u(:,3) = 0;
u(:,5) = 0;

dt = ones(1,5);

% self-coefficient (decay)
A = -0.9 * ones(1,5);

% xternal influence coefficient
B =  ones(1,5);
%B(4)=0;             % No external stimuli into 4.
% This will make it so that node 3 is necessary for node 4

% Direct influence coefficients - Sufficiency
C = zeros(5,5);

C(1,2) = 0.5;
C(2,3) = 0.5;
C(1,5) = 0.5;
C(5,4) = 0.5;

% calculate the  changes in activity at each time step
for n=2:Npts
    dXdt = ...
        X(n-1,:) .* A  +  ...
        u(n,:) .*B  +  ...
        X(n-1,:)* C;
    
    X(n,:) = X(n-1,:) + dXdt .* dt ;
end



h = spm_hrf(1);
for n=1:5
    tmp = conv(X(:,n), h);
    tmp = tmp(1:1000);
    X(:,n) = tmp ;
    Xdisplay(:,n) = tmp +1*n;
end

Result = X;

% introduce noise into the system
noisemat =  0.0005*randn(size(X));
X = X+noisemat;
Xdisplay = Xdisplay+noisemat;

% show the time courses on a nice plot:
figure(1)
subplot(2,1,1); plot(Xdisplay)
subplot(2,1,2), imagesc(C); title('Connection Weights')
return
%%%
