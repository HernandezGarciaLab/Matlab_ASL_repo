% execute this script from a directory that contains
% all the P files...
if (~exist('doFilter'))
    doFilter=1
end

Pfiles=dir('P*')
tcount=1;
NPairs = 24;

for count=1:length(Pfiles)
    % filter the k-space data to remove RF noise
    %a = filterrawEX(Pfiles(count).name, [183:185],0,0);
    if doFilter==1
        a = filterrawEX(Pfiles(count).name, [178:186],0,0);
        %a = filterrawEX(Pfiles(count).name, [45:49],0,0);
        a = despikerEX2(sprintf('f_%s',Pfiles(count).name), 0);
        str = sprintf('!mv f_f_%s f_%s',Pfiles(count).name ,Pfiles(count).name)
        eval(str);
        % do the recon with field map correction
        %str = sprintf('! gsp20a -m f_%s', Pfiles(count).name)
        %eval(str)
        %str = sprintf('! gsp20a -A f_%s', Pfiles(count).name)
        str = sprintf('! gsp21a -A f_%s', Pfiles(count).name)
        eval(str)
    else
        str = sprintf('! gsp21a -A %s', Pfiles(count).name)
        eval(str)
    end

    names=dir('vol*.hdr')
    root=names(1).name;
    root=root(1:end-8)
    str = sprintf('!cp -f %s mask.hdr',names(5).name);
    eval(str);
    str = sprintf('!cp -f %s.img mask.img',names(5).name(1:end-4));
    eval(str);  
    
    % aslsub(root,14,3,size(names,1), 0)
    % this work
    % do 24 averages (pairs) starting with 1 end with the hightest number,
    % skip the first two pairs
    NPairs=length(names)/2;
    aslsub(root,NPairs,1,size(names,1), 2,1,0)
    !rm vol*
    
    % rename the output subtraction image
    sfiles = dir('sub_*.img')
    for count=1:length(sfiles)
        str = sprintf('!mv %s.img TT_%04d.img', sfiles(count).name(1:end-4), tcount)
        eval(str)
        str = sprintf('!mv %s.hdr TT_%04d.hdr', sfiles(count).name(1:end-4), tcount)
        eval(str)
        tcount = tcount+1;
    end


end

% display in slices and as a time series plot
slices('TT_',[-50 50])
% figure
% slices('vol_*_0002')
% figure
% orthov2(2,'TT_0001')
figure
histo_series('TT_','mask',2000)

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

