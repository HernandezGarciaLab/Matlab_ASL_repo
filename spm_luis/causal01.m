% other tests for causality
close all
% conditional probability
duration=200;
TR=1;
SECONDS=1;
noise = 0.1;
hrf_var = 0.1;
nevents = 10;
extra_events = 5;
threshold = 0.3;
binsize = 2;
NITER = 10;
doPlots =1;


all_rho = zeros(1,NITER);
all_H_asymmetry = zeros(1,NITER);
all_Pa_b = zeros(1,NITER);
all_Pb_a = zeros(1,NITER);
all_dom = zeros(1,NITER);
all_mi = zeros(1,NITER);
subplot(224)


for iter=1:NITER
    fprintf('\riteration: %d',iter);
    a = zeros(duration,1);
    b = zeros(duration,1);

    % make the onset times
    iti_a = rand(nevents,1)*5 + 12;
    iti_b = iti_a;

    onsets_a = round(cumsum(iti_a));
    onsets_b = round(cumsum(iti_b));

    % add some extra events in b
    onsets_b = [onsets_b ;
        1+round(rand(extra_events,1)*(duration-3))];

    % randomize the HRF dispersion parameters to reflect physiology
    tau = 1 + randn(2,1) * hrf_var;

    hrf_a = spm_hrf(TR, [6 16 tau(1) tau(1) 6 0 32]);
    hrf_b = spm_hrf(TR, [6 16 tau(2) tau(2) 6 0 32]);
    
    hrf_a = hrf_a / max(hrf_a);
    hrf_b = hrf_b / max(hrf_b);
    
    if doPlots
        figure(3)
        plot(hrf_a)
        hold on
        %plot(diff(hrf_a),'g')
        plot(hrf_b,'r')
        hold off
        drawnow
    end

    % the A paradigm is the same as the B paradigm + additional stuff
    a(onsets_a) = 1;
    b(onsets_b) = 1;

    a = conv(a, hrf_a);
    b = conv(b, hrf_b);

    a = a(1:duration);
    b = b(1:duration);


    %put some noise in.
    a = a + noise*randn(size(a));
    b = b + noise*randn(size(b));

    % filtering and other conditioning here:
    a = smoothdata(a, 1, 0.3, 4);
    b = smoothdata(b, 1, 0.3, 4);

    a = a/sum(abs(a));
    b = b/sum(abs(b));

    a = a - mean(a);
    b = b - mean(b);
    
    
    
    
    % find the events
    a_events = indicator(a, threshold, binsize);
    b_events = indicator(b, threshold, binsize);

    if doPlots
        figure(1)
        subplot(211), plot(100*a,'r'), hold on, plot(100*b)
        title('Preconditioned FMRI Time Courses ')
        legend('A', 'B')
        line([ 1 length(b)], [threshold*std(b) threshold*std(b)]);
        line([ 1 length(a)], [threshold*std(a) threshold*std(a)],'Color','r');
        dofontsize(16);
        hold off        
        
        subplot(212), 
        stem(a_events,'r'), hold on, stem(b_events,'--');
        title(sprintf('Detected Events ( Dominance = %f)',dom));
        legend('A', 'B')
        dofontsize(16);
        hold off
        drawnow
        
    end

    % signals are ready .  Let's do the tests
    % find the conditional and joint probs.
    [Pa_b, Pb_a, Pa, Pb, Pab ] = cprob02(a_events,b_events);

    [Pa_b, Pb_a, Pa, Pb, Pab ];

    % Now do the Dominance measure:
    Pratio = Pa_b/Pb_a;
    dom = Pb_a - Pa_b;  % if this is high, A is domendant to B.
    %dom = abs(Pb_a - Pb) - abs(Pa_b - Pa);  % if this is high, A "causes" B.
    
  
    Nbins=20;
    jointhist = jhist(a,b, Nbins);

    if doPlots
        figure(2)
        axis xy
        imagesc(jointhist);
        amin = min([a b]);
        amax = max([a b]);
        a_delta = (amax - amin) / Nbins;

        hand=line([0 Nbins],[0 Nbins]);
        set(hand,'LineWidth',4,'Color','white');
        axis square
        colorbar
        xlabel('B')
        ylabel('A')

        title('Joint Histogram')
        dofontsize(16);
        axis square
        drawnow
        pause
    end

    % calculate the energy in the two sides of the histogram
    AgtB=0;
    BgtA=0;

    for acount=2:length(jointhist)
        AgtB = AgtB + sum(jointhist(acount, 1:acount-1));
        BgtA = BgtA + sum(jointhist(acount, acount+1:end));
    end

    H_asymmetry = (AgtB - BgtA)/sum(jointhist(:));


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

    all_rho(iter) = rho;
    all_H_asymmetry(iter) = H_asymmetry;
    all_Pa_b(iter) = Pa_b;
    all_Pb_a(iter) = Pb_a;
    all_dom(iter) = dom;
    all_mi(iter) = mi;
    
end

figure
subplot 321 , hist(all_rho,50) , title('Rho')
subplot 322 , hist(all_H_asymmetry,50), title('H_asymmetry')
subplot 323 , hist(all_Pb_a,50), title('P(B|A)')
subplot 324 , hist(all_Pa_b,50), title('P(A|B)')
subplot 325 , hist(all_dom,50), title('Dominance: P(B|A) - P(A|B)')
subplot 326 , hist(all_mi,50),  title('Mutual Information')

figure
subplot 311 , hist(all_rho,50) , title('Correlation'), dofontsize(16)
subplot 312 , hist(all_mi,50),  title('Mutual Information'), dofontsize(16)
subplot 313 , hist(all_dom,50), title('Dominance: P(B|A) - P(A|B)'), dofontsize(16)

save simulations
