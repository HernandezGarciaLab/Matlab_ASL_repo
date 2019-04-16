function blankify_nii_hdr(strFileNii,strFileNiiWrite)
% EXAMPLES
% strFileNii = 'run_01.nii';
% [1] 
% blankify_nii_hdr(strFileNii);
% 
% [2] 
% strFileNiiOut = 'run_01_blankhdr.nii';
% blankify_nii_hdr(strFileNii,strFileNiiOut)

% $Id: blankify_nii_hdr.m 1279 2014-03-24 20:06:25Z klitinas $
% $HeadURL: svn+ssh://klitinas@anger.engin.umich.edu/svn/matlab/img/trunk/blankify_nii_hdr.m $

if ~exist('strFileNiiWrite','var')
    strFileNiiWrite = strFileNii;
end

[img,hdr] = read_nii_img(strFileNii);
hdrOut = hdr;
hdrOut.data_type = repmat(' ',1,length(hdr.data_type));
hdrOut.db_name = repmat(' ',1,length(hdr.db_name));
hdrOut.pixdim(1) = 0; % check this
hdrOut.pixdim(5:8) = 0; % check this
hdrOut.scl_slope = 0;
hdrOut.scl_inter = 0;
hdrOut.glmax = 0;
hdrOut.glmin = 0;
hdrOut.qform_code = 0;
hdrOut.sform_code = 0;
hdrOut.quatern_b = 0;
hdrOut.quatern_c = 0;
hdrOut.quatern_d = 0;
hdrOut.qoffset_x = 0;
hdrOut.qoffset_y = 0;
hdrOut.qoffset_z = 0;
hdrOut.srow_x = zeros(1,4);
hdrOut.srow_y = zeros(1,4);
hdrOut.srow_z = zeros(1,4);
hdrOut.originator = zeros(5,1);

write_nii(strFileNiiWrite,img,hdrOut,0);
