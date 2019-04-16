function imgDominate(rootname, xyz, DesMat)
%function imgDominate(rootname, [x,y,z], DesMat)
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

suffix = rootname(end-3:end);
[data, h] = read_img(rootname);

if suffix=='.nii'
	h = nii2avw_hdr(h);
end 


imgDominateFun(h, data, xyz, DesMat);

return

