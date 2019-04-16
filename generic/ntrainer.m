% files=dir('/Users/hernan/eprime/N-back/sound/*.wav');
% for n=1:length(files)
%     wavs{n} = wavread(fullfile('/Users/hernan/eprime/N-back/sound', files(n).name));
%     %mywavsc(wavs{n}, 40000)
% end
%
% save soundmat

clear all
load soundmat

Nmywavs = 8;
Npos = 8;
Nback = 2
Nsets = 10;
Ntrials = 15;
Nmatches = round(Ntrials/3);

width = 20; length = 20;
corners = [
    10 10
    10 40
    10 70
    40 10
    40 40
    40 70
    70 10
    70 40
    70 70];

axis([0 100 0 100])
tic

vcHist = zeros(1,Nsets);
acHist = zeros(1,Nsets);
levelHist = zeros(1,Nsets);

tic

for s=1:Nsets
    soundCorrect=0;
    visualCorrect = 0;

    % order the sounds randomly
    mywavs = randperm(Ntrials+Nback);
    mywavs = mod(mywavs, 8) +1;
    % introduce the matches into the mix
    smatch = randperm(Ntrials+Nback);
    smatch = smatch(find(smatch < Ntrials));
    smatch = smatch(1:Nmatches);
    smatch = sort(smatch);
    for c=smatch
        mywavs(c) = mywavs(c+Nback);
    end

    % same thing for the sound
    positions = randperm(Ntrials+Nback) ;
    positions = mod(positions, 8)+1;
    vmatch = randperm(Ntrials+Nback);
    vmatch = vmatch(find(vmatch < Ntrials));
    vmatch = vmatch(1:Nmatches);
    vmatch = sort(vmatch);
    for c=vmatch
        positions(c) = positions(c+Nback);
    end

    for n=1:Ntrials+Nback
        title(['N back :  ' num2str(Nback) ]);
        cla
        rectangle('Position',[ corners(positions(n),:) width length], 'FaceColor','b')
        drawnow
        pause(1)
        cla
        soundsc(wavs{mywavs(n)}, 40000)
        [x y c] = ginput(2);
        pause(1)

        positionMatch =0;
        soundMatch = 0;

        if n>Nback

            if positions(n) == positions(n-Nback)
                positionMatch = 1;
            end
            if mywavs(n) == mywavs(n-Nback)
                soundMatch = 1;
            end

            if ~isempty(find(c== 97)) && positionMatch
                visualCorrect = visualCorrect+1;
                fprintf('\n vis. correct TP %d ', visualCorrect)

            elseif isempty(find(c == 97)) && ~positionMatch
                visualCorrect = visualCorrect+1;
                fprintf('\n vis. correct TN %d ', visualCorrect)

            else
                fprintf('\n vis. wrong  %d ', visualCorrect)
            end



            if ~isempty(find(c == 108)) && soundMatch
                soundCorrect = soundCorrect+1;
                fprintf(' sound correct TP %d ', soundCorrect)

            elseif isempty(find(c == 108)) && ~soundMatch
                soundCorrect = soundCorrect+1;
                fprintf(' sound correct TN %d ', soundCorrect)

            else
                fprintf(' sound wrong  %d ', visualCorrect)
            end
            fprintf(' visual match %d audio match  %d ', positionMatch, soundMatch)
        end

    end

    sRate = soundCorrect/(Ntrials);
    vRate = visualCorrect/(Ntrials);

    % keep track
    vcHist(s) = vRate;
    acHist(s) = sRate;
    levelHist(s) = Nback;
    
    str = sprintf('\n\nEnd of set n. %d . \naudio correct: %0.2f,  \nvisual correct: %0.2f \n\n', s, 100*sRate, 100*vRate);
    
    disp(str)
    if sRate > 0.85 && vRate > 0.85
        Nback=Nback+1
        str = sprintf('%s\nAdvance to the next level!', str);
    end
    if vRate < 0.7 || sRate < 0.7
        Nback=Nback-1
        str = sprintf('%s\nGo back to previous level!', str);
    end
    
    text('String', str, 'Position',[20 50],'Fontsize',16)
    
    


    
    ginput(1);

end
disp(['End of session.  Time : ' num2str(toc)])

subplot(211)
plot([1:Nsets], [vcHist ; acHist ]')
legend('Visual Rate', 'Audio Rate', 'Nback Level')
title('Your Performance');
axis([1 Nsets 0 1])
subplot(212)
plot([1:Nsets], levelHist);
axis([1 Nsets 1 10])
xlabel('Set');
ylabel('Level')


