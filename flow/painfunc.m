% This script will
% filter the P files to remove RF leakage spikes
% reconstruct a turbo set of ASL images
% perform the pairwise subtraction and averaging (aslsub)
% smooth those images in space
% produce signal as a function of TR plot
% show histogram of the different TRs
%
% execute this script from a directory that contains
% all the P files...
close all

% use these default flags....
doFilter=1
doDespiker=1;
filter_range = [178:186];
navg=1;
skip=2;
switch_order=0;
order=0;
isExcite=1


if isExcite==0
    filterProg='filterraw';
    recon='gsp20a';
    fastrec=1;
    year=2004;
else
    filterProg='filterrawEX';
    recon='gsp21a';
    fastrec=0;
    year=2005;
end

Pfiles=dir('P*')
tcount=1;

for count=1:length(Pfiles)
    % filter the k-space data to remove RF noise
    workPfile = Pfiles(count).name;
    if doFilter==1
        str = sprintf('a = %s(''%s'', [%s],%d,0);',...
            filterProg, workPfile, num2str(filter_range),fastrec)
        eval(str);
        workPfile = sprintf('f_%s', workPfile)
    end
    if doDespiker==1
        % remove white pix
        a = despiker(workPfile, 2, fastrec, 0, year);
        workPfile = sprintf('f_%s', workPfile)
    end

    str = sprintf('! %s -A %s', recon, workPfile)
    eval(str)

    %spm_smooth_ui
    warning off
    smoother('vol',7);
    warning on
    
    
    names=dir('s_vol*.hdr')
    root=names(1).name;
    root=root(1:end-8)
    str = sprintf('!cp -f %s mask.hdr',names(5).name);
    eval(str);
    str = sprintf('!cp -f %s.img mask.img',names(5).name(1:end-4));
    eval(str);

    % do  averages (pairs) starting with 1 end with the hightest number,
    % skip the first two pairs
    % aslsub(root,navg,1,size(names,1), skip, order)

    % for the cases where we used cast_doubleall for TR 0.8:2.0 sec and cast_double for tr=4sec:
    if switch_order
        order=~order;
    end

    % try again after sinc interpolation:
    interp_asl('s_vol_*',1);
    meanreg = load('mean_subreg.dat');
    %051117pl
    TR = 1.1;
    Nscans = 574;

    %051117tn:
    %TR = 1;
    %Nscans = 630;

    total_time = Nscans*TR;

    duration = 10 * 25;
    stim = zeros(10 * total_time,4);

    % Make the design matrix from the timing data
    onsets = load('~hernan/data/painflow/SeqOneTR2.5.txt');
    onsets(:,1) = onsets(:,1)*25;

    % high intensity: 
     onsets(find(onsets(:,3) == 1),1)
     onsets(find(onsets(:,3) == 2),1)
     onsets(find(onsets(:,3) == 3),1)
     onsets(find(onsets(:,3) == 4),1)
     
    for o = 1:size(onsets,1);
        type = onsets(o , 3);
        if type >0
            stim(onsets(o,1) : onsets(o,1) + duration , type) = 1;
        end
    end

    hrf = make_hrf(0,20,250);

    for type = 1:4
        resp = conv(stim (:,type), hrf);
        stim(:,type) = resp(1:size(stim,1));
    end

    resp = stim(1:TR*10:end,:);
    
    % include the mean image time series into the design matri
    % (must orthogonalize it first)
    DesMat = [ones(Nscans,1)  resp];
    [t , B, vB] = myLinReg( DesMat, meanreg, [ 1,1,1,1,1]);
    meanreg_o = meanreg - DesMat*B;
    DesMat = [meanreg_o DesMat];
   
    
    imagesc(DesMat)
    drawnow
    
    contrasts = ...
       [0 0 0 1 1 1;
        0 0 0 0 0 1
        0 0 0 0 1 0
        0 0 0 1 0 0
        0 0 1 0 0 0];

    spmJr('interpsub',DesMat,contrasts);
    !mvimg Zmap_0001 Zmap_con0111
    !mvimg Zmap_0002 Zmap_con0001
    !mvimg Zmap_0003 Zmap_con0010
    !mvimg Zmap_0004 Zmap_con0100
    !mvimg Zmap_0005 Zmap_con1000
end

return

%  this is just junk for testing purposes....
for n=1:32*3
    a1=readraw('f_Pa1600',n);
    a2=readraw('f_Pa1600',n+1);
    fprintf('\nframe= %d', n)
    subplot(211)
    plot(abs(fft(a1)))
    subplot(212)
    plot(abs(fft(a1 - a2)))
    pause
end

for n=1:32*3
    a1=readraw('Pa1600',n);
    a2=readraw('f_Pa1600',n);
    fprintf('\nframe= %d', n)
    plot(abs(a1))
    hold on
    plot(abs(a2),'g')
    pause
    hold off
end

