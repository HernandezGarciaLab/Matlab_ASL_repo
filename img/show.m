function out = show(a,windfact)
% usage .. show(a,f);
% displays matrix "a" as a greyscale image in the matlab window
% and "f" is the optional window factors [min,max]

global RT_MODE

if isempty(RT_MODE) || (RT_MODE ~=1)
    doColorBar=1;
else
    doColorBar=0;
end

if exist('windfact') == 0, 
  amin = min(min(a));
  amax = max(max(a));
  minmax = [amin,amax];
  a = (a  - amin);
else
  amin = windfact(1);
  amax = windfact(2);
  minmax = [amin,amax];
  a = (a  - amin);

end


%a(a>amax) = amax;


a = a./(amax-amin).*255;
a(a < amin)=0;
a(a>255) = 255;

imageHandle = image(a);


if doColorBar
    ncbar_labels=5;
    c1 = colorbar;
    set(c1,'YTick',linspace(1,256,ncbar_labels),...
        'YTickLabel',linspace(amin,amax,ncbar_labels),...
        'FontSize',12);
end

if nargout==0 && isempty(RT_MODE),
  disp(['min/max= ',num2str(minmax(1)),' / ',num2str(minmax(2))]);
end;
