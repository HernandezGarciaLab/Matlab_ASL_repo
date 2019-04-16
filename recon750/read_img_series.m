function [series_data, h] = read_img_series(root,strVerbose)
%
% 	[series_data , h] = read_img_series(root)
% 
% Luis hernandez
% last edit 6/26/2004
%
% hdr		header information
% root	root name of the image files
% 
% ouput: 	a matrix with pixels in each column and
% 		 rows means position in time
%
% similar to read_img, but used when there are multiple files
% for the time series
%
% (c) 2005 Luis Hernandez-Garcia 
% University of Michigan
% report bugs to:  hernan@umich.edu
%

% $Id: read_img_series.m 1279 2014-03-24 20:06:25Z klitinas $
% $HeadURL: svn+ssh://klitinas@anger.engin.umich.edu/svn/matlab/img/trunk/read_img_series.m $

% Defaults to verbose mode
if ~exist('strVerbose','var')
    strVerbose = 'v';
end

if strcmpi(strVerbose,'v')
    blnVerbose = 1;
else
    blnVerbose = 0;
end

% Figure out the direcory and go there
curDir = pwd;
slash = find(root=='/' | root=='\');
if ~isempty(slash)
    dirStr = root(1:slash(end));
    cd (dirStr);
end

names = dir(sprintf('%s*.img', root));
hnames = dir(sprintf('%s*.hdr', root));

h = read_hdr(hnames(1).name);

if h.tdim >1
    fprintf('\n   WARNING.  THE FIRST FILE CONTAINS A TIME SERIES');
    fprintf('\n   READING ONLY ONE FILE \n');
    [series_data h] = read_img(names(1).name);
    whos series_data
else

    series_data = zeros(length(names), h.xdim*h.ydim*h.zdim);

    for count=1:length(names)
        
        if blnVerbose
            fprintf('\r Reading .... %s', names(count).name);
        end
        series_data(count,:) = (read_img(h,names(count).name));
    end
end

% come back from the direcotry
cd(curDir)

return
