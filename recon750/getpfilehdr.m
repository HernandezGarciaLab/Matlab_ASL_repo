function hdr = getpfilehdr(strFile)
% EXAMPLE
% strFile = './P32768.7';
% hdr = getpfilehdr(strFile);

% $Id: getpfilehdr.m 1279 2014-03-24 20:06:25Z klitinas $
% $HeadURL: svn+ssh://klitinas@anger.engin.umich.edu/svn/matlab/img/trunk/getpfilehdr.m $

% Check for file
if ~exist(strFile,'file')
    error('fmrilab:invalidfile','File %s does not exist',strFile);
end

% Read header
fid = fopen(strFile,'r','l');
hdr = read_gehdr(fid);
ver = hdr.rdb.rdbm_rev;

if ver <= 20.006
    % If header has character shift, read it using modified read_gehdr
    if hasheadershift(hdr)
        offset = 5;
        while  hasheadershift(hdr) && offset > -6
            hdr = read_shifted_gehdr(fid,offset);
            offset = offset - 1;
        end
    end
end

% Close file
fclose(fid);
