function P = dir2names(str)

fs = dir(str);
P = cell(length(fs), 1);

for n=1:length(fs)
    P(n) = {fs(n).name};
end



return