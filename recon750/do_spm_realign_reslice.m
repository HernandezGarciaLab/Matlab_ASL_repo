function strFileOut = do_spm_realign_reslice(strFileNii,strPrefix)
% do_spm_realign_reslice.m - wrapper for spm8 realign:est&write module.
% given .nii image, realigns it with the 'alignref.nii' image that should be 
% located two levels above the image's location.
%
% INPUTS
% strFileNii - string, filename of .nii to be realigned
% strPrefix - string, prefix that will be tacked on to output name (default 'r')
%
% OUTPUTS
% strFileOut - string, filename of .nii that has been realigned
%
% EXAMPLES
% strFileNii = 'prun_01.nii';
%
% [1] strFileCorrected = do_spm_slice_timing(strFileNii);
% 
% [2] strFileCorrected = do_spm_slice_timing(strFileNii,'x');

% Author - Krisanne Litinas
% $Id: do_spm_realign_reslice.m 1279 2014-03-24 20:06:25Z klitinas $
% $HeadURL: svn+ssh://klitinas@anger.engin.umich.edu/svn/matlab/img/trunk/do_spm_realign_reslice.m $

% Give prefix 's' if not specified
if ~exist('strPrefix','var')
    strPrefix = 'r';
end

% Parse filename to find alignref.nii
[strPath,strName,strExt] = fileparts(strFileNii);

strDirCur = pwd;
if ~isempty(strPath)
    cd(strPath)
    strFileNiiTmp = [strName strExt];
else
    strFileNiiTmp = strFileNii;
end

strSubjDir = fileparts(fileparts(pwd));
strFileAlignRef = fullfile(strSubjDir,'alignref.nii');
strAlignOut = sprintf('%s,1',strFileAlignRef);

% Read header for needed info
hdr = spm_read_hdr(strFileNiiTmp);
numVols = hdr.dime.dim(5);

% Format data list to go in spm job
casNiiVols = strread(num2str(1:numVols),'%s');
casNiiFiles = repmat({fullfile(pwd,strFileNiiTmp)},numVols,1);
casNiiOut = strcat(casNiiFiles,repmat({','},numVols,1),casNiiVols);
casDataList = [strAlignOut; casNiiOut];

matlabbatch{1}.spm.spatial.realign.estwrite.data = {casDataList};
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.sep = 4;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.rtm = 0;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.interp = 2;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.weight = '';
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.which = [2 1];
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.interp = 4;
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.mask = 1;
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.prefix = strPrefix;

% Save job (not actually needed)
strFileJob = 'realign_job.mat';
save(strFileJob,'matlabbatch');

% Run job
spm_jobman('initcfg')
spm_jobman('run', matlabbatch);

% Return output file
[strPath,strNameIn,strExt] = fileparts(strFileNii);
strNameOut = [strPrefix strNameIn strExt];
strFileOut = fullfile(strPath,strNameOut);
