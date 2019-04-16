function dat = loaddat_ex2_lhg(phnum,slnum,scaninfo,fid);
% this function should read the data for one slice at one frame
% it should include all the coils and all the shots
%
% order of data in file (rev/for, views(spirals), slices, coils)

DEBUG = 0;

if (scaninfo.sliceorder == 0)
	slnum2 = round((slnum+1.5)/2) + rem(slnum,2)*round((scaninfo.nslices+0.5)/2) - 1;
else
	slnum2 = slnum;
end

ncoils	= scaninfo.ncoils;
ndat	= scaninfo.ndat;
npr		= scaninfo.npr;
concat	= scaninfo.concat;
nslices = scaninfo.nslices;
nphases = scaninfo.nphases;
nechos	= concat+1;

dat = zeros([ndat (concat+1)*npr*ncoils]);
% add one if odd numbered views
nodd = rem((scaninfo.nphmult*scaninfo.npr),2);
% nodd = 0;
% point to right view
viewskip = ndat;
echoskip = viewskip*(npr + nodd);
phaseskip = echoskip*nechos;
sliceskip = phaseskip*(nphases+1);
coilskip = sliceskip*(nslices);

%{
coilskip = scaninfo.nslices*(concat+1)*(scaninfo.nphmult+1+nodd)*npr*4*scaninfo.ndat;
nproj = slnum2*(concat+1)*(scaninfo.nphmult+1+nodd)*scaninfo.npr + phnum*scaninfo.npr + 1;
echostep = (scaninfo.nphmult+1+nodd)*scaninfo.npr;

% LHG trying to do multi-shot
if npr>1
	coilskip = scaninfo.nslices*(concat+1)*(scaninfo.nphmult+nodd)*npr*4*scaninfo.ndat;
	nproj = slnum2*(concat+1)*(scaninfo.nphmult+nodd)*scaninfo.npr + phnum*scaninfo.npr + 1;
	echostep = (scaninfo.nphmult+nodd)*scaninfo.npr;
end
%}
r = 1;
for coilnum = 0:ncoils-1
	%	coiloff = coilskip*(coilnum-1);
	%	offs = scaninfo.headersize + nproj*ndat*4 + coiloff;

	% pointer to the location of the views:
	offs = coilnum*coilskip + ...
		slnum * sliceskip + ...
		(phnum)*phaseskip +...
		ndat;

	offs = offs * 4 + scaninfo.headersize;
	fseek(fid,offs,'bof');

	% now read all the views into a matrix
	for lp = 1:npr
		if DEBUG
			fprintf('\ncoilnum = %d, slnum = %d, phnum = %d, lp =%d,  ndat= %d, offs = %d', ...
				coilnum, slnum2, phnum, lp, ndat, offs);
		end
		ktmp = fread(fid,2*ndat,'int16');
		dat(:,r) = ktmp(1:2:end) + i.*ktmp(2:2:end);
		r = r+1;
	end

	%{
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
	%}
end
