function strCells = dirnames(string)
%function strCells = dirnames(string)
%
% converts the output of the DIR command into a 
% cell array with the file names
% very simple  - just intended to save some typing
%

arr = dir(string);


for n=1:length(arr)
    strCells{n} = arr(n).name;
end

return