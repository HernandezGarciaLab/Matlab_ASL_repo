function histrelease

set(gcf,'UserData','keyup');
% get(gcf,'UserData')
%  hLines = findobj(gcf,'type','line');
% draggable(gco,'h','endfcn',@lineendfcn);
                        set(gcf,'WindowButtonDownFcn','histpress')
