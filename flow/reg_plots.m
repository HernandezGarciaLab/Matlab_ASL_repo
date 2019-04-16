% Make Nice plots of estimates and signal from the saved mat files
rhos = [];
figure
load r00clean
subplot(221)
plot(t,f/mean(f))
hold on, plot(t,est2/mean(est2), 'r')
plot(t(1:end-1), signal/mean(signal),'g')
title ('r = 0 , clean ')
%legend('True Perfusion', ' Perfusion Estimate', 'ASL signal')
 
fatlines, dofontsize(12); 
axis([0 100 0.8 1.6])
legend('True Perfusion', 'Perfusion Estimate', 'ASL signal')
rhos = rho(2,1);

load r05clean 
subplot(222)
plot(t,f/mean(f))
hold on, plot(t,est2/mean(est2), 'r')
plot(t(1:end-1), signal/mean(signal),'g')
title('r = 0.05, clean')
 
axis([0 100 0.8 1.6])
rhos = [rhos ;rho(2,1)];
fatlines, dofontsize(12); 

load r10clean
subplot(223)
plot(t,f/mean(f))
hold on, plot(t,est2/mean(est2), 'r')
plot(t(1:end-1), signal/mean(signal),'g')
%legend('True', 'Perfusion Estimate', 'ASL signal')
title('r=0.1, clean')
 
axis([0 100 0.8 1.6])
rhos = [rhos ;rho(2,1)];
fatlines, dofontsize(12); 


load r11clean
rhos = [rhos ;rho(2,1)];
load r15clean
rhos = [rhos ;rho(2,1)];


load r20clean
subplot(224)
plot(t,f/mean(f))
hold on, plot(t,est2/mean(est2), 'r')
plot(t(1:end-1), signal/mean(signal),'g')
%legend('True', 'Perfusion Estimate', 'ASL signal')
title('r = 0.20') 
 
axis([0 100 0.8 1.6])
rhos = [rhos ;rho(2,1)];
fatlines, dofontsize(12); 


print -dpng cleanestimation.png

figure

%plot([0 0.05 0.10 0.11 0.15 0.20], rhos)
plot([0 0.05 0.10 0.11  0.20], rhos)
title('Effect of Regularization on the Estimation')
xlabel('Roughness Penalty (rho)')
ylabel('Correlation between Truth and Estimate')
fatlines,  dofontsize(12)
print -dpng cleancorrelation.png

% Make another convergence plot based on the diairy info
r1 =load ('r00clean.txt');
r2 = load ('r05clean.txt');
r3 = load ('r10clean.txt');
r4 = load ('r11clean.txt');
r5 = load ('r15clean.txt');
r6 = load ('r20clean.txt');

figure
hold on
plot(r1(:,1), r1(:,3) )
plot(r2(:,1), r2(:,3),'r' )
plot(r3(:,1), r3(:,3),'g' )
plot(r4(:,1), r4(:,3),'b' )
plot(r5(:,1), r5(:,3),'k' )
plot(r6(:,1), r6(:,3),'m' )
xlabel('iteration')
ylabel('Residual Error')
legend('r = 0' , 'r = 0.05', 'r = 0.10', 'r = 0.11', 'r=0.15', 'r= 0.20')
title('Residual Errors at each iteration')
fatlines,  dofontsize(12)

print -dpng cleanconverge.png

% Now the noisy data ....
rhos = [];
figure
load r00 
subplot(221)
plot(t,f/mean(f))
hold on, plot(t,est2/mean(est2), 'r')
plot(t(1:end-1), signal/mean(signal),'g')
title ('r = 0 , noisy ')
%legend('True Perfusion', ' Perfusion Estimate', 'ASL signal')
 
axis([0 100 0.8 1.6])
legend('True Perfusion', 'Perfusion Estimate', 'ASL signal')
rhos = rho(2,1);
fatlines, dofontsize(12); 


load r05 
subplot(222)
plot(t,f/mean(f))
hold on, plot(t,est2/mean(est2), 'r')
plot(t(1:end-1), signal/mean(signal),'g')
title('r = 0.05, noisy')
 
axis([0 100 0.8 1.6])
rhos = [rhos ; rho(2,1)];
fatlines, dofontsize(12); 


load r10
subplot(223)
plot(t,f/mean(f))
hold on, plot(t,est2/mean(est2), 'r')
plot(t(1:end-1), signal/mean(signal),'g')
%legend('True', 'Perfusion Estimate', 'ASL signal')
title('r=0.1, noisy')
 
axis([0 100 0.8 1.6])
rhos = [rhos ; rho(2,1)];
fatlines, dofontsize(12); 


load r11clean
rhos = [rhos ;rho(2,1)];
load r15clean
rhos = [rhos ;rho(2,1)];

load r20
subplot(224)
plot(t,f/mean(f))
hold on, plot(t,est2/mean(est2), 'r')
plot(t(1:end-1), signal/mean(signal),'g')
%legend('True', 'Perfusion Estimate', 'ASL signal')
title('r = 0.20') 
 
axis([0 100 0.8 1.6])
rhos = [rhos ; rho(2,1)];
fatlines, dofontsize(12); 


print -dpng noisyestimation.png

figure

plot([0 0.05 0.10 0.11 0.15 0.2], rhos)
title('Effect of Regularization on the Estimation')
xlabel('Roughness Penalty (rho)')
ylabel('Correlation between Truth and Estimate')
fatlines,  dofontsize(12)
print -dpng correlation.png

% Make another convergence plot based on the diairy info
r1 =load ('r00.txt');
r2 = load ('r05.txt');
r3 = load ('r10.txt');
r4 = load ('r11.txt');
r5 = load ('r15.txt');
r6 = load ('r20.txt');

figure
hold on
plot(r1(:,1), r1(:,3) )
plot(r2(:,1), r2(:,3),'r' )
plot(r3(:,1), r3(:,3),'g' )
plot(r4(:,1), r4(:,3),'b' )
plot(r5(:,1), r5(:,3),'k' )
plot(r6(:,1), r6(:,3),'m' )
xlabel('iteration')
ylabel('Residual Error')
legend('r = 0' , 'r = 0.05', 'r = 0.10', 'r = 0.11', 'r=0.15', 'r= 0.20')
title('Residual Errors at each iteration')
fatlines,  dofontsize(12)

print -dpng noisyconverge.png


% 2004 - 03 - 30


load noiselessSim
figure
plot(bias_2,vars_2,'*-')
hold on
title ('Variance:Bias plot')
xlabel('Bias')
ylabel('Variance')
fatlines
dofontsize(14)

load noisySim
hold on
plot(bias_2,vars_2,'*-r')
title ('Variance:Bias plot')
xlabel('Bias')
ylabel('Variance')

axis([0 1e-3 0 0.8e-5])
legend('Noise = 0','Noise = 0.1'), legend boxoff
fatlines
dofontsize(14)

figure
subplot(211)
plot(t,f,'k')
hold on
plot( t,all_est(1:2*NITER:11*NITER,:) )
hold off
legend('True perfusion', 'reg=0', 'reg=200', 'reg=400' , 'reg=600', 'reg=800', 'reg=1000',-1)
legend boxoff
title ('Perfusion estimates')
xlabel('Time (sec.)')
ylabel('Perfusion (ml/s/g)')
fatlines
dofontsize(14)
axis([0 100 0.01 0.03])


load noiselessSim
subplot(212)
plot(t,f,'k')
hold on
plot( t,all_est(1:2*NITER:11*NITER,:) )
hold off
legend('True perfusion', 'reg=0', 'reg=200', 'reg=400' , 'reg=600', 'reg=800', 'reg=1000',-1)
legend boxoff
title ('Perfusion estimates')
xlabel('Time (sec.)')
ylabel('Perfusion (ml/s/g)')
fatlines
dofontsize(14)
axis([0 100 0.01 0.03])


