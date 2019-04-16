% batch job to test different estimation strategies, forcing Vart and f to be correlated.
% calls kinetix2.m , which calls kinetix_lsq.m

global rpenalty 
est0=[];

NITER=10;
noise = 0.5;
reglevels = [0:100:1000];
%reglevels = [25:5:50]*50;

all_f = [];
all_sig = [];
all_est = [];
bias = zeros(NITER,length(reglevels));
variance = zeros(NITER,length(reglevels));
%%%%%%  adding noise

rn=[];
for reg=1:length(reglevels)
    for iter=1:NITER
        %nvec = randn(1,600)
        %residue = [];
        rpenalty = reglevels(reg);
        fprintf('\nRegularization: %d -- iteration: %d: ',rpenalty, iter);
        tic
	kinetix2
  	toc
	rn=[rn; resnorm];

        bias(iter,reg) = sum(((f_est2-f)./f).^2);
        variance(iter,reg)  = var(f_est2);   
        
        all_f = [all_f ; f];
        all_sig = [all_sig ; signal];
        all_est = [all_est ; f_est2];   
        
    end    
    subplot(4,3,reg) 
    hold on
    plot(f)
    plot(f_est2, 'r')
    plot(est0(1:end-1)+est0(end),'k')
    drawnow
 
    
end

bias_2 = mean(bias,1);
vars_2 = mean(variance,1);
figure
plot(bias_2,vars_2,'o-')
title ('Variance:Bias plot')
xlabel('Bias')
ylabel('Variance')
fatlines
dofontsize(14)
save reg_temp_noisy

return
figure
plot(t,f,'k')
hold on
plot( t,all_est(1:NITER:end ,:) )
hold off
legend('True perfusion', 'reg0', 'reg1', 'reg2' , 'reg3', 'reg4', 'reg5')
legend boxoff
title ('Perfusion estimates')
xlabel('Time (sec.)')
ylabel('Perfusion (ml/s/g)')
fatlines
dofontsize(16)

% for k=1:50
%     plot( (all_2_est(k:k+5,:) )')
%     pause
% end
