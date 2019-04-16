function moviegogcf(src,eventdata,func_data,func_hdr,fmin,args,myfig,myRange,x,y,z,roi,doAVI,hSlider,hTxt)
% moviegogcf.m - ortho code, executed when Play button pressed.

% Author - Krisanne Litinas
% $Id: moviegogcf.m 740 2013-07-31 14:13:15Z klitinas $

%for count=1:size(func_data,1)
locSlider = get(hSlider,'Value');
locSlider = round(locSlider);
if locSlider == 0
    locSlider = 1;
end

for count = locSlider:size(func_data,1)
    
    d = reshape(func_data(count,:), func_hdr.xdim, func_hdr.ydim, func_hdr.zdim);
    dd = (d-fmin)*256/myRange;
    if ~isempty(args.wscale)
        % dd = (d-wscale(1))*256 / (args.wscale(2)-args.wscale(1));
        dd = (d-args.wscale(1))*256 / (args.wscale(2)-args.wscale(1));

        dd(find(dd>256)) = 256;
        dd(find(dd<1))=1;
    end
    
    figure(myfig)
    % [fig1, fig2, fig3] =  ov(func_hdr,dd,x,y,z,roi);
    
    xP = round(mean(x));
    yP = round(mean(y));
    zP = round(mean(z));
    [fig1, fig2, fig3] =  ov(func_hdr,dd,xP,yP,zP,roi);
    
    fprintf('\r(x,y,z,t)=  (%d %d %d %d)', x, y, z, count);
    
    drawnow
    if doAVI
        M = getframe(gcf);
        aviF=addframe(aviF, M);
    end
    
    set(hSlider,'Value',count);
    set(hTxt,'String',num2str(count));
    
    
    hChild = get(myfig,'children');
    hAxTime = findobj(hChild,'tag','tcourse');
    hLineMyTime = findobj(hAxTime,'tag','mytimeline');
    hObjOld = gca;
    axes(hAxTime);
    if isempty(hLineMyTime)
        
        yLim = get(hAxTime,'ylim');
        hLineMyTime = line([count count],yLim);
        set(hLineMyTime,'tag','mytimeline','color','k');
    else
        set(hLineMyTime,'xdata',[count count]);
    end
    axes(hObjOld);
    
    pause(0.1)
end

if doAVI
    aviF=close(aviF);
end
% redraw the time series plot
%         subplot 224, plot(tdata,'r'); hold off;
%         xlabel('scan #'), title('Signal')
%         set(gca,'Position',[ 0.55    0.15    0.40    0.30]);axis tight ;