
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

sprec1_3d(Pfile,'N', 'fy','l','C',0.5,'n',256);

vols = dir('vol*.nii');
volname = vols(1).name;

hdr = read_hdr(volname);

% Skip the first one:  field map!!
aslsub(volname(1:end-4), 1, 3, hdr.tdim, 0, 0 , 0);

ms = lightbox('mean_sub',[0 300],3);
if (mean(ms(:)) < 0)
	aslsub(volname(1:end-4), 1, 3, hdr.tdim, 0, 1, 0);
    	ms = lightbox('mean_sub',[-200 200],3);
end

%print -djpeg testlabel

%figure, hist(ms(:), 100); 
figure
subplot(221); mc = lightbox('mean_con'); title('Control')
subplot(222); mt = lightbox('mean_tag'); title('Label')
subplot(223); m0 = lightbox(volname); title('Spin Density')
subplot(224); fract = lightbox(ms ./ m0); caxis([-0.015 0.015]); title('\DeltaM / M_0');

figure
[tSNR sSNR] = ASL_snr(0.5);



ortho2005([],'anat_file', 'mean_sub.img' , 'wscale',[-300 300]);

return
