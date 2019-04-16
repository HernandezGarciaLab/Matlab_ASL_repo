function blnShifted = hasheadershift(hdr)
% EXAMPLE
% fid = fopen('P32768.7','r','l');
% hdr = read_gehdr(fid);
% blnShifted = hasheadershift(hdr);

% $Id: hasheadershift.m 1279 2014-03-24 20:06:25Z klitinas $
% $HeadURL: svn+ssh://klitinas@anger.engin.umich.edu/svn/matlab/img/trunk/hasheadershift.m $

% if strcmpi(hdr.image.psdname(1),'u') && strcmpi(hdr.series.pure_cfg_params(1),'r') && strcmpi(hdr.series.landmark_uid(1),'+')
if strcmpi(hdr.image.sop_uid(1),'+') && strcmpi(hdr.series.pure_cfg_params(1),'r') && strcmpi(hdr.series.landmark_uid(1),'+')
    blnShifted = 0;
else
    blnShifted = 1;
end
