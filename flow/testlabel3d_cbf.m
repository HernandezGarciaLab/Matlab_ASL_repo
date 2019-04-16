function ms = testlabel3d_cbf(Pfile, doGetraw)

if nargin>1
	if doGetraw
		str=['!~hernan/scripts/getraw ' Pfile];
		eval(str)
	end
end

!rm *.nii
 %sprec1_3d(Pfile,'m','n',64);
 %sprec1_3d(Pfile,'N','h','n',64, 'fx', 'fy');
 %sprec1_3d(Pfile,'m','fy','l');
 sprec1_3d(Pfile,'N', 'fy','fx', 'l');
 %sprec1_3d(Pfile,'h', 'com', 'N', 'fy', 'l');

 

vols = dir('vol*.nii');
volname = vols(1).name;

hdr = read_hdr(volname);

% Skip the first one:  field map!!
aslsub(volname(1:end-4), 1, 11, hdr.tdim, 0, 0, 0);

figure(11)
ms = lightbox('mean_sub',[-200 200],3);
if (mean(ms(:)) < 0)
	aslsub(volname(1:end-4), 1, 11, hdr.tdim, 0, 1, 0);
    ms = lightbox('mean_sub',[-200 200],3);
end

print -djpeg testlabel

figure
[tSNR sSNR] = ASL_snr(1.5)
%figure, hist(ms(:), 100); 

M0frames = 6;  % the first frames do not have background suppression
inv_alpha = 0.85;
flip = 35 * pi/180;
Ttag = 1.8;
TR = 4;
Ttrans = 1.2;
pid = 1.6;
T1 = 1.4;

f = casl_pid_02(volname, M0frames, inv_alpha, flip, Ttag, TR, pid, Ttrans, T1);
%function f = casl_pid_02(raw_file, M0frames, inv_alpha, flip, Ttag, TR, pid, Ttrans, T1)

figure(12);
subplot(121)
lightbox('Flow', [ 0 80], 5);  title ('Perfusion');
subplot(122)
lightbox('SpinDensity',[],5); title('Spin Density/100');

return
