function alpha = testlabelcom(Pfile, doGetraw)
% function alpha = testlabelcom(Pfile, doGetraw)
%
% calculate inversion efficiency at every voxel
%
% this program takes the k-space Pfile as input
% and recons it as complex data.
% complex subtractions are done pairwise.
%     alpha = abs(con-tag) / 2*abs(con)
%
% program has the option to grab it from the scanner itself!
%

!rm *.nii

if nargin>1
	if doGetraw
		str=['!~hernan/scripts/getraw ' Pfile];
		eval(str)
	end
end

sprec1(Pfile,'n', 64, 'com','N', 'fy','l');

vols = dir('vol*.nii');
volname = vols(1).name;

pvols = dir('p_vol*.nii');
pvolname = pvols(1).name;

hdr = read_hdr(volname);

aslsub(volname(1:end-4), 1, 3, hdr.tdim, 0, 0, 1);
%aslsub(volname(1:end-4), 1, 1, hdr.tdim, 0, 0, 1);


%figure, hist(ms(:), 100); 
subplot(221); con = lightbox('mean_con'); title('Mean control MAG')
subplot(222); tag = lightbox('mean_tag'); title('Mean Tag MAG')
subplot(223); lightbox('p_mean_con'); title('Mean control PHS')
subplot(224); lightbox('p_mean_tag'); title('Mean Tag PHS')
set(gcf,'Name','Excluding first two frames ... ')

% in a complex subtraction this already includes the sign.
figure
subplot(221); delta = lightbox('mean_sub'); title('abs(control-tag)');
subplot(222); lightbox('mean_magDiff'); title('abs(control)-abs(tag)');
subplot(223); lightbox('p_mean_sub'); title('angle(control-tag)');
subplot(224); lightbox('mean_phaseDiff'); title('angle(control)-angle(tag)');
set(gcf,'Name','Excluding first two frames ...')

%ms = lightbox('mean_sub'); 
den = max(con,tag);

alpha = delta ./ (2*den);

figure; 
lightbox(abs(alpha(:,:,1)) ,[0 1],sqrt(hdr.zdim));  title('alpha map')

figure
slices03(volname);
title('Magnitude time series')

figure
slices03(pvolname);
title('Phase time series')
colormap hsv

%{
global args; clear args
ortho2005([],'tseries_file', volname,...
    'roitype','sphere',...
    'roisize',80,...
    'doMovie',1,...
    'interact',0 ...
    );

ortho2005([],'tseries_file', pvolname,...
    'roitype','sphere',...
    'roisize',80,...
    'doMovie',1,...
    'interact',0 ...
    );
%}
%q=1;
% while q~=3
%     [x y q] = ginput(1);
%     fprintf('\r value of Inv. Efficiency:  %02f ', alpha(round(x),round(y),1));
% end
%print -djpeg testlabelcom
