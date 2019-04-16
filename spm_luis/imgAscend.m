function imgAscend(rootname, xyz, DesMat)
%function imgAscend(rootname, [x,y,z], DesMat)
%
% (c) 2005 Luis Hernandez-Garcia
% University of Michigan
% report bugs to:  hernan@umich.edu
%
% either we filter or pre-whiten

doWhiten = 0;
doFilter=1;

x = xyz(:,1);
y = xyz(:,2);
z = xyz(:,3);


h = read_hdr(rootname);
data = read_img_series(rootname(1:end-8));


imgAscendFun(h, data, xyz, DesMat);

return

