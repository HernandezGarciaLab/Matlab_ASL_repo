function restoreoldniiheader(strFile,strFileWithHeader)
% EXAMPLE
% strFileCorrected = do_spm_slice_timing(strFileNii,'x');
% restoreoldniiheader(strFileCorrected,strFileNii);

% $Id: restoreoldniiheader.m 1279 2014-03-24 20:06:25Z klitinas $
% $HeadURL: svn+ssh://klitinas@anger.engin.umich.edu/svn/matlab/img/trunk/restoreoldniiheader.m $

% Get the header
fidHdr = fopen(strFileWithHeader,'r','l');
hdr = fread(fidHdr,348);
fclose(fidHdr);

% Modify the data file
fid = fopen(strFile,'r+');
fwrite(fid,hdr);

% Check the voxel offset value
fseek(fid,108,'bof');
fwrite(fid,352,'float32');

% Set scl_slope = 1 (won't actually make a difference since scl_inter = 0 but will do anyway.)
fseek(fid,112,'bof');
fwrite(fid,1,'float32');
fclose(fid);
