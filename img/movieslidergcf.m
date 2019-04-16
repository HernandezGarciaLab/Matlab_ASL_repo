function movieslidergcf(src,eventdata,hSlider,hTxt,func_data,func_hdr,fmin,args,myfig,myRange,x,y,z,roi,func_xyz,spm_hdr)
% movieslidergcf.m - part of ortho package, callback executed when slider is moved.

% Author - Krisanne Litinas
% $Id: movieslidergcf.m 740 2013-07-31 14:13:15Z klitinas $

% Get the position of the slider
locSlider = get(hSlider,'Value');
locSlider = round(locSlider);
set(hSlider,'TooltipString',num2str(locSlider));
set(hTxt,'String',num2str(locSlider));

% Reshape, scale, plot data.
d = reshape(func_data(locSlider,:), func_hdr.xdim, func_hdr.ydim, func_hdr.zdim);
dd = (d-fmin)*256/myRange;
if ~isempty(args.wscale)
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
fprintf('\r(x,y,z,t)=  (%d %d %d %d)', x, y, z, locSlider);

drawnow

if ~isempty(func_xyz)
    vx = func_xyz(:,1);
    vy = func_xyz(:,2);
    vz = func_xyz(:,3);
    
    % match the voxels in the spm to the anatomical frame of
    % reference
    
    [vx2, vy2, vz2 ] = vox2mm(spm_hdr, func_xyz);
    %[vx2, vy2, vz2 ] = mm2vox(hdr, [vx2, vy2, vz2]);
    [vx2, vy2, vz2 ] = mm2vox(spm_hdr, [vx2, vy2, vz2]);
    
    anat_xyz = [vx2 vy2 vz2];
    
    vx2 = round(vx2); vy2 = round(vy2); vz2 = round(vz2);
    
    h1 = findobj('tag','fig1');
    zind = find(vz2==z);
    axes(h1(1)),hold on,plot(vy2(zind), vx2(zind),'mx');
    
    h2 = findobj('tag','fig2');
    yind = find(vy2==y);
    axes(h2(1)),hold on,plot(vx2(yind), vz2(yind),'mx');
    
    xind = find(vx2==x);
    
    h3 = findobj('tag','fig3');
    axes(h3(1)),hold on,plot(vy2(xind), vz2(xind),'mx');
    
end

set(hSlider,'Value',locSlider);
set(hTxt,'String',num2str(locSlider));

% Plot vertical line in timecourse plot at correct frame.
hChild = get(myfig,'children');
hAxTime = findobj(hChild,'tag','tcourse');
hLineMyTime = findobj(hAxTime,'tag','mytimeline');
hObjOld = gca;
axes(hAxTime);
if isempty(hLineMyTime)
    
    yLim = get(hAxTime,'ylim');
    hLineMyTime = line([locSlider locSlider],yLim);
    set(hLineMyTime,'tag','mytimeline','color','k');
else
    set(hLineMyTime,'xdata',[locSlider locSlider]);
end
axes(hObjOld);
return