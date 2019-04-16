function append2niidesc(strFileNii,str2append)
% EXAMPLE
% strFileNii = 'run_01.nii';
% str2append = '_rtrcr'; % want to append '_rtrcr' to existing description
% append2niidesc(strFileNii,str2append)

% $Id: append2niidesc.m 1610 2014-11-18 21:11:32Z klitinas $

% Read header and make up new description
hdr = read_nii_hdr(strFileNii);
strDescOld = deblank(strtrim(hdr.descrip));
strDescNew = [strDescOld str2append];

% Check the length (shouldn't be > 79 chars)
if length(strDescNew) > 79
    fprintf('\nWarning: nii description ''%s'' too long - stripping the end\n',strDescNew);
    strDescNew = strDescNew(1:79);
end

% Write out the new header
nii_describe(strFileNii,strDescNew);