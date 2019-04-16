function strFileOut = do_spm8_slice_timing(strFileNii,strPrefix,strPreserveHeader,strSliceDir,strSliceOrder)
% do_spm8_slice_timing.m - wrapper for spm8 slice-timing module.  This differs from do_spm_slice_timing
% such that here it calls sliceordervec.m to correctly account for ref slice and order vector
% based on slice acquisition/order and odd/even numbering. Also added optional strSliceOrder input for
% interleaved/sequential.
%
% INPUTS
% strFileNii - string, filename of .nii to be corrected
% strPrefix - string, prefix that will be tacked on to output name (default 't')
% strPreserveHeader - [optional] string, 'h' to write out slice-timed image using original header, 
%                     done for back-compatibility with old stream (default doesn't restore old header).
% strSliceDir - [optional] string, 'bu' for bottom-up acquisition, 'td' for top-down. (default bu)
% strSliceOrder - [optional] string,'seq' for sequential acquisition, 'int' for interleaved (default seq)
%
% OUTPUTS
% strFileOut - string, filename of .nii that has been slice-timed corrected
%
% EXAMPLES
% strFileNii = 'subject/func/run_01/run_01.nii';
%
% [1] strFileCorrected = do_spm8_slice_timing(strFileNii);
% 
% [2] strFileCorrected = do_spm8_slice_timing(strFileNii,'x');
% 
% [3] strFileCorrected = do_spm8_slice_timing(strFileNii,'x','h','td');
%
% [4] strFileCorrected = do_spm8_slice_timing(strFileNii,'x','h','td','int'); % interleaved order

% Author - Krisanne Litinas
% $Id: do_spm8_slice_timing.m 1545 2014-10-02 20:10:10Z klitinas $
% $HeadURL: svn+ssh://klitinas@anger.engin.umich.edu/svn/matlab/img/trunk/do_spm8_slice_timing.m $

% Give prefix 's' if not specifiedd
if ~exist('strPrefix','var')
    strPrefix = 't';
end

% Default slice direction (should be bottom:up, but sometimes we get a top:down acq)
if ~exist('strSliceDir','var')
    strSliceDir = 'bu';
end

% Default slice order is sequential
if ~exist('strSliceDir','var')
    strSliceOrder = 'seq';
end

% Read header for needed info
hdr = spm_read_hdr(strFileNii);
numSlices = hdr.dime.dim(4);

% switch lower(strSliceDir)
%     case 'bu'
%         sliceOrder = 1:1:numSlices;
%         refSlice = floor(numSlices/2);
%     case 'td'
%         sliceOrder = numSlices:-1:1;
%         refSlice = ceil(numSlices/2);
%     otherwise
%         error('fmrilab:invalidslicedir','Invalid slice order %s, must be td (top-down) or bu (bottom-up).',strSliceDir);
% end
[sliceOrder,refSlice] = sliceordervec(numSlices,strSliceDir,strSliceOrder);

strFmt = ['\nUsing slice order:\n' repmat('%d ',size(sliceOrder))];
fprintf(strFmt,sliceOrder);

fprintf('\n\nUsing reference slice: %d\n',refSlice);

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
