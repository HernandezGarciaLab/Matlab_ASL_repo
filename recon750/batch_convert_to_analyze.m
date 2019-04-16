function batch_convert_to_analyze(strListFile,strFlip)
% batch_convert_to_analyze.m - given text file with list of nifti files,
% converts all 3d analyze format
% 
% INPUTS
% strListFile - name of file containing list of niftis to convert (expects one filename per line)
% strFlip [optional] - 'fx', 'fy', or 'fz' to flip in x,y,z respectively [default no flipping]
% 
% OUTPUTS
% [implicit] - 3d .img/.hdr files with data from .nii files in strListFile 
% 
% EXAMPLES
% strListFile = './niifiles.log';
% batch_convert_to_analyze(strListFile);
% batch_convert_to_analyze(strListFile,'fx');

% Author - Krisanne Litinas
% $Id: batch_convert_to_analyze.m 1523 2014-09-19 19:45:14Z klitinas $

% Default don't do any flips
if ~exist('strFlip','var')
    strFlip = '';
end

fid = fopen(strListFile,'r');
c = textscan(fid,'%s');
casFiles = c{1};
fclose(fid);

numFiles = length(casFiles);
for i = 1:numFiles
    strFile = casFiles{i};
    [~,strName] = fileparts(strFile);
    img4d_split(strFile,strName,'a',strFlip);
end
