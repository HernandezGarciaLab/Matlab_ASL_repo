function a = dofontsize(sz)
%function a = dofontsize(sz)

dlha = get(gca,'Title');
set(dlha(:),'FontSize',sz);
set(dlha(:),'FontWeight','Bold');

dlha = get(gca,'XLabel');
set(dlha(:),'FontSize',sz);
set(dlha(:),'FontWeight','Bold');

dlha = get(gca,'YLabel');
set(dlha(:),'FontSize',sz);
set(dlha(:),'FontWeight','Bold');

dlha = get(gca,'ZLabel');
%set(dlha(:),'FontSize',sz);

%dlha = get(gca,'ZTickLabels');
%set(dlha(:),'FontSize',sz);

set(gca, 'FontSize',sz)

a = sz;
set(legend,'FontSize',sz);
set(legend,'color','none');
return
