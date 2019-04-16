% other tests for causality
% this version includes intantaneous terms into the Granger causality 
% computation to see if they indeed make a difference

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
NITER =  1000;
NXITER = 10;
doPlots = 1;
Today = date;

% Granger Params.
Xmodel = [];
Nlag = 1;

%ARX structure parms:
AA1(1:Nlag) =  0.7;
AB1(1:Nlag) = 0.3;
BB1(1:Nlag) = 0.7;
BA1(1:Nlag) = 0.01;

if 0
    %ARX structure parms: zeroed to test how things look without it.
    AA1(1:Nlag) =  0;
    AB1(1:Nlag) = 0;
    BB1(1:Nlag) = 0;
    BA1(1:Nlag) = 0;
end
% % let's try an AR2 example
% Nlag = 2;
% AA1 = [0.7 0.1];
% BB1 = [0.7 0.1];
% AB1 = [1 0.1];
% BA1 = [0 0];

% here we play with the dispersion parameters of the hrfs in the two 
% signals:
%tau = [1.2, 1.2];

all_theta = zeros(4,NITER);
all_rho = zeros(1,NITER);
all_G = zeros(1,NITER);
all_Fab = zeros(1,NITER);
all_Fba = zeros(1,NITER);
all_G_inst = zeros(1,NITER);
all_Fab_inst = zeros(1,NITER);
all_Fba_inst = zeros(1,NITER);
all_dom = zeros(1,NITER);
all_mi = zeros(1,NITER);


for iter=1:NITER

%     if mod(iter,NXITER)==0
%          extra_events = extra_events+1
%     end
    
    a = zeros(duration,1);
    b = zeros(duration,1);

    % make the onset times
    iti_a = rand(nevents,1)*5 + 12;
    %iti_a = rand(nevents,1)*5 + 20;
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

    hrf_c = spm_hrf(TR);
    
    hrf_a = hrf_a / max(hrf_a);
    hrf_b = hrf_b / max(hrf_b);
    
    if 0
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

    % save original events for comparison
    ae1 = a;    be1 = b;
    
    a = conv(a, hrf_a);
    b = conv(b, hrf_b);

    a = a(1:duration);
    b = b(1:duration);
    
    %put some noise in.
    a = a + noise*randn(size(a));
    b = b + noise*randn(size(b));

    % save the original BOLD timecourses for debugging
    a1 =a; b1 = b;

    % introduce the ARX structure:
    for n=Nlag+1:duration
        for lag=1:Nlag
            a(n) = a(n) + AA1(lag)*a(n-lag) +  BA1(lag)*b(n-lag);
            b(n) = b(n) + BB1(lag)*b(n-lag) +  AB1(lag)*a(n-lag);
        end
    end

    % save the original BOLD timecourses for debugging
    a_raw =a; b_raw = b;


    % filtering and other conditioning here:
    %a = smoothdata(a, 1, 0.3, 4);
    %b = smoothdata(b, 1, 0.3, 4);
    a = LPFilter01(a,0);
    b = LPFilter01(b,0);
    
    a = mydetrend(a');
    b = mydetrend(b');
    
    a = a/sum(abs(a));
    b = b/sum(abs(b));


%     a = a - mean(a);
%     b = b - mean(b);
     a = a - min(a);
     b = b - min(b);

    % find the events
    a_events = indicator(a, threshold, binsize);
    b_events = indicator(b, threshold, binsize);
    
    
    if doPlots  & iter==1
        figure(1)
        subplot(211), plot(100*a,'r'), hold on, plot(100*b)
        stem(ae1,'r'), stem(be1,'--b')
        title('Preconditioned FMRI Time Courses ')
        legend('A', 'B')
        line([ 1 length(b)], [threshold*std(b) threshold*std(b)]);
        line([ 1 length(a)], [threshold*std(a) threshold*std(a)],'Color','r');
        dofontsize(16);
        hold off        
        
        subplot(212), 
        stem(a_events,'r'), hold on, stem(b_events,'--');
        title('Detected Events ');
        legend('A', 'B')
        dofontsize(16);
        hold off
        drawnow
    		    
    end

    % signals are ready .  Let's do the tests
    % find the conditional and joint probs.
    [D, thetas ] = Dominance(a_events,b_events);
    
    [Fab , Fba, chi2] = granger(a_raw, b_raw, Xmodel, Nlag,  0);
    [Fab_inst, Fba_inst, chi2_inst] = granger_inst(a_raw, b_raw, Xmodel, Nlag,  0);
    
    grangerF = Fab - Fba;
    grangerF_inst = Fab_inst - Fba_inst;
    
    % get a corr. coefficient to top ot off
    rho = corrcoef(a,b);
    rho = rho(1,2);
    
    %get mutual information too
    mi = mutual_info(a,b);
    
    all_thetas (iter,:) = thetas;
    all_Fba(iter) = Fba;
    all_Fab(iter) = Fab;
    all_rho(iter) = rho;
    all_dom(iter) = D;
    all_mi(iter) = mi;
    all_G(iter) = grangerF;

    all_Fba_inst(iter) = Fba_inst;
    all_Fab_inst(iter) = Fab_inst;
    all_G_inst(iter) = grangerF_inst;

    fprintf('\riteration: %d D= %2.3f G= %2.3ff',iter, D, grangerF);
end


figure
subplot(221), hist(all_dom,20, 'k'), title(sprintf('Dominance  %f', mean(all_dom))), dofontsize(16)
subplot(222), hist(all_mi,20,'k'), title(sprintf('Mutual Info %f', mean(all_mi))), dofontsize(16)
subplot(223), hist(all_G,20), title(sprintf('Granger %f', mean(all_G))), dofontsize(16)
subplot(224), hist(all_Fab,20,'k'), title(sprintf('F_a_b  %f', mean(all_Fab))), dofontsize(16)


figure
subplot(321), hist(all_Fab,20,'k'), title(sprintf('mean F_{ab} = %0.3f', mean(all_Fab))), dofontsize(16), axis([0 1.5 0 200])
subplot(322), hist(all_Fab_inst,20,'k'), title(sprintf('mean F_{ab inst} = %0.3f', mean(all_Fab_inst))), dofontsize(16), axis([0 1.5 0 200])
subplot(323), hist(all_Fba,20,'k'), title(sprintf('mean F_{ba} = %0.3f', mean(all_Fba))), dofontsize(16), axis([0 1.5 0 200])
subplot(324), hist(all_Fba_inst,20,'k'), title(sprintf('mean F_{ba inst} = %0.3f', mean(all_Fba_inst))), dofontsize(16), axis([0 1.5 0 200])
subplot(325), hist(all_G,20,'k'), title(sprintf('mean GF = %0.3f', mean(all_G))), dofontsize(16), axis([0 1 0 200])
subplot(326), hist(all_G_inst,20,'k'), title(sprintf('mean GF_{inst} = %0.3f', mean(all_G_inst))), dofontsize(16), axis([0 1 0 200])

save GrangerDominanceSims_inst

mean(all_dom)
mean(all_G)
mean(all_G_inst)
