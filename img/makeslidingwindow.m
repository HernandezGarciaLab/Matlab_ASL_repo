function hAx = makeslidingwindow(hFig,strTagAx,vScale)
% makeslidingwindow.m - used in ortho code, given figure and axis tag,
% creates two draggable lines used to adjust image scale.

% Find axis to make lines
strTagFig = get(gcf,'tag');
hHistFig = findobj('tag',[strTagFig(1:3) 'histfig']);
hAx = findobj(hHistFig,'tag',strTagAx);

xLims = get(hAx,'xlim');
yLims = get(hAx,'ylim');

if isempty(vScale) || numel(vScale) == 1
    vScale = [];
    vScale(1) = 0;
    vScale(2) = xLims(2);
end

hold on;

% Minimum line
hLineMin = line;
set(hLineMin,'xData',[vScale(1) vScale(1)]);
set(hLineMin,'yData',yLims);
draggable(hLineMin,'h')

set(hLineMin,'linewidth',3.5,'color','r');
set(hLineMin,'tag',[strTagAx '_scaleMin']);

% Maximum line
hLineMax = line;
set(hLineMax,'xData',[vScale(2) vScale(2)]);
set(hLineMax,'yData',yLims);
draggable(hLineMax,'h')
set(hLineMax,'linewidth',3.5,'color','g');
set(hLineMax,'tag',[strTagAx '_scaleMax']);

% For now, max lines in SPM maps don't do anything, so we'll hide them.
if strfind(strTagAx,'spm')
    set(hLineMax,'visible','off');
end