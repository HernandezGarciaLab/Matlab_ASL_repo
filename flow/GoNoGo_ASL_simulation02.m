% these onsets times are in units of TR, when TR=2, we
% need to adapt them to a case where TR=4;

TR=4;
exp_duration = 256;


%%
% r1 = load('Lureswwrest.txt');
% r2 = load('Targetwrest.txt');
% 
% r1 = load('rejects.txt');
% r2 = load('targets.txt');

r1 = load('luresrun1and4.txt');
r2 = load('targetsrun1and4.txt');

r1 = load('luresrun2and3.txt');
r2 = load('targetsrun2and3.txt');

onsets{1} = 2* r1';
durations{1} = onsets{1};
durations{1}(:) = 1;

onsets{2} = 2* r2';
durations{2} = onsets{2};
durations{2}(:) = 1;


if 0
    onsets{1} = [onsets{1} (onsets{1} + exp_duration)];
    durations{1} = [durations{1} durations{1}];
    onsets{2} = [onsets{2} (onsets{2} + exp_duration)];
    durations{2} = [durations{2} durations{2}];
    
    exp_duration = exp_duration*2;
end

if 0
    onsets{1} = [onsets{1} (onsets{1} + exp_duration)];
    durations{1} = [durations{1} durations{1}];
    onsets{2} = [onsets{2} (onsets{2} + exp_duration)];
    durations{2} = [durations{2} durations{2}];
    
    exp_duration = exp_duration*2;
end

doASLmod = 1;

X=buildDesMat(TR, exp_duration, onsets, durations, doASLmod);

%%
DX = -differencer(X,4);
DX = DX(:,end/2+1:end);

subplot(221)
imagesc(X)
subplot(222)
imagesc(DX); colormap gray

%  baseline, targets, comission, crrt lures, omission
betas1 = [100 20 15 ]';
betas2 = [100 0 10]';

ASL = DX*betas1;

NITER=1;
for n=1:NITER
    noise = 10* randn(size(ASL));
    signal = ASL + noise;
    
    
    subplot(212)
    plot(signal)
    
    contrast = [ 0  1 0];
    cc = ~contrast;
    
    flags.header = [];
    flags.doWhiten=0;
    [betaCon vCon zmap] = spmJr (signal, DX, contrast, flags);
    
    allZ(n) = zmap;
end
mean(allZ)

load spmJr.mat


hold on;
plot(signal - DX*(beta_est.*cc'), 'r')
plot(DX*(beta_est.*contrast'),'g')
hold off
