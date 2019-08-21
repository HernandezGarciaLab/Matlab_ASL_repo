function ms = testlabel3d(Pfile, doGetraw)

if nargin>1
	if doGetraw
		str=['!~hernan/scripts/getraw ' Pfile];
		eval(str)
	end
end

!rm *.nii
%sprec1_3d(Pfile,'m','n',64);
%sprec1_3d(Pfile,'h','n',64,'l');

% sprec1_3d(Pfile,'N','h','n',64, 'fx', 'fy');
% sprec1_3d(Pfile,'N', 'n',64,'fx','fy','l');

sprec1_3d(Pfile,'N', 'n',64,'fy','l','C',1);

vols = dir('vol*.nii');
volname = vols(1).name;

hdr = read_hdr(volname);

% Skip the first one:  field map!!
aslsub(volname(1:end-4), 1, 5, hdr.tdim, 0, 0 , 0);

ms = lightbox('mean_sub',[-500 500],3);
if (mean(ms(:)) < 0)
	aslsub(volname(1:end-4), 1, 5, hdr.tdim, 0, 1, 0);
    	ms = lightbox('mean_sub',[-200 200],3);
end

%print -djpeg testlabel

figure
[tSNR sSNR] = ASL_snr(0.5);
%figure, hist(ms(:), 100); 
figure
subplot(211); lightbox('mean_con');
subplot(212); lightbox('mean_tag');

return
