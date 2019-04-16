% batch job to test different estimation strategies, forcing Vart and f to be correlated.
% call_2_s kinetix.m , which call_2_s kinetix_lsq.m

global rpenalty 

NITER=1;
noise = 0;
reglevels = [0:100:1000];

all_f = [];
all_sig = [];
all_est = [];
bias = zeros(NITER,length(reglevels));
variance = zeros(NITER,length(reglevels));
%%%%%%  adding noise


for reg=1:length(reglevels)
	subplot(4,3,reg) 
    for iter=1:NITER
        %nvec = randn(1,600)
        residue = [];
        rpenalty = reglevels(reg);
        fprintf('\nRegularization: %d -- iteration: %d: ',rpenalty, iter);
        kinetix
  
        bias(iter,reg) = sum((est2-f).^2);
        variance(iter,reg)  = var(est2);   
        
        all_f = [all_f ; f];
        all_sig = [all_sig ; signal];
        all_est = [all_est ; est2];   
        
    end    
    
    
end

bias_2 = mean(bias,1);
vars_2 = mean(variance,1);
figure
plot(bias_2,vars_2,'*-')
title ('Variance:Bias plot')
xlabel('Bias')
ylabel('Variance')
fatlines
dofontsize(14)
save temp

figure
plot(t,f,'k')
hold on
plot( t,all_est(1:2*NITER:11*NITER,:) )
hold off
legend('True perfusion', 'reg=0', 'reg=200', 'reg=400' , 'reg=600', 'reg=800', 'reg=1000')
legend boxoff
title ('Perfusion estimates')
xlabel('Time (sec.)')
ylabel('Perfusion (ml/s/g)')
fatlines
dofontsize(14)

% for k=1:50
%     plot( (all_2_est(k:k+5,:) )')
%     pause
% end
