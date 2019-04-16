function dat = loaddat_ex2(phnum,slnum,scaninfo,fid);
% this function should read the data for one slice at one frame
% it should include all the coils and all the shots
%
% order of data in file (rev/for, views(spirals), slices, coils)

% $Id: loaddat_ex2.m 242 2012-09-23 22:11:10Z klitinas $
DEBUG = 0;

if (scaninfo.sliceorder == 0)
	slnum2 = round((slnum+1.5)/2) + rem(slnum,2)*round((scaninfo.nslices+0.5)/2) - 1;
else
	slnum2 = slnum;
end
ncoils = scaninfo.ncoils;
ndat = scaninfo.ndat;
npr = scaninfo.npr;
concat = scaninfo.concat;
dat = zeros([ndat (concat+1)*npr*ncoils]);
% add one if odd numbered views
nodd = rem((scaninfo.nphmult*scaninfo.npr),2);
% nodd = 0;
% point to right view
coilskip = scaninfo.nslices*(concat+1)*(scaninfo.nphmult+1+nodd)*npr*4*scaninfo.ndat;
nproj = slnum2*(concat+1)*(scaninfo.nphmult+1+nodd)*scaninfo.npr + phnum*scaninfo.npr + 1;
echostep = (scaninfo.nphmult+1+nodd)*scaninfo.npr;

% LHG trying to do multi-shot
% if npr>1
% 	coilskip = scaninfo.nslices*(concat+1)*(scaninfo.nphmult+nodd)*npr*4*scaninfo.ndat;
% 	nproj = slnum2*(concat+1)*(scaninfo.nphmult+nodd)*scaninfo.npr + phnum*scaninfo.npr + 1;
% 	echostep = (scaninfo.nphmult+nodd)*scaninfo.npr;
% end

for coilnum = 1:ncoils
	coiloff = coilskip*(coilnum-1);
	offs = scaninfo.headersize + nproj*ndat*4 + coiloff;
	fseek(fid,offs,'bof');
	for lp = 1:npr
		if DEBUG
			fprintf('\ncoilnum = %d, slnum = %d, lp =%d, nproj= %d, ndat= %d, offs = %d', ...
				coilnum, slnum2, lp, nproj, ndat, offs);
		end
		ktmp = fread(fid,2*ndat,'int16');
		dat(:,lp+(coilnum-1)*(concat+1)*npr) = ktmp(1:2:end) + i.*ktmp(2:2:end);
%		dat(:,lp+(coilnum-1)*(concat)*npr) = ktmp(1:2:end) + i.*ktmp(2:2:end);
	end

	if (concat == 1)
		offs = scaninfo.headersize + (nproj+echostep)*ndat*4 + coiloff;
		fseek(fid,offs,'bof');
		for lp = 1:npr
			if DEBUG
				fprintf('\ncoilnum = %d, slnum = %d, lp =%d, nproj= %d, ndat= %d, offs = %d', ...
					coilnum, slnum2, lp, nproj, ndat, offs);
			end
			ktmp = fread(fid,2*ndat,'int16');
			dat(:,lp+(coilnum-1)*(concat+1)*npr+npr) = ktmp(1:2:end) + i.*ktmp(2:2:end);
		end
	end
end
