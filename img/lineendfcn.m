function hMax= lineendfcn(fig)
% lineendfcn.m - executed when a sliding line in histogram plots are
% released.

% Author - Krisanne Litinas
% $Id: lineendfcn.m 737 2013-07-31 13:57:39Z klitinas $

hpp = gcf;
hp = gca;
strTagHist = get(hpp,'tag');
strTagOrth = [strTagHist(1:3) 'myfig'];
hFigOrth = findobj('tag',strTagOrth);

datOrth = guidata(hFigOrth);
x = datOrth.x;
y = datOrth.y;
z = datOrth.z;
anat_data = datOrth.img;

% Find all lines
hLines = findobj(hpp,'type','line');
    
% Find anat lines and do scaling
hMax = findobj(hLines,'tag','anat_hist_scaleMax');
hMin = findobj(hLines,'tag','anat_hist_scaleMin');
scaleMin = get(hMin,'xdata');
anatScaleMin = round(scaleMin(1));

scaleMax = get(hMax,'xdata');
anatScaleMax = round(scaleMax(1));

dat = (anat_data - anatScaleMin)*256 / (anatScaleMax-anatScaleMin);
dat(find(dat>256)) = 256;
dat(find(dat<1)) = 1;

% colormap
my_map=(0:255)';
my_map=[my_map my_map my_map]/256;
datOrth.wscale = [anatScaleMin anatScaleMax];

% Look for first SPM map to scale
if isfield(datOrth,'spm_img')
    spm_data = datOrth.spm_img;
    hMax = findobj(hLines,'tag','spm1_hist_scaleMax');
    hMin = findobj(hLines,'tag','spm1_hist_scaleMin');
    scaleMin = get(hMin,'xdata');
    spmScaleMin = scaleMin(1);
    
    scaleMax = get(hMax,'xdata');
    spmScaleMax = scaleMax(1);

    [dat , inds]= mk_overlay(spmScaleMin, dat, spm_data, 257);
    datOrth.threshold = [spmScaleMin spmScaleMax];

end

% Look for second SPM map to scale
if isfield(datOrth,'spm_img2')
    spm_data2 = datOrth.spm_img2;
    
     hMax = findobj(hLines,'tag','spm2_hist_scaleMax');
    hMin = findobj(hLines,'tag','spm2_hist_scaleMin');
    scaleMin = get(hMin,'xdata');
    spm2ScaleMin = scaleMin(1);

    scaleMax = get(hMax,'xdata');
    spm2ScaleMax = scaleMax(1);
    
    [dat , inds2]= mk_overlay(spm2ScaleMin, dat, spm_data2, 513);
    dat = mk_overlap(dat,inds,inds2);
    datOrth.threshold2 = [spm2ScaleMin spm2ScaleMax];
end

% Stash back in figure
guidata(hFigOrth,datOrth);

% Set status of keypress
hAx = hp;
hHistFig = hpp;
set(hHistFig,'UserData','keyup');

hTemp = findobj('type','text');
delete(hTemp);
set(hMin,'xdata',scaleMin);
set(hMax,'xdata',scaleMax);

datHist.anatScaleMax = anatScaleMax;
datHist.anatScaleMin = anatScaleMin;
guidata(hpp,datHist);
set(hHistFig,'WindowButtonMotionFcn','');

% Do the scaling
adjustwscale3(dat,hFigOrth,x,y,z)
return