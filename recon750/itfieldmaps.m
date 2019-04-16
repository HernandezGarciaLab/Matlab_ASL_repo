function itfieldmaps(strFile,dIn,dOut)

% $Id: itfieldmaps.m 1279 2014-03-24 20:06:25Z klitinas $
% $HeadURL: svn+ssh://klitinas@anger.engin.umich.edu/svn/matlab/img/trunk/itfieldmaps.m $

% Spiral in
sprec2(strFile,'m','it','l','QI','fx','fy','n',64,'d',dIn)
strFileIn = sprintf('%s_in_d%d.mat',strrep(strFile,'.7',''),dIn);
movefile('fmfile.mat',strFileIn);

% Spiral out
sprec2(strFile,'m','it','l','QO','fx','fy','n',64,'d',dOut)
strFileOut = sprintf('%s_out_d%d.mat',strrep(strFile,'.7',''),dOut);
movefile('fmfile.mat',strFileOut);
