function plotmcflirtregressors(strFileRegressors,strFileOut,strHeader)
% EXAMPLE
% strFileRegressors = 'realign.dat';
% strFileOut = 'run_01_motion';
% plotmcflirtregressors(strFileRegressors,strFileOut)

% $Id: plotmcflirtregressors.m 1279 2014-03-24 20:06:25Z klitinas $
% $HeadURL: svn+ssh://klitinas@anger.engin.umich.edu/svn/matlab/img/trunk/plotmcflirtregressors.m $

% Read motion parameters
s = readmcflirtpar(strFileRegressors);

% Plots
hFig = figure;
set(hFig,'color',[1 1 1]);
set(hFig,'PaperPosition',[0.0 0.0 8.5 11]);
set(hFig,'PaperSize',[8.5 11]);

% Rotations
subplot(211);
hAxRot = gca;
hXR = plot(s.xr,'r','linewidth',2);
hold on;
hYR = plot(s.yr,'g','linewidth',2);
hZR = plot(s.zr,'b','linewidth',2);
set(hAxRot,'xticklabel','','xlim',[1 length(s.xr)]);
%legend([hXR,hYR,hZR],'xR','yR','zR','location','NorthEastOutside');
%legend([hXR,hYR,hZR],'xR','yR','zR');
ylabel('Rotation (rad)');
strTitle = sprintf('MCFLIRT realignment parameters\nRotations');
hTitle = title(strTitle);
set(hTitle,'fontsize',12);

% Translations
subplot(212);
hAxTrans = gca;
hXT = plot(s.xt,'r','linewidth',2);
hold on;
hYT = plot(s.yt,'g','linewidth',2);
hZT = plot(s.zt,'b','linewidth',2);
set(hAxTrans,'xlim',[1 length(s.xr)])
%legend([hXT,hYT,hZT],'xT','yT','zT','location','NorthEastOutside');
%legend([hXT,hYT,hZT],'xT','yT','zT');
xlabel('Volume Number');
ylabel('Translation (mm)');
title('Translations','fontsize',12);

set([hAxRot hAxTrans],'fontsize',12,'linewidth',2);

if exist('strHeader','var')
	my_suptitle(strHeader);
end

% axes(hAxTrans)
% legend([hXT,hYT,hZT],'xT','yT','zT','location','NorthEastOutside');

% axes(hAxRot);
% legend([hXR,hYR,hZR],'xR','yR','zR','location','NorthEastOutside');
% set(hAxRot,'pos',[ 0.13 0.540980066445184 0.622321428571429 0.334245094796546]);
% set(hAxTrans,'pos',[ 0.13 0.108546961909456 0.622321428571429 0.334245094796546])
set(hAxRot,'pos',[ 0.13 0.540980066445184 0.775 0.334245094796546]);
set(hAxTrans,'pos',[ 0.13 0.108546961909456 0.775 0.334245094796546])
axes(hAxRot);
hLeg=legend([hXR,hYR,hZR],'x','y','z');
set(hLeg,'pos',[0.82 0.87 0.10 0.10]);

% print(hFig,'-dpdf','test');
print(hFig,'-dpdf',strFileOut);
close(gcf);
