function show_rotation(strPfile,strDir,sliceToShow,strFileOut)
% show_rotation.m - version of delay_calc_summary to show a given spiral
% direction (in or out) instead of assuming the pfile has both in/out
% components
%
% INPUTS
% strPfile - name of the pfile
% strDir - 'in' or 'out' to show spiral in or out rotations respectively (default in)
% sliceToShow - which slice to show in plot [default ceil(nslices/2) ]
% strFileOut - if specified, makes pdf with this name
%
% OUTPUTS
% [implicit] - tiled plot of reconstructed first time point of
%   pfile with delay terms [-21:21]

% Author - Krisanne Litinas
% $HeadURL: svn+ssh://klitinas@anger.engin.umich.edu/svn/matlab/img/trunk/show_rotation.m $
% $Id: show_rotation.m 1436 2014-06-18 18:47:02Z klitinas $

warning off;
if strcmpi(strDir,'out')
    strIO = 'QO';
else
    strIO = 'QI';
end

dellist = -20:20;

sprec1(strPfile,'cp','m');
hdr = ge_pfilehdr(strPfile);

for x=1:length(dellist)
    sprec1(strPfile,'cp','h','t','1',strIO,'d',int2str(dellist(x)));
    tmp=dir('vol*.img');
    fname=tmp.name;
    %[img,hdr] = read_img(fname);
    %imgR = reshape(img,hdr.xdim,hdr.ydim,hdr.zdim);
    dat(:,:,:,x)=double(analyze75read(fname));
    %ddat(:,:,:,x)=imgR;
    !rm vol*.img vol*.hdr
end

  
hFig = figure;
show(tile(squeeze(dat(:,:,sliceToShow,:))));
set(gca,'xticklabel','');
set(gca,'yticklabel','');

[~,strName,strExt] = fileparts(strPfile);
strTitle = sprintf('%s%s: Rotations (spiral %s)',strName,strExt,strDir);
title(strTitle);

if exist('strFileOut','var')
    print(hFig,'-dpdf',strFileOut);
end