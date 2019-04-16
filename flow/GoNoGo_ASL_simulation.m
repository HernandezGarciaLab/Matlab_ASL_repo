% these onsets times are in units of TR, when TR=2, we
% need to adapt them to a case where TR=4;

TR=4;
exp_duration = 130*2;
%{
% TARGETS\
onsets{1} = 2* [20,21,22,22,23,26,27,29,30,31,31,32,34,35,36,37,38,41,42,45,46,46,48,49,50,51,52,53,53,54,56,57,58,58,59,62,66,70,74,75,76,76,77,77,80,81,83,84,85,85,86,88,89,90,91,92,95,96,99,100,100,102,104,105,106,107,107,108,110,111,112,112,113];
durations{1} = onsets{1};
durations{1}(:) = 1;

% comission - screwups on the no-gos
onsets{2} = 2* [44,60,93,98,101];
durations{2} = onsets{2};
durations{2}(:) = 1;

% CRRT lures - correct rejections of no-gos
onsets{3}= 2* [25,28,34,39,47,56,79,82,88,110,114];
durations{3} = onsets{3};
durations{3}(:) = 1;



% Omission - missed a no-go trial
onsets{4} = 2* [23,67,70,103];
durations{4} = onsets{4};
durations{4}(:) = 1;

%%
%}
r1 = load('reject2.txt');
r2 = load('Target2.txt');

onsets{1} = 2* r1;
durations{1} = onsets{1};
durations{1}(:) = 1;

onsets{2} = 2* r2;
durations{2} = onsets{2};
durations{2}(:) = 1;


if 1
    onsets{1} = [onsets{1} (onsets{1} + exp_duration)];
    durations{1} = [durations{1} durations{1}];
    onsets{2} = [onsets{2} (onsets{2} + exp_duration)];
    durations{2} = [durations{2} durations{2}];
    %{
    onsets{3} = [onsets{3} (onsets{3} + exp_duration)];
    durations{3} = [durations{3} durations{3}];
    onsets{4} = [onsets{4} (onsets{4} + exp_duration)];
    durations{4} = [durations{4} durations{4}];
    exp_duration = exp_duration*2;
    %}
end

doASLmod = 1;

X=buildDesMat(TR, exp_duration, onsets, durations, doASLmod);

%%
DX = -differencer(X,4);
DX = DX(:,6:end);

subplot(221)
imagesc(X)
subplot(222)
imagesc(DX); colormap gray

%  baseline, targets, comission, crrt lures, omission
betas1 = [100 20 15 16 14]';
betas2 = [100 0 0 10 10]';

ASL = DX*betas1;

noise = 20* randn(size(ASL));
signal = ASL + noise;


subplot(212)
plot(signal)
contrast = [ 0  0 0 1 0];
flags.header = [];
flags.doWhiten=0;
[betaCon vCon zmap] = spmJr (signal, DX, contrast, flags)
load spmJr.mat
cc = ~contrast;
hold on;
plot(signal - DX*(beta_est.*cc'), 'r')
plot(DX*(beta_est.*contrast'),'g')
hold off
