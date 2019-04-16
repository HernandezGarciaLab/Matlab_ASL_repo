function blnFM = isfieldmap(fid,scaninfo)
% isfieldmap.m - determines if current file position is in range of field map bytes.
% 
% INPUTS
% fid - file id of pfile, from fopen
% scaninfo - structure, from running rec_setup1.m on the pfile
% 
% OUTPUTS
% blnFM - 1 if in range of field map, 0 otherwise
% 
% EXAMPLE
% strFile = 'P22016.7';
% fid = fopen(strFile,'r','l');
% [~,scaninfo] = rec_setup1(strFile,'V'); 
% fseek(fid,455356,'bof');
% blnFM = isfieldmap(fid,scaninfo);
% fclose(fid);

% Author - Krisanne Litinas
% $HeadURL: svn+ssh://klitinas@anger.engin.umich.edu/svn/matlab/img/trunk/isfieldmap.m $
% $Id: isfieldmap.m 1287 2014-03-28 17:12:04Z klitinas $

% Needed information from header
numCoils = scaninfo.ncoils;
hdrSize = scaninfo.headersize;
isInOut = scaninfo.concat;
numDat = scaninfo.ndat;
numSlices = scaninfo.nslices;
numVols = scaninfo.nphases - 1; % actual volumes, w/o fieldmap

% For an even number of time points, have to account for extra (bogus) frame 
if ~mod(numVols,2)
    numVols = numVols + 1;
end

% Field map ranges based on header info
numFMinds = numCoils * numSlices * (isInOut+1);
iTmp = 1:numFMinds;

vStart = hdrSize + 4*scaninfo.ndat + (iTmp-1)*(4*numDat)*(numVols+2);
vStart = vStart(:);

% Get current location in file
fileLoc = ftell(fid);

% See if location is in range of fieldmap vector
tmp = find(fileLoc >= vStart);
if isempty(tmp)
    blnFM = 0;
else
    iStart = tmp(end);
    fmStart = vStart(iStart);
    iEnd = fmStart + 4*numDat-1;
    if fileLoc <= iEnd
        blnFM = 1;
    else
        blnFM = 0;
    end
end