function [xPix,yPix,sliceThickness,rows,cols,seriesDesc,seriesNum] = getdcmspecs(strFile,strDirOut)
% getdcmspecs.m - kind of kludgy fix for anatomy stream in case dcmtk
% doesn't work.
% 
% EXAMPLE:
% strFile = '/Users/klitinas/data/mr750/dicom/s3323/ginx/e12345s2i1';
% [xPix,yPix,sliceThickness,rows,cols] = getdcmspecs(strFile);

% Author - Krisanne Litinas
% $Id: getdcmspecs.m 1279 2014-03-24 20:06:25Z klitinas $
% $HeadURL: svn+ssh://klitinas@anger.engin.umich.edu/svn/matlab/img/trunk/getdcmspecs.m $

% Check input
if ~exist(strFile,'file')
    error('fmrilab:buildanatomy:invaliddcmfile','File "%s" does not exist',strFile);
end

% Read dicom and get fields of interest
s = dicominfo(strFile);
pixSpacing = s.PixelSpacing;
xPix = pixSpacing(1);
yPix = pixSpacing(2);
sliceThickness = s.SliceThickness;
rows = s.Rows;
cols = s.Columns;
seriesDesc = lower(s.SeriesDescription);
seriesDesc = strrep(seriesDesc,' ','_');
seriesDesc = strrep(seriesDesc,'->','2');
seriesNum = s.SeriesNumber;

[~,strBase] = fileparts(strFile);
strLogFile = fullfile(strDirOut,[strBase '.tmp']);
fid = fopen(strLogFile,'w');
fprintf(fid,'pixx:%g',xPix);
fprintf(fid,'\npixy:%g',yPix);
fprintf(fid,'\nslicethickness:%g',sliceThickness);
fprintf(fid,'\nrows:%g',rows);
fprintf(fid,'\ncols:%g',cols);
fprintf(fid,'\nseriesdesc:%s',seriesDesc);
fprintf(fid,'\nseriesnum:%d',seriesNum);

fclose(fid);
