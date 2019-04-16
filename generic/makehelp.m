files = dir('*.m')
diary('help.txt')

for n=1:length(files)
f = files(n).name;
disp(f)
f = f(1:end-2);
eval(sprintf('help %s', f))
end
diary off