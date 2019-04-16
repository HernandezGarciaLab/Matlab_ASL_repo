% Make nice plots of the convergence from the mat files 
figure

load notnoisy
plot(residue, 'b'), hold on
load noisy
plot(residue,'g')
load rpenalty05
plot(residue,'r')
load rpenalty20
plot(residue,'k')
dofontsize(12)
legend ('no noise', 'noisy', 'roughness penalty=0.5', 'roughness penalty = 2.0')

% Make Nice plots of estimates and signal from the saved mat files
figure
load notnoisy
subplot(221)
plot(t,f/mean(f))
hold on, plot(t,est2/mean(est2), 'r')
plot(t(1:end-1), signal/mean(signal),'g')
title ('No noise')
%legend('True Perfusion', ' Perfusion Estimate', 'ASL signal')
fatlines, dofontsize(12)
axis([0 100 0.8 1.6])
legend('True Perfusion', 'Perfusion Estimate', 'ASL signal')

load noisy

subplot(222)
plot(t,f/mean(f))
hold on, plot(t,est2/mean(est2), 'r')
plot(t(1:end-1), signal/mean(signal),'g')
title('Noisy')
fatlines, dofontsize(12)
axis([0 100 0.8 1.6])

load rpenalty05

subplot(223)
plot(t,f/mean(f))
hold on, plot(t,est2/mean(est2), 'r')
plot(t(1:end-1), signal/mean(signal),'g')
%legend('True', 'Perfusion Estimate', 'ASL signal')
title('Roughness Penalty = 0.5')
fatlines, dofontsize(12)
axis([0 100 0.8 1.6])

load rpenalty20

subplot(224)
plot(t,f/mean(f))
hold on, plot(t,est2/mean(est2), 'r')
plot(t(1:end-1), signal/mean(signal),'g')
%legend('True', 'Perfusion Estimate', 'ASL signal')
title('Roughness Penalty = 2.0') 
fatlines, dofontsize(12)
axis([0 100 0.8 1.6])

print -dpng estimation.png

% Make another convergence plot based on the diairy info
r1 =load ('notnoisy.txt');
r2 = load ('noisy.txt');
r3 = load ('rpenalty05.txt');
r4 = load ('rpenalty20.txt');

figure
hold on
plot(r1(:,1), r1(:,3) )
plot(r2(:,1), r2(:,3),'r' )
plot(r3(:,1), r3(:,3),'g' )
plot(r4(:,1), r4(:,3),'k' )
legend('No noise', 'Noisy', 'R. Penalty=0.5', 'R. Penalty=2.0')
title('Residual Errors at each iteration')
fatlines, dofontsize(12)

print -dpng converge.png