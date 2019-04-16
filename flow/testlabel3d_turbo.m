function  testlabel3d_turbo(Pfile, Npairs)
% function  testlabel3d_turbo(Pfile, Npairs)


!rm *.nii
%sprec1_3d(Pfile,'m');
%sprec1_3d(Pfile,'h','N');
sprec1_3d(Pfile,'N', 'n',64,'fx','fy','l');

vols = dir('vol*.nii');
volname = vols(1).name;

hdr = read_hdr(volname);

aslsub(volname(1:end-4), Npairs, 1, hdr.tdim, 0, 1, 0);

% aslsub(volname(1:end-4), 2, 1, hdr.tdim, 0, 0, 0);

% aslsub(volname(1:end-4), 12, 1, hdr.tdim, 0, 0, 0);


% histo_series02('sub.img',[],100)
%
global args; clear args
ortho2005([],'tseries_file', 'sub.img',...
	'wscale',[-400 400], ...
	'roitype','sphere',...
	'roisize',80,...
	'doMovie',1,...
	'interact',0 ...
	);

fprintf('\nsaving the global ASL signal as a function of phase correction ...');
sig = abs(load('Ortho_tdata.dat'));

% smoothing the plot with a moving average
sig = [sig(end); sig ;sig(1)];
outsig = sig;
for n=2:length(outsig)-1
	outsig(n) = sum(sig(n-1 : n+1)) / 3;
end
outsig = outsig(2:end-1);
sig = sig(2:end-1);

ind = find(outsig==max(outsig));
str1 = sprintf('THE HIGHEST GLOBAL SIGNAL WAS AT THE  %dth IMAGE', ind);

%

figure(33)
slices02('sub',[0 500]) ; axis image

hdr = read_hdr('sub.hdr');
axis([1 hdr.xdim*hdr.tdim (hdr.zdim/2-2)*hdr.ydim (hdr.zdim/2+2)*hdr.ydim]);
title(str1);

%myphase_correction=(ind-1);
%save myphase_correction.txt myphase_correction -ASCII
return
