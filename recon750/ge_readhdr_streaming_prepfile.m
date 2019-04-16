function [hdr] = ge_readhdr_streaming_prepfile(prepfile)

% $Id: ge_readhdr_streaming_prepfile.m 1580 2014-10-28 17:00:54Z klitinas $

id = fopen(prepfile, 'r', 'l');

fseek(id, 16*4, -1);  % go to start of raw data file

ver = fread(id,1,'float32');
str = num2str(ver);
rdbm_rev = str2double(str);
fseek(id,16*4,-1);
hdr = read_rdb_hdr(id,rdbm_rev);

fclose(id);
