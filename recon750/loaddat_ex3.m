function dat = loaddat_ex3(phnum,slnum,scaninfo,fid);
% Returns data for one slice at one frame, for all coils and shots.
% dat = [ndat ncoils*npr], where npr = # leafs
% $Id: loaddat_ex3.m,v 1.7 2013/02/06 02:21:52 jfnielse Exp $

rhptsize  = 2;                                 % data is stored in short int format (int16)
echo = 1;
frame = phnum+1;
slice = slnum+1;

% calculate size of data chunks, then read data
rhnframes  = scaninfo.npr*scaninfo.nphases+1;   % the spiral psd saves views and time-frames ("phases") in loaddab 'view' slot
echores    = scaninfo.ndat*rhnframes;           % number of data points per echo (see pfilestruct.jpg)
sliceres   = (scaninfo.concat+1)*echores;       % rhnecho = concat + 1
coilres    = scaninfo.nslices * sliceres;       % number of data points per receive coil

dat = zeros([scaninfo.ndat scaninfo.ncoils*scaninfo.npr]);
for coil = 1:scaninfo.ncoils
	offsetres = (coil-1)*coilres+ (slice-1)*sliceres + (echo-1)*echores + (frame-1)*scaninfo.ndat*scaninfo.npr + scaninfo.ndat;
	offsetbytes = 2*rhptsize*offsetres;
	fseek(fid, scaninfo.headersize+offsetbytes, 'bof');
	for lp = 1:scaninfo.npr
		dtmp = fread(fid, 2*scaninfo.ndat, 'int16');
		dat(:,(coil-1)*scaninfo.npr+lp) = complex(dtmp(1:2:end), dtmp(2:2:end));
	end
end

return;
