% this is the version for 3D muti echo
% execute this script from a directory that contains
% all the P files...

Pfiles=dir('P*')
nechos=16;
nframes=32;
mkdir('reconned') 
for count=1:length(Pfiles)
    % filter the k-space data to remove RF noise
    % a = filterraw(Pfiles(count).name, [185:187]);
    
    % do the recon
    fse3d_recon(Pfiles(count).name , 64, 64, nechos, nframes);   
    % re-number the files so that we can concatenate...
    str=sprintf('!renumimg volume_ 1 %d %d ',nframes, (count-1)*nframes+1);
    eval(str)
    !mv volume_* reconned
end
cd reconned
% now do the pairwise subtraction (skip the first pair)
names=dir('volume_*.hdr')
root=names(1).name;
root=root(1:end-8);

aslsub(root,1,1,length(names), 0)
%aslsub(root,31,3,length(names), 2)
return

% rename the output subtraction image
subf=dir('sub_*.img');
for count=1:length(subf)
    name=subf(count).name;
    name=name(1:end-4);
    str = sprintf('!mvimg %s TT_%04d', name, count+1);
    eval(str)   
end

% display in slices and as a time series plot
slices('TT_',[-20 50])
% figure
% slices('vol_*_0002')
% figure
% orthov2(2,'TT_0001')
figure
histo_series('TT_',sprintf('%s0003',root),2000)

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
    
