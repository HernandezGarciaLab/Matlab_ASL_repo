
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
NITER = 10000;
doPlots =1;
FWHM = 2;
co = 0.95;
eventsa = [];
eventsb = [];
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

%     if doPlots
%         figure(3)
%         plot(hrf_a)
%         hold on
%         %plot(diff(hrf_a),'g')
%         plot(hrf_b,'r')
%         hold off
%         drawnow
%     end

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
    aa = zeros(length(a),1);
    bb = zeros(length(b),1);
    spm_smooth(a,aa,FWHM);
    spm_smooth(b,bb,FWHM);

%     figure
%     plot(aa,'-r');
%     hold on
%     plot(bb,'--b');
%


%     a = smoothdata(a, 1, 0.3, 4);
%     b = smoothdata(b, 1, 0.3, 4);
%
%     a = a/sum(abs(a));
%     b = b/sum(abs(b));
%
%     a = a - mean(a);
%     b = b - mean(b);




    % find the events
%     a_events = indicator(a, threshold, binsize);
%     b_events = indicator(b, threshold, binsize);

%     if doPlots
%         figure(1)
%         subplot(211), plot(100*a,'r'), hold on, plot(100*b)
%         title('Preconditioned FMRI Time Courses ')
%         legend('A', 'B')
%         line([ 1 length(b)], [threshold*std(b) threshold*std(b)]);
%         line([ 1 length(a)], [threshold*std(a) threshold*std(a)],'Color','r');
%         dofontsize(16);
%         hold off
%
%         subplot(212),
%         stem(a_events,'r'), hold on, stem(b_events,'--');
%         title(sprintf('Detected Events ( Dominance = %f)',dom));
%         legend('A', 'B')
%         dofontsize(16);
%         hold off
%         drawnow
%
%     end

    smoothrfa = zeros(length(hrf_a),1);
    spm_smooth(hrf_a,smoothrfa,FWHM);
    rulesa = sum(smoothrfa.*(smoothrfa>=mean(smoothrfa)));
    as = aa>mean(smoothrfa);
    as = as.*aa;

    smoothrfb = zeros(length(hrf_b),1);
    spm_smooth(hrf_b,smoothrfb,FWHM);
    rulesb = sum(smoothrfb.*(smoothrfb>=mean(smoothrfb)));
    bs = bb>mean(smoothrfb);
    bs = bs.*bb;
    %abline('h',mean(smoothrf));

    lista = [];

    for (i = 1:(length(as)-1))
        if (as(i) == 0 & as(i+1) ~= 0)
            tmp = 0;
            j = i+1;
            while(as(j)~=0)
                tmp = tmp + as(j);
                if (j == length(as))
                    as(j) = 0;
                else
                    j = j+1;
                end
            end
            i = j;  lista = [lista tmp];
        end
    end

    eventsa = [eventsa sum(round(lista./(co*rulesa)))];

    listb = [];
    for (i = 1:(length(bs)-1))
        if (bs(i) == 0 & bs(i+1) ~= 0)
            tmp = 0;
            j = i+1;
            while(bs(j) ~= 0)
                tmp = tmp + bs(j);
                if (j == length(bs))
                    bs(j) = 0;
                else
                j = j+1;
                end
            end
            i = j;  listb = [listb tmp];
        end
    end

    eventsb = [eventsb sum(round(listb./(co*rulesb)))];
end

sum(eventsb==15)
hist(eventsb)
sum(eventsa == 10)

