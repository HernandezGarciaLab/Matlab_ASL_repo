function strFileOut = do_spm_slice_timing(strFileNii,strPrefix,strPreserveHeader,strSliceDir)
% do_spm_slice_timing.m - wrapper for spm8 slice-timing module
%
% INPUTS
% strFileNii - string, filename of .nii to be corrected
% strPrefix - string, prefix that will be tacked on to output name (default 't')
% strPreserveHeader - [optional] string, 'h' to write out slice-timed image using original header, 
%                     done for back-compatibility with old stream (default doesn't restore old header).
% strSliceDir - [optional] string, 'bu' for bottom-up acquisition, 'td' for top-down. (default bu)
%
% OUTPUTS
% strFileOut - string, filename of .nii that has been slice-timed corrected
%
% EXAMPLES
% strFileNii = 'subject/func/run_01/run_01.nii';
%
% [1] strFileCorrected = do_spm_slice_timing(strFileNii);
% 
% [2] strFileCorrected = do_spm_slice_timing(strFileNii,'x');
% 
% [3] strFileCorrected = do_spm_slice_timing(strFileNii,'x','h','td');

% Author - Krisanne Litinas
% $Id: do_spm_slice_timing.m 1279 2014-03-24 20:06:25Z klitinas $
% $HeadURL: svn+ssh://klitinas@anger.engin.umich.edu/svn/matlab/img/trunk/do_spm_slice_timing.m $

% Give prefix 's' if not specifiedd
if ~exist('strPrefix','var')
    strPrefix = 't';
end

% Default slice order (should be bottom:up, but sometimes we get a top:down acq)
if ~exist('strSliceDir','var')
    strSliceDir = 'bu';
end

% Read header for needed info
hdr = spm_read_hdr(strFileNii);
numSlices = hdr.dime.dim(4);

switch lower(strSliceDir)
    case 'bu'
        sliceOrder = 1:1:numSlices;
        refSlice = floor(numSlices/2);
    case 'td'
        sliceOrder = numSlices:-1:1;
        refSlice = ceil(numSlices/2);
    otherwise
        error('fmrilab:invalidslicedir','Invalid slice order %s, must be td (top-down) or bu (bottom-up).',strSliceDir);
end

tr = 3;
mtiming = [tr/numSlices, tr/numSlices];

% Do slice timing
spm_slice_timing(strFileNii,sliceOrder,refSlice,mtiming,strPrefix)

fprintf('\n\n----\nNOTE:\nTR is not actually 3.0, SPM just needs an input value but it is not used.\n----\n\n')

% Return output file
[strPath,strNameIn,strExt] = fileparts(strFileNii);
strNameOut = [strPrefix strNameIn strExt];
strFileOut = fullfile(strPath,strNameOut);

% If specified, modify header in output file so that it keeps the same
% header as input .nii file
if exist('strPreserveHeader','var')
    if strcmpi(strPreserveHeader,'h')
        restoreoldniiheader(strFileOut,strFileNii);
    else 
        fprintf('\nUnknown input "%s", use "h" to restore the original header.',strPreserveHeader);
    end
end
