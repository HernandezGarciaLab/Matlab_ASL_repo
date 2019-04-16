function  testlabel_mult(Pfile, doGetraw)

if nargin>1
	if doGetraw
		str=['!~hernan/scripts/getraw ' Pfile];
		eval(str)
	end
end
!rm *.nii
%sprec1(Pfile,'n',128,'fy','N');
%sprec1(Pfile,'N','h');
sprec1(Pfile,'n', 64,'fy','N', 'C', 0.3);

vols = dir('vol*.nii');
volname = vols(1).name;

hdr = read_hdr(volname);

%aslsub(volname(1:end-4), 16, 1, hdr.tdim, 0, 0, 0);
% aslsub(volname(1:end-4), 12, 1, hdr.tdim, 0, 1, 0);

% This is the case for the phase correction optimization
aslsub(volname(1:end-4), 1, 1, hdr.tdim, 0, 0, 0);

% This is the case for the TurboCurve:
%  aslsub(volname(1:end-4), 8, 1, hdr.tdim, 0, 0, 0);

% histo_series02('sub.img',[],100)
global args; clear args
ortho2005([],'tseries_file', 'sub.img',...
	'wscale',[-200 200], ...
	'roitype','sphere',...
	'roisize',80,...
	'doMovie',1,...
	'interact',0 ...
	);

fprintf('\nsaving the global ASL signal as a function of phase correction ...');
sig = load('Ortho_tdata.dat');
sig = [sig(end); sig ;sig(1)];
outsig = sig;
for n=2:length(outsig)-1
	outsig(n) = sum(sig(n-1 : n+1)) / 3;
end
outsig = outsig(2:end-1);
sig = sig(2:end-1);

ind = find(outsig==max(outsig));
fprintf('\n\n THE HIGHEST GLOBAL SIGNAL WAS AT THE  %dth IMAGE\n', ind);
fprintf('\n\n THE RECOMMENDED PHASE CORRECTION IS  %0.2f \n\n', (ind-1)*0.2);

figure(33)
slices03('sub',[-100 100]) ; axis image
hdr = read_hdr('sub.hdr');
axis image
axis([1 hdr.xdim*hdr.tdim (hdr.zdim/2-3)*hdr.ydim (hdr.zdim/2+3)*hdr.ydim]);
title('magnitude of complex difference')

% figure(34)
% slices02('phaseDiff',[-pi pi]*1e3) ; axis image
% title('difference of phases')
return
