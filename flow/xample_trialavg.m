%%%%

TR = 1.2;
dirstr = '/net/stanley/home/hernan/data/flow/031119ph/turbocasl'
spmstr = sprintf('%s/s_0004.img',dirstr)
anastr = sprintf('%s/raw_0006.img',dirstr)
serstr = 's_002.img'
pix =13 
thresh = 10

onsets = [80:80:500]*1.096 / TR;
onsets = [70:80:500] / TR;
window = 80 / TR;

cd(dirstr)

orthoasl( pix,...
	thresh, ...
	onsets, ...
	window, ...
	spmstr, ....
	anastr, ....
	dirstr, ...
	serstr);


