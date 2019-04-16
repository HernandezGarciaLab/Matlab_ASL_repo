function write_shorts(data, rfpfname)
% function write_shorts(data, rfpfname)
%
% write out a waveform in binary format so that EPIC can read it
% You must run this before it will run on the scanner
%     xlatebin -o filename.rho rfpfname

% scale the data from 0 to 2^15 -1
data =  (2^15-1)*(data -min(data)) / max(data);

% put EOS bit into file
if rem(data(end) , 2) == 0
    data(end) = data(end) - 1;
end

fid=fopen([rfpfname,'.bin'],'w','b');
fwrite(fid, data, 'short');
fclose(fid);

end

