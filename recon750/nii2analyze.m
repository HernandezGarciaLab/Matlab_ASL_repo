function nii2analyze(casFilesNii)
% EXAMPLE
% casFilesNii = {'./arun_01.nii;./rtmp_variance.nii;./run_01.nii};
% nii2analyze(casFilesNii);

% $Id: nii2analyze.m 1279 2014-03-24 20:06:25Z klitinas $
% $HeadURL: svn+ssh://klitinas@anger.engin.umich.edu/svn/matlab/img/trunk/nii2analyze.m $

% Loop through and convert each file
for i = 1:length(casFilesNii)
    strFile = casFilesNii{i};
    strFileBse = strrep(strFile,'.nii','');
    nii2avw(strFileBse)
end
