function nii2avw(name)

% $Id: nii2avw.m 1279 2014-03-24 20:06:25Z klitinas $
% $HeadURL: svn+ssh://klitinas@anger.engin.umich.edu/svn/matlab/img/trunk/nii2avw.m $

[dnii hnii] = read_nii_img(name);
avwh = nii2avw_hdr(hnii);

write_img([name '.img'],dnii,avwh);
return
