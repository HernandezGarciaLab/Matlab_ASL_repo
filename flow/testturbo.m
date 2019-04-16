function  testturbo(Pfile, doGetraw)

if nargin>1
	if doGetraw
		str=['!~hernan/scripts/getraw ' Pfile];
		eval(str)
	end
end
!rm *.nii
sprec1(Pfile,'N');
%sprec1(Pfile,'N','h');

vols = dir('vol*.nii');
volname = vols(1).name;

hdr = read_hdr(volname);

%aslsub(volname(1:end-4), 16, 1, hdr.tdim, 0, 0, 0);
% aslsub(volname(1:end-4), 12, 1, hdr.tdim, 0, 1, 0);

% This is the case for the phase correction optimization
%aslsub(volname(1:end-4), 2, 1, hdr.tdim, 0, 0, 0);

% This is the case for the TurboCurve:
 aslsub(volname(1:end-4), 8, 1, hdr.tdim, 0, 0, 0);

global args; clear args

ortho2005([],'tseries_file', 'sub.img',...
	'wscale',[-200 200], ...
	'roitype','sphere',...
	'roisize',40,...
	'doMovie',1,...
	'interact',1 ...
	);

fprintf('\nsaving the global ASL signal as a function of phase correction ...');
sig = load('Ortho_tdata.dat');
outsig = sig;
for n=2:length(outsig)-1
	outsig(n) = sum(sig(n-1 : n+1)) / 3;
end

ind = find(outsig==min(abs(outsig)));
str1 = sprintf('\nTHE CLOSEST TO ZERO CROSSING WAS AT THE  %dth IMAGE', ind);
str2 = sprintf('\nTHE RECOMMENDED TR IS  %0.2f ms. \n\n', 1500 + (ind-1)*100);

figure(33)
slices02('sub',[-150 150]) ;
title([str1 str2]);
% histo_series02('sub.img',[],100)

return
