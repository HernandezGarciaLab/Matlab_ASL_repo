function log_pfile_hdr_info(strFileP,strFileLog)
% EXAMPLE
% strFileP = 'sample_pfile.7';
% strFileLog = 'test.log;
% log_pfile_hdr_info(strFileP,strFileLog)

% Read the pfile header
fid = fopen(strFileP,'r','l');
hdr = read_gehdr(fid);
fclose(fid);

% If not specified specify output file name
if ~exist('strFileLog','var')
    strFileLog = strrep(strFileP,'.7','.log');
end

% Get some parameters (need to add a lot more)
nslices = hdr.rdb.nslices;
tr = hdr.image.tr;
te = hdr.image.te;
disdaq = hdr.rdb.datacq; % check this one

% Write to log file
fid = fopen(strFileLog,'w');
fprintf(fid,'%s\t%s','param','value');
fprintf(fid,'\n%s\t%d','nslices',nslices);
fprintf(fid,'\n%s\t%0.3f','tr',tr*1e-6);
fprintf(fid,'\n%s\t%0.3f','te',te*1e-6);
fprintf(fid,'\n%s\t%d','disdaq',disdaq);
fclose(fid);