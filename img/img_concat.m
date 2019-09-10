function [alldata outh] = img_concat(file_list)
% function [data hdr] = concat(file_list)
% concatenates a list of imgs into a single file as a time series

if isempty(file_list)
    file_list=multiSelector
end
alldata=[];
outh = [];
for n=1:length(file_list)
    fname = char(file_list(n));
    [data h] = read_img(fname);
    fprintf('\nReading ... %s', fname)
    if h.tdim==1
        data= data(:)';
    end
    alldata = [alldata; data];
    
    if n==1
        outh = h;
    else
        outh.tdim = outh.tdim + h.tdim;
    end
end
write_img('imageSeries.img',alldata,outh);
return

function file_list = multiSelector

flg = 0;
file_list = {};
c=1
while flg == 0
    [f,p]=uigetfile('*.m','Select all Images - press CANCEL if done','MultiSelect','on')
    if isnumeric(f)
        break
    else
        for n=1:length(f)
            ftmp = fullfile(p,f(n))
            file_list{c} = ftmp;
            c=c+1;
        end
    end
end

