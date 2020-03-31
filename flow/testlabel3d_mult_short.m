function  testlabel3d_mult(Pfile, offset )

if nargin <2
    offset = -0.8
end
!rm *.nii
%sprec1_3d(Pfile,'m');
%sprec1_3d(Pfile,'h','N');
sprec1_3d(Pfile,'N','n',128, 'C',1);

vols = dir('vol*.nii');
volname = vols(1).name;

hdr = read_hdr(volname);

aslsub(volname(1:end-4), 1, 1, hdr.tdim, 0, 0, 0);

% aslsub(volname(1:end-4), 12, 1, hdr.tdim, 0, 0, 0);


% histo_series02('sub.img',[],100)
%
global args; clear args
ortho2005([],'tseries_file', 'sub.img',...
	'wscale',[], ...
	'roitype','sphere',...
	'roisize',40,...
	'doMovie',1,...
	'interact',0 ...
	);

fprintf('\nsaving the global ASL signal as a function of phase correction ...\n\n');
sig = load('Ortho_tdata.dat');



% fermi function :
x =  0.4*[0:length(sig)-1] + offset;
parms0 = [200, 0.4, 0.2];

myfermifun = @(parms,x) parms(1)./(exp((x-parms(2))/parms(3))+1)-parms(1)/2;

% cost function
cost = @(parms)  sum( (myfermifun(parms,x)-sig').^2 );

% fit the fermi function to the data by minimizing cost function
% opts = optimset('PlotFcns',@optimplotfval);
est = fminsearch(cost, parms0)

y_est = myfermifun(est,x)
plot(x,sig); hold on; plot(x, y_est, '--');hold off
xlabel('phase'); ylabel('signal')
% 
ind = find(y_est==max(y_est));
recommend_phase = est(2)-pi/2;
y_rec = myfermifun(est,est(2)-pi/2)
if y_rec < 0
    recommend_phase = est(2)+pi/2;
end

str1 = sprintf('THE HIGHEST GLOBAL SIGNAL WAS AT THE  %dth IMAGE', ind);
str2 = sprintf('\n THE RECOMMENDED PHASE INCR. IS  %0.2f (DISCO)', recommend_phase);

%

figure(33)
slices02('sub',[-1000 1000]) ; axis image
hdr = read_hdr('sub.hdr');
axis image
axis([1 hdr.xdim*hdr.tdim (hdr.zdim/2-3)*hdr.ydim (hdr.zdim/2+3)*hdr.ydim]);
title([ str2]);

%myphase_correction=(ind-1);
%save myphase_correction.txt myphase_correction -ASCII
return
