function casFilesNii = niisplit(strNiiToSplit,numVols,strPrefixOut)
% EXAMPLE
% strNiiToSplit = 's004a1001.nii';
% numVols = 500;
% strPrefixOut = 'run_';
% casFilesOut = niisplit(strNiiToSplit,numVols,strPrefixOut);

% $Id: niisplit.m 1279 2014-03-24 20:06:25Z klitinas $
% $HeadURL: svn+ssh://klitinas@anger.engin.umich.edu/svn/matlab/img/trunk/niisplit.m $

[imgIn,hdrIn] = read_nii_img(strNiiToSplit);

numVolsTotal = size(imgIn,1);
numRunsOut = numVolsTotal / numVols;
casFilesNii = cell(numRunsOut,1);

for iRun = 1:numRunsOut
	strFileRun = sprintf('%s%02d.nii',strPrefixOut,iRun);
	if iRun == 1
		iVol = 1:numVols;
	else
		iVol = 1+(iRun-1)*numVols:1+(iRun-1)*numVols+numVols-1;
	end
imgRun = imgIn(iVol,:);
hdrRun = hdrIn;
hdrRun.dim(5) = numVols;
write_nii(strFileRun,imgRun,hdrRun,0);
blankify_nii_hdr(strFileRun);
casFilesNii{iRun} = strFileRun;
end
