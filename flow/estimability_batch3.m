% batch job to test estimability at different acquisition parameters
% for a given Transit time, can we estimate flow from any TR and TTag?

global rpenalty 

NITER=20;
rpenalty=300;
tr_choice=[0.2:0.4:4];
tr_choice=[0.6, 1, 1.2, 1.4, 1.6, 1.8, 2, 2.4, 2.8, 3.2, 3.6 ,4];

noise = 0.1;
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

all_sig = [];
all_f_est2 = [];
rn=[];
nbias = zeros(NITER,length(tr_choice));
bias = zeros(NITER,length(tr_choice));
variance = zeros(NITER,length(tr_choice));
ffig=figure;
sfig=figure;
tmp=zeros(1,200);

for n=1:length(tr_choice)
    TR=tr_choice(n);
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
    SECONDS = 1; 
    duration = 100;   % this is in seconds !!
    %duration = 50;   % this is in seconds !!
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
    f_est =f;
    
    % Adding the Additional Mean parameter to estimate....
    % f_est is the function to estimate
    % f is the TRUE perfusion fucntion
    %f_est = [f_est-mean(f_est)   mean(f_est)];
    %whos
    
    signal = kinetix_lsqb(f_est ,t, parms); 
    tmp(:)=0;
    tmp(1:length(signal))=signal;
    all_sig = [all_sig; tmp];
    %%%%%%%%%%%%
    
    for iter=1:NITER
        nvec = noise*randn(size(signal));
        signal=signal+nvec;
        figure(sfig)
        subplot(4,3,n)
        plot(signal, 'g') 
        title(sprintf('TR= %02f', TR));
        drawnow
        
        residue = [];
        fprintf('\nTR: %f -- iteration: %d: ',TR, iter);
        
        
        % create initial guess including a mean value...
        est0 =zeros(size(t)) ;
        %est0=[est0 0.015];
        
        LB = ones(size(t))*0.001;
        UB = ones(size(t))*0.04;
        
        
        optvar=optimset('lsqnonlin');
        optvar.TolFun = 1e-15;
        optvar.TolX = 1e-10;
        optvar.MaxIter = 10;
        optvar.Diagnostics = 'off';
        optvar.Display = 'iter';
        optvar.DiffMinChange = 1.0e-6;
        
        [f_est2 , resnorm, res, ex, output]  = lsqnonlin(@kinetix_lsqb,...
            est0, LB, UB, ...
            optvar,...
            t,parms, ...
            signal);
        rn=[rn;resnorm];
        
        % include the mean back into the timeseries...
        %f_est2 = est2(1:end-1) + est2(end); 
        %tmp(:)=0;
        %tmp(1:length(f_est2))=f_est2;
        all_f_est2 = [all_f_est2 ; tmp];
        
        bias(iter,n) = sum((f_est2-f).^2);
        nbias(iter,n) = sum((f_est2-f).^2 ./f);
        if (iter==100)
            figure(ffig)
            subplot(4,3,n)
            fprintf('\nTR: %f -- iteration: %d: ',TR, iter);
            hold on
            plot(t, f_est2)
            plot(t, f, 'r')
            drawnow
        end
        variance(iter,n)  = var(f_est2);   
        
        
    end    
    
    
end

nbias_2 = mean(nbias,1);
bias_2 = mean(bias,1);
vars_2 = mean(variance,1);
figure
%subplot(211)
%plot(bias_2,vars_2,'*-')
%title ('Variance:Bias plot')
%xlabel('Bias')
%ylabel('Variance')
%fatlines
%dofontsize(14)
%
%subplot(212)
plot(tr_choice,100*nbias_2)
xlabel('TR')
ylabel('% Estimation Error (MSE)')
 title('Estimation Error as a Function of TR')
 text(3,10,'Transit Time = 1.6 s','Fontsize',14)
fatlines
dofontsize(17)
axis([0.6 4 -1 5]) , grid on


save temp_estimability
print -dpng estimation_bias.png

%figure
%plot(t,f,'k')
%hold on
%plot( t,all_est(1:2*NITER:11*NITER,:) )
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
