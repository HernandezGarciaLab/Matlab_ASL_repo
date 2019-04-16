function casFilesOut = spm_slicetiming_patch(strSubject,strSTPrefix)
% spm_slice_timing_patch - given subject, does spm slicetiming and realign
% routines on existing data (meant to be run on data already processed with
% incorrect fsl slicetimer)
%
% INPUTS
% strSubject - string, name of subject directory.  Must be an absolute
%   path, or located directly beneath current directory. Default: pwd
% strSTPrefix - string, the string to be prepended to filenames of
%   slice-time corrected images. Default 's'.  
%
% OUTPUTS
% [explicit] casFilesOut - cell array of strings containing filenames of slice-time
% corrected and realign/resliced images.
% [implicit] the actual slice-timed, plus slice-timed with realigned images produced
% 
% EXAMPLE
% strSubject = 'subject';
% spm_slicetiming_patch(strSubject);

% Author - Krisanne Litinas
% $Id: spm_slicetiming_patch.m 1279 2014-03-24 20:06:25Z klitinas $
% $HeadURL: svn+ssh://klitinas@anger.engin.umich.edu/svn/matlab/img/trunk/spm_slicetiming_patch.m $

%%if nargin == 0 
strFullCurDir = pwd;
[strPath,strCurDir] = fileparts(strFullCurDir); 
if ~strcmpi(strCurDir,strSubject)
    if exist(strSubject,'dir')
        cd(strSubject);
    else
        error('fmrilab:invalidsubjectdir','Error: Subject directory "%s" does not exist',strSubject);
    end
end

if ~exist('strSTPrefix','var')
    strSTPrefix = 's';
end

% Get list of "run_##.nii" files (and func dirs).
casFilesRecursive = getallrecursivefiles(pwd);
strPatRunFile = [filesep 'run_\d{2}' filesep 'run_\d{2}.nii'];
iMatch = findnonemptycells(regexpi(casFilesRecursive,strPatRunFile));
casFilesNii = casFilesRecursive(iMatch);
casDirsFunc = cellfun(@fileparts,casFilesNii,'uni',false);

numRuns = length(casFilesNii);
fprintf('\nFound %d functional runs.',numRuns);

strTmpCWD = pwd;
casFilesOut = cell(numRuns,1);

% Now loop through all functional runs
for i = 1:numRuns
    strDirFunc = casDirsFunc{i};
    [ignore,strNiiBase,strExt] = fileparts(casFilesNii{i});
    fprintf('\n... Working in directory %s',strDirFunc);
    try
        cd(strDirFunc);
        strPhysCorrected = ['p' strNiiBase strExt];
        if exist(strPhysCorrected,'file')
            strNiiToCorrect = fullfile(pwd,strPhysCorrected);
        else
            strNiiToCorrect = casFilesNii{i};
        end
        strFileSTCorrected = do_spm_slice_timing(strNiiToCorrect,strSTPrefix);
        strFileOut = do_spm_realign_reslice(strFileSTCorrected);
        casFilesOut{i} = strFileOut;
    catch lasterr
        strErr = lasterr;
        fprintf('\n\nWARNING: files in dir %s did not process successfully!!\n\n',strDirFunc);
        % fprintf('\n...error message: %s\n',strErr);
        continue;
    end
    cd(strTmpCWD);
end

% Change back to original directory.
cd(strFullCurDir);
