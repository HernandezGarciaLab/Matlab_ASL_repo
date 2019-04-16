function vDiffs = studyfmdiffs(strDirStudy)
% EXAMPLE
% strDirStudy = '/export2/data/klitinas/mr750/den13wmr00001';
% vDiffs = studyfmdiffs(strDirStudy)

% $Id: studyfmdiffs.m 1279 2014-03-24 20:06:25Z klitinas $
% $HeadURL: svn+ssh://klitinas@anger.engin.umich.edu/svn/matlab/img/trunk/studyfmdiffs.m $

strDirOld = pwd;
cd(strDirStudy);

% Get list of fieldmaps (in order of timestamp)
%[~,strFiles] = unix('find ./ -name "fmfile.mat" -type f | xargs stat --format "%Y:%n" | sort -n | cut -d":" -f2');
[~,strFiles] = unix('find ./func/ -name "fmfile.mat" -type f | xargs stat --format "%Y:%n" | sort -n | cut -d":" -f2');

if isempty(strFiles)
    return
end

casSplit=strsplit('.mat',strFiles,'append');
casFiles = casSplit;
casFiles(end) = [];
numFiles = numel(casFiles);

vDiffs = nan(numFiles-1,1);
for i = 1:numFiles-1
   strFileOne = strtrim(casFiles{i});
   strFileTwo = strtrim(casFiles{i+1});
   vDiffs(i) = fmdiffs(strFileOne,strFileTwo);
end


cd(strDirOld);
