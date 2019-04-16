subjs = [
'060518ak'
'060518mw'
'060524aw'
'060524mm'
'060524ms'
'060606jm'
'060613cg'
'060613cj'
'060620ag'
'060620cs'
];

if 0
addpath /net/stanley/home/hernan/matlab/spm_luis
addpath /net/stanley/home/hernan/matlab/img
addpath /net/stanley/home/hernan/matlab/generic
end

rootdir = '/export/subjects/FMRI2006/'
for s=1:size(subjs,1)
	cd ([rootdir  subjs(s,:) '/func/run_01/ra_img/' ])

	DM1 = load([rootdir subjs(s,:) '/fh/DesMat_01_edat.dat']);
	spmJr('raprun', DM1, [1 -1 0 ; 1 0 0; 0 1 0]);
	lightbox('Zmap_0001');	
	mkdir edat 
	!mv Zmap* edat/

	DM2 = load([rootdir subjs(s,:) '/fh/DesMat_01_tdat.dat']);
	spmJr('raprun_01', DM2, [1 -1 0 ; 1 0 0; 0 1 0]);
	lightbox('Zmap_0001');	
	mkdir tdat
	!mv Zmap* tdat

	pwd
	pause
	close all
end

for s=1:size(subjs,1)
	cd ([rootdir  subjs(s,:) '/func/run_01/ra_img/edat' ])
	figure
	subplot(121)
	lightbox('Zmap_0001'); 
	title([subjs(s,:) ' - edat'])

	cd ([rootdir  subjs(s,:) '/func/run_01/ra_img/tdat' ])
	subplot(122)
	lightbox('Zmap_0001'); 
	title([subjs(s,:) ' - tdat'])
end

