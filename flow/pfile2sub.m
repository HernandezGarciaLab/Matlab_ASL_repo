function ms = pfile2sub(Pfile, dopreproc)
% function ms = pfile2sub(Pfile, dopreproc)
% 
% recons the P file and produces a surround subtracted time series
% if dopreproc == 1, then it also realigns and smooths the images
% before the subtraction
%

if nargin<2
	dopreproc = 0;
end
% 
% !rm *vol*.nii
% sprec1_3d(Pfile,'m','n',64);
% sprec1_3d(Pfile,'N','h','n',64, 'fx', 'fy');
% 


vols = dir('vol*.nii');
workFile = vols(1).name;

if dopreproc
	opts.rtm=1;
	fprintf('\nRealigning ...')
	spm_realign(workFile, opts);
	spm_reslice(workFile);
	[pth nm ext] = fileparts(workFile);
	rp = load(['rp_' nm '.txt']);
	workFile = ['r' workFile];

	fprintf('\nSmoothing ...')
	smoother3(workFile,3);
	workFile = ['s' workFile];
end
hdr = read_hdr(workFile);

[pth root ext] = fileparts(workFile);

aslsub_sur(root, 1, hdr.tdim, 0, 0);

ms = lightbox('mean_sub',[-200 200],3);

if sum(ms(:)) < 0
	fprintf('\n WARNING:  reversing the subtraction order! \n')
	aslsub_sur(root, 1, hdr.tdim, 0, 1);
	ms = lightbox('mean_sub',[-200 200],3);
end

print -djpeg testlabel

figure
[tSNR sSNR] = ASL_snr(1.5)
%figure, hist(ms(:), 100);
return
