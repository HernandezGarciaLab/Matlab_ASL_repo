function X=buildDesMat(TR, exp_duration, onsets, durations, doASLmod)
% function X = buildDesMat(TR, exp_duration, onsets, durations, doASLmod)
%
%     (c) 2010 Luis Hernandez-Garcia @ UM
%     report bugs to hernan@umich.edu
%
%     this is a function to make design matrices, including the ASL
%     modulation if you want to analyze ASL data without subtraction
%
%     The baseline is the first column and gets added in for you.
%
%     NOTE: this is hard coded to use ASL based HRFs - little undershoot
%     and a little bit faster time to peak:
%                   h = spm_hrf(1, [5, 16, 1,1, 20,0,32]); 
%
%     TR :  scanner repetition time ...please give all data in seconds
%
%     exp_duration : total duration of the run
%
%     onsets: onset times for each block/event of the stimulation (or condition)
%         this should be a cell array containing the onset times of each condition like this:
%         onsets{1} = [ 1, 40, 60, 90 ....];
%         onsets{2} = [ 10, 20, ....];
%
%     durations : similarly, give the duration of each of the above blocks.  If they are events, make them 1
%         make sure that the sizes match up.
%         durations{1} = [20 20 20 ...];
%         durations{2} = [3 1 5 ....];
%
%     doASLmod : 1 if you're making a design matrix for an unssubtracted ASL experiment,
%                 0 otherwise
%

% Allocate space:
D = zeros(exp_duration , length(onsets)+1);
Nconds = length(onsets);

%% describe the basic set of conditions
D(:,1) = 1;
for cond=1:Nconds
    for blk = 1:length(onsets{cond})
        D( onsets{cond}(blk) : (onsets{cond}(blk) + durations{cond}(blk) ), cond+1) = 1;
    end
end
D = D(1:exp_duration,:);

%% Now convolve with HRF at high sampling rate:
% BOLD case:
h = spm_hrf(1);
% ASL case:
if doASLmod
    h = spm_hrf(1, [6, 16, 1,1, 20,0,32]); 
end
for r=1:Nconds+1
    reg = D(:,r);
    reg = conv(reg,h);
    reg = reg(1:exp_duration);
    reg = reg/max(reg);
    D(:,r) =  reg;
end
D(:,1) = 1;

%% resample to TR
tsamp1=1:exp_duration;
tsamp2=1:TR:exp_duration;
for r=1:Nconds+1
    reg = D(:,r);
    reg = interp1(tsamp1, reg, tsamp2);
    D2(:,r) =  reg;
end
D=D2;

%% now generate the ASL modulated version:
if doASLmod
    D2 = D;
    D2(1:2:end,:) = -D2(1:2:end,:);

    % concatenate the two:
    X = [D D2/2];
else
    X=D;
end

return
