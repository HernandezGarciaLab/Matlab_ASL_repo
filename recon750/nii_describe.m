function nii_describe(strFileNii,strDescription,strFileOut)
% EXAMPLES
% strFileNii = 'prun_01.nii';
% strDescription = 'run_01+retroicor';
% strFileOut = 'new_prun_01.nii';
% 
% [1] overwrite input file
% 
%       nii_describe(strFileNii,strDescription)
% 
% [2] create new file
% 
%       nii_describe(strFileNii,strDescription,strFileOut)
% 

% Author - Krisanne Litinas
% $Id: nii_describe.m 1594 2014-11-07 20:47:42Z klitinas $

if length(strDescription) > 79
    fprintf('\nInvalid description %s - must be < 80 characters\n',strDescription);
    return
end

strPad = repmat(' ',1,80-length(strDescription));
strDesc = [strDescription strPad];
[img,hdr] = read_nii_img(strFileNii);
hdr.descrip = strDesc;

if ~exist('strFileOut','var')
   strFileOut = strFileNii; 
end

write_nii(strFileOut,img,hdr,0);
