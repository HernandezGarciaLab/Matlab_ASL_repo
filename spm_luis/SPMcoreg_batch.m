% Sample spatial coregistration batch script for SPM5 
% original was used the FMRI course 2006- by Tom N. and Luis H. at UM

%  step 1:  you do a coregistration by hand using the GUI and save
%  that job to a mat file that will serve as a template.
%  Alternativelly, you could build the structure by hand, but it's just
%  much easier to use the SPM5 GUI if you don't know the right fields. 
load SPMsmooth_template.mat

%  step 2:  set up a list of the directories with your sibjects:
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
	jobs{n}.spatial{1}.coreg{1}.estimate.ref = ...
			{[fullfile(Dirs{n}, '/anatomy/het1overlay.img') ',1']};
	jobs{n}.spatial{1}.coreg{1}.estimate.source = ... 
			{[fullfile(Dirs{n}, '/anatomy/het1spgr.img') ',1']};
end

% step 5 : execute the batch
spm_jobman('run',jobs)

