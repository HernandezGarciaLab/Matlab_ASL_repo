% Sample spatial normalization batch script for SPM5 
% original was used the FMRI course 2006- by Tom N. and Luis H. at UM

%  step 1:  you do a normalization by hand using the GUI and save
%  that job to a mat file that will serve as a template.
%  Alternativelly, you could build the structure by hand, but it's just
%  much easier to use the SPM5 GUI if you don't know the right fields
load SPMnormalizeWrite_template.mat

Dirs = {
    '/export/subjects/FMRI2006/060518ak',...
    '/export/subjects/FMRI2006/060518mw',...
    '/export/subjects/FMRI2006/060524aw',...
    '/export/subjects/FMRI2006/060524mm',...
    '/export/subjects/FMRI2006/060524ms',...
    '/export/subjects/FMRI2006/060606jm',...
    '/export/subjects/FMRI2006/060613cg',...
    '/export/subjects/FMRI2006/060613cj',...
    '/export/subjects/FMRI2006/060620ag',...
    '/export/subjects/FMRI2006/060620cs'};
nDir = length(Dirs);


% step 4:  replicate the original job structure updating the fields
% that specify the file locations
for n = 1:nDir
	jobs{n} = jobs{1};
	jobs{n}.spatial{1}.normalise{1}.write.subj.matname = ...
			{[fullfile(Dirs{n}, '/anatomy/het1spgr_sn.mat') ]};
	jobs{n}.spatial{1}.normalise{1}.write.subj.resample = ...
    			{fullfile(Dirs{n}, '/anatomy/het1spgr.img,1');
    			fullfile(Dirs{n}, '/anatomy/het1overlay.img,1');
			fullfile(Dirs{n}, '/RESULTS/Block/con_0001.img,1');
			fullfile(Dirs{n}, '/RESULTS/Block/con_0002.img,1');
			fullfile(Dirs{n}, '/RESULTS/Block/spmT_0001.img,1');
			fullfile(Dirs{n}, '/RESULTS/Block/spmT_0002.img,1');

			fullfile(Dirs{n}, '/RESULTS/BlockSm/con_0001.img,1');
			fullfile(Dirs{n}, '/RESULTS/BlockSm/con_0002.img,1');
			fullfile(Dirs{n}, '/RESULTS/BlockSm/spmT_0001.img,1');
			fullfile(Dirs{n}, '/RESULTS/BlockSm/spmT_0002.img,1');

			fullfile(Dirs{n}, '/RESULTS/Event/con_0001.img,1');
			fullfile(Dirs{n}, '/RESULTS/Event/con_0002.img,1');
			fullfile(Dirs{n}, '/RESULTS/Event/spmT_0001.img,1');
			fullfile(Dirs{n}, '/RESULTS/Event/spmT_0002.img,1')}
			

end

% step 5 : execute the batch
spm_jobman('run',jobs)


