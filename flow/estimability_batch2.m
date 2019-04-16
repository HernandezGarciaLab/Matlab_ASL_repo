% batch job to test estimability at different acquisition parameters
% for a given Transit time, can we estimate flow from any TR and TTag?

global rpenalty 

NITER=1;
rpenalty=500;
tr_choice=[0.4:0.4:4];
tr_choice=[0.4 1.4 1.6 4];
init_choice=[0.012:0.001:0.018];
    SECONDS = 1; 
    duration = 100;   % this is in seconds !!

noise = 0;
%Ttag =0.8  % seconds
del = 0.02;	 %seconds
crushers=1;
R1t = 1/1.2;    % 1/sec.
R1a = 1/1.6;    % 1/sec
%TR = Ttag + 0.2;
xchange_time = 0.1;  % sec.
dist = 16;   %cm
V0 = 10;  %cm/sec
Ttransit=dist/V0
% adjust for the proton density
alpha=6000*0.7*0.85;

%all_f = [];
%all_sig = [];
%all_est = [];

all_f = zeros(NITER*length(tr_choice), duration/tr_choice(1));
all_sig=all_f;
all_est=all_f;
all_t = all_f;

nbias = zeros(NITER,length(tr_choice));
bias = zeros(NITER,length(tr_choice));
variance = zeros(NITER,length(tr_choice));
realization=1;

%for n=1:length(tr_choice)
for n=1:length(init_choice)
    TR=1.4;
    %TR=tr_choice(n);
    Ttag=TR-0.2;
    
    parms(1) = Ttag;     % seconds
    parms(2) = del ;	 %seconds
    parms(3) = crushers ;
    parms(4)= R1t ;    % 1/sec.
    parms(5) = R1a;   % 1/secparms(6)=
    parms(6) = TR ;  % sec.
    parms(7) = alpha; 
    parms(8) = dist ;
    parms(9) = V0 ;
    
    
    %%%%%%%%%%%
    % make up an activation paradigm: 
    art = ones(1,duration*SECONDS/TR);
    
    f0=90/(60*100);
    f = f0*ones(1,duration*SECONDS/TR);
    paradigm = ones(size(art));
    for delay=20:15:duration*0.5
        h = make_hrf(delay*SECONDS/TR,3*SECONDS/TR,max(size(art))) * 0.4;
        paradigm  = paradigm + h;
    end        
    % Now scale the data to a baseline level:
    f = f.* paradigm ;
    t = [TR: TR: TR*(length(f))];
    % generate the original signal:
    signal = kinetix_lsq(f ,t, parms); 
    %%%%%%%%%%%%
    
    for iter=1:NITER
        nvec = noise*randn(size(signal));
        signal=signal+nvec;
        residue = [];
        fprintf('\nTR: %f -- iteration: %d: ',TR, iter);
        
        
        est0=zeros(size(signal));
        %est0(:) = 0.015;
        est0(:) = init_choice(n)
        
        LB = est0*0.5;
        UB = est0*2.5;
        
        optvar=optimset('lsqnonlin');
        optvar.TolFun = 1e-15;
        optvar.TolX = 1e-10;
        optvar.MaxIter = 8;
        optvar.Diagnostics = 'off';
        optvar.Display = 'iter';
        optvar.DiffMinChange = 1.0e-6;
        
        [est2 , resnorm, res, ex, output]  = lsqnonlin(@kinetix_lsq,...
            est0, LB, UB, ...
            optvar,...
            t,parms, ...
            signal);
        
        bias(iter,n) = sum((est2-f).^2);
        nbias(iter,n) = mean((est2-f).^2 ./f);
        if (iter==1)
            plot(t, est2)
            hold on
            plot(t, f, 'r')
            drawnow
        end
        variance(iter,n)  = var(est2);   
        
        all_t(realization, 1:length(f)) =  t;
        all_f(realization, 1:length(f)) =  f;
        all_sig(realization, 1:length(f)) = signal;
        all_est(realization, 1:length(f)) = est2;   
        realization = realization +1;
        %all_f = [all_f ; f];
        %all_sig = [all_sig ; signal];
        %all_est = [all_est ; est2];   
        
    end    
    
    
end

nbias_2 = mean(nbias,1);
bias_2 = mean(bias,1);
vars_2 = mean(variance,1);
figure
subplot(211)
plot(bias_2,vars_2,'*-')
title ('Variance:Bias plot')
xlabel('Bias')
ylabel('Variance')
fatlines
dofontsize(14)

subplot(212)
plot(tr_choice,nbias_2)
xlabel('TR')
ylabel('Bias')
title('Normalized Estimation bias as a function of TR')
fatlines
dofontsize(14)

save temp
print -dpng estimation_bias.png



figure
plot(all_t(1,:),all_f(1,:),'k')
hold on
for p=1:2:length(tr_choice)
    x = all_t(p*NITER, :);
    y = all_est(p*NITER,:);
    plot(x,y)
end
print -dpng fplots.png

%hold off
%title ('Perfusion estimates')
%xlabel('Time (sec.)')
%ylabel('Perfusion (ml/s/g)')
%fatlines
%dofontsize(14)

% for k=1:50
%     plot( (all_2_est(k:k+5,:) )')
%     pause
% end
