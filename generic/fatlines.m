function fatlines(thick)
if nargin<1
    thick=2;
end
dlha = get(gca,'children');
set(dlha(:),'LineWidth',thick);
set(gca,'LineWidth',thick);
set(gca,'color','none');
