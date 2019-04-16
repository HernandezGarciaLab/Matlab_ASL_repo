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
fprintf('\nExecuting TTscript02 ...')

if (~exist('doFilter'))
% use these default flags....
    doFilter=1
    filter_range = [178:186];
    navg=24;
    skip=2;
    switch_order=0;
    order=1;
    isExcite=1
end


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
    if doFilter==1
        str = sprintf('a = %s(''%s'', [%s],%d,0);',...
			 filterProg, Pfiles(count).name, num2str(filter_range),fastrec)
        eval(str);
	% remove white pix
	fprintf('\nRunning despiker on f_%s',Pfiles(count).name);
	a = despikerEX(sprintf('f_%s',Pfiles(count).name),fastrec,0);
        str = sprintf('!mv f_f_%s f_%s',Pfiles(count).name ,Pfiles(count).name)
        eval(str);

        % do the recon with field map correction
        str = sprintf('! %s -m f_%s', recon, Pfiles(count).name)
        eval(str)
        str = sprintf('! %s -h -A f_%s', recon, Pfiles(count).name)
        eval(str)
    else
        str = sprintf('! %s -m %s', recon, Pfiles(count).name)
        eval(str)
        str = sprintf('! %s -h -A %s', recon, Pfiles(count).name)
        eval(str)
    end

    names=dir('vol*.hdr')
    root=names(1).name;
    root=root(1:end-8)
    str = sprintf('!cp -f %s mask.hdr',names(5).name);
    eval(str);
    str = sprintf('!cp -f %s.img mask.img',names(5).name(1:end-4));
    eval(str);  
    
    % do 24 averages (pairs) starting with 1 end with the hightest number,
    % skip the first two pairs
    aslsub(root,navg,1,size(names,1), skip, order)
    
    % for the cases where we used cast_doubleall for TR 0.8:2.0 sec and cast_double for tr=4sec:
    if switch_order
        order=~order;
    end
    
    % rename the output subtraction image
    sfiles = dir('sub_*.img')
    cfiles = dir('con_*.img')
    tfiles = dir('tag_*.img')
%{
    for count=1:length(sfiles)
        str = sprintf('!mv %s.img TT_%04d.img', sfiles(count).name(1:end-4), tcount)
        eval(str)
        str = sprintf('!mv %s.hdr TT_%04d.hdr', sfiles(count).name(1:end-4), tcount)
        eval(str)

    % rename the output control image
        str = sprintf('!mv %s.img CON_%04d.img', cfiles(count).name(1:end-4), tcount)
        eval(str)
        str = sprintf('!mv %s.hdr CON_%04d.hdr', cfiles(count).name(1:end-4), tcount)
        eval(str)

    % rename the output tag image
        str = sprintf('!mv %s.img TAG_%04d.img', tfiles(count).name(1:end-4), tcount)
        eval(str)
        str = sprintf('!mv %s.hdr TAG_%04d.hdr', tfiles(count).name(1:end-4), tcount)
        eval(str)

        tcount = tcount+1;
    end
    !rm vol* sub_* tag_*
%}

end
return

smoother('TT_',[5 5 5]);histo_series('TT_','mask',2000)
smoother('CON_',[5 5 5]);
smoother('TAG_',[5 5 5]);


% display in slices and as a time series plot
slices('TT_',[-100 100])
% figure
% slices('vol_*_0002')
% figure
% orthov2(2,'TT_0001')
figure
histo_series('TT_','mask',2000)
fprintf('\n\n ... TTscript02 complete \n\n')
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

