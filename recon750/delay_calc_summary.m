function delay_calc_summary(strFile,dIn,dOut,rdat,ddat,zdiff,sliceToShow,strFileOut)

% $Id: delay_calc_summary.m 1437 2014-06-23 13:47:19Z klitinas $
% $HeadURL: svn+ssh://klitinas@anger.engin.umich.edu/svn/matlab/img/trunk/delay_calc_summary.m $

hFig = figure;
set(hFig,'color',[1 1 1]);
%set(hFig,'PaperPosition',[0.5 0.5 7.5 10]);
set(hFig,'PaperPosition',[0.0 0.0 8.5 11]);
set(hFig,'PaperSize',[8.5 11]);


numSlices = size(rdat,3);
if ~exist('sliceToShow','var')
    sliceToShow = ceil(numSlices/2);
elseif isempty(sliceToShow)
    sliceToShow = ceil(numSlices/2);
end


% Summarize file
% hdr = getpfilehdr(strFile);
hdr = ge_pfilehdr(strFile);
[ignore,strName,strExt] = fileparts(strFile);
strDate = hdr.rdb.scan_date(1:9);
strTime = hdr.rdb.scan_time(1:5);

dOutScanner = hdr.rdb.user32;
dInScanner = hdr.rdb.user33;

hAxZeroD = subplot(321);
% strText = sprintf('File summary:\nFile: %s\nDate: %s\nTime: %s\nSlice shown: %d\n\nEstimated delays:\n... Reverse: %d\n... Forward: %d\n',...
%    [strName strExt],strDate,strTime,sliceToShow,dIn,dOut);
strText = sprintf('File summary:\nFile: %s\nDate: %s\nTime: %s\nSlice shown: %d\n\nDelays set on scanner:\n... Reverse: %d\n... Forward: %d\n\nEstimated delays:\n... Reverse: %d\n... Forward: %d\n\n\n\n\n',...
    [strName strExt],strDate,strTime,sliceToShow,dInScanner,dOutScanner,dIn,dOut);

% Delay=0
imgZeroD = ddat(:,:,sliceToShow,21);
show(imgZeroD);

hold on;
locshowgrid(imgZeroD);
hText = text(1,-24,strText);
locdoborders(imgZeroD,'b')
title('ddat (reverse): Delay = 0','color','b');


hAxZeroR = subplot(323);
imgZeroR = rdat(:,:,sliceToShow,21);
show(imgZeroR);
hold on;
title('rdat (forward): Delay = 0','color','r');
locshowgrid(imgZeroR);
locdoborders(imgZeroR,'r');

hAxDdat = subplot(322);
show(tile(squeeze(ddat(:,:,sliceToShow,:))));
set(hAxDdat,'xticklabel','');
title('ddat (reverse)');

hAxRdat = subplot(324);
show(tile(squeeze(rdat(:,:,sliceToShow,:))));
xlabel('rdat (forward)');

set([hAxDdat;hAxRdat;hAxZeroD;hAxZeroR],'xticklabel','');
set([hAxDdat;hAxRdat;hAxZeroD;hAxZeroR],'yticklabel','');
%set(hAx_ddatDelay0,'color','b','linewidth',4);



hAxZdiff = subplot(325);
iDelay = -20:20;
hMesh = mesh(iDelay,iDelay,zdiff,zdiff);
title('zdiff');

set(hAxRdat,'pos',[0.4    0.0   0.55    0.55]);   
set(hAxDdat,'pos',[0.4    0.45   0.55    0.55]);

% Rectangles
axes(hAxDdat);
hold on;
hSqIn = rectangle('position',[390 130 55 55],'edgecolor',[0 0 1],'linewidth',2);

axes(hAxRdat);
hold on;
hSqOut = rectangle('position',[390 130 55 55],'edgecolor',[1 0 0],'linewidth',2);

% set(hAxZdiff,'pos', [0.1    0.1    0.20    0.20]);
% set(hAxZeroR,'pos',[0   0.35    0.3347    0.2157])
% set(hAxZeroD,'pos',[0.0 0.6 0.3347    0.2157])
set(hAxZdiff,'pos', [0.1    0.05    0.20    0.20]);
set(hAxZeroR,'pos',[0   0.3    0.3347    0.2157])
set(hAxZeroD,'pos',[0.0 0.55 0.3347    0.2157])
print(hFig,'-dpdf',strFileOut);
close(gcf);

% -------------------------------
function locshowgrid(dat,mcolor)
M = size(dat,1);
N = size(dat,2);

for k = 1:8:M
    x = [1 N];
    y = [k k];
    plot(x,y,'Color','w','LineStyle','-');
    plot(x,y,'Color','k','LineStyle',':');
end

for k = 1:8:N
    x = [k k];
    y = [1 M];
    plot(x,y,'Color','w','LineStyle','-');
    plot(x,y,'Color','k','LineStyle',':');
end

hold off

% -------------------------------
function locdoborders(dat,mcolor)
X = size(dat,1);
Y = size(dat,2);
hB = line([0 X],[Y Y],'color',mcolor,'linewidth',2);
hT = line([0 X],[1 1],'color',mcolor,'linewidth',2);
hL = line([1 1],[0 Y],'color',mcolor,'linewidth',2);
hR = line([X X],[0 Y],'color',mcolor,'linewidth',2);
