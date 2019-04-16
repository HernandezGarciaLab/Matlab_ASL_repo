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
fprintf('\nExecuting TTscript_quick ...')

if (~exist('doFilter'))
% use these default flags....
    doFilter=0
    filter_range = [178:186];
    navg=24;
    skip=2;
    switch_order=0;
    order=1;
    isExcite=1
end

isComplex = 0;

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
	a = despiker(sprintf('f_%s',Pfiles(count).name),2, fastrec,0,year);
        str = sprintf('!mv f_f_%s f_%s',Pfiles(count).name ,Pfiles(count).name)
        eval(str);

        % do the recon with field map correction
        str = sprintf('! %s -A f_%s', recon, Pfiles(count).name)
        eval(str)
    else
        str = sprintf('! %s -A %s', recon, Pfiles(count).name)
        eval(str)
    end

    names=dir('vol*.hdr')
    root=names(1).name;
    root=root(1:end-8)
    str = sprintf('!cp -f %s mask.hdr',names(1).name);
    eval(str);
    str = sprintf('!cp -f %s.img mask.img',names(1).name(1:end-4));
    eval(str);  
    
    % do 24 averages (pairs) starting with 1 end with the hightest number,
    % skip the first two pairs
    aslsub(root,navg,1,size(names,1), skip, order, isComplex)
    str = sprintf('!mvimg mean_sub sub_%04d', count); 
    eval(str)
    str = sprintf('!mvimg mean_con con_%04d', count); 
    eval(str)
    str = sprintf('!mvimg mean_tag tag_%04d', count); 
    eval(str)
    % for the cases where we used cast_doubleall for TR 0.8:2.0 sec and cast_double for tr=4sec:
    if switch_order
        order=~order;
    end

end


% display in slices and as a time series plot
slices('con_',[200 -200])
% figure
% slices('vol_*_0002')
% figure
% orthov2(2,'TT_0001')
figure
avg = histo_series('con_','mask',500);
fprintf('\n\n ... TTscript03 complete \n\n')

return




%%  this is just junk for testing purposes....
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

