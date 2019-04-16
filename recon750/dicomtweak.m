function dicomtweak(strFile,strField,newValue)
% EXAMPLE
% strFile = '/Users/klitinas/data/trailer/epi/20120905/a/z01';
% strField = 'SeriesNumber';
% newValue = 7;
% dicomtweak(strFile,strField,newValue)

% Author - Krisanne Litinas
% $Id: dicomtweak.m 1279 2014-03-24 20:06:25Z klitinas $

% Read dicom file
hdr = dicominfo(strFile);
img = dicomread(hdr);

% Change desired field to new value
hdrNew = hdr;
hdrNew.(strField) = newValue;

% Write file
dicomwrite(img,strFile,hdrNew);