function ms = testlabel3d_cbf_grappaz(Pfile)

!rm *.nii
numACS = 6;

 %sprec1_3d(Pfile,'m','n',64);
 %sprec1_3d(Pfile,'N','h','n',64, 'fx', 'fy');
 %sprec1_3d(Pfile,'m','fy','l');
 sprec1_3d_grappaz(Pfile,'N', 'l','grappaz', numACS );
 %sprec1_3d(Pfile,'h', 'com', 'N', 'fy', 'l');

 
 load fullysampled.mat

vols = dir('vol*.nii');
volname = vols(1).name;

[vols hdr] = read_img(volname);


aslsub(volname(1:end-4), 1, numACS+3 , hdr.tdim, 0, 0, 0);

figure(11)
ms = lightbox('mean_sub',[-200 200],3);
if (mean(ms(:)) < 0)
	aslsub(volname(1:end-4), 1, numACS+3, hdr.tdim, 0, 1, 0);
    ms = lightbox('mean_sub',[-200 200],3);
end

print -djpeg testlabel

figure
[tSNR sSNR] = ASL_snr(1.5)
%figure, hist(ms(:), 100); 

M0frames = numACS;  % the first frames do not have background suppression
inv_alpha = 0.85;
flip = 35 * pi/180;
Ttag = 2.0;
pid = 1.7;
TR = 5.0;
Ttrans = 1.2;
T1 = 1.4;


% altternative settings
Ttag = 1.8;
pid = 1.6;
TR = 4.0;


% We will stick in the M0 frames back into the unsubtracted volume file
a = fullimg(:)' / (M0frames/2);
a = repmat(a, M0frames,1);
vols = [a ; vols];
hdr.tdim = hdr.tdim + M0frames;
nhdr = avw2nii_hdr(hdr);
write_nii(volname, vols, nhdr,0);

f = casl_pid_02(volname, M0frames, inv_alpha, flip, Ttag, TR, pid, Ttrans, T1);
%function f = casl_pid_02(raw_file, M0frames, inv_alpha, flip, Ttag, TR, pid, Ttrans, T1)

figure(12);
subplot(121)
lightbox('Flow', [ 0 80], 6);  title ('Perfusion');
subplot(122)
lightbox('SpinDensity',[],6); title('Spin Density/100');

return
