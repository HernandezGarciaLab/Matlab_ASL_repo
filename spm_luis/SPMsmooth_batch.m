% Sample spatial smoothing batch script for SPM5 
% original was used the FMRI course 2006- by Tom N. and Luis H. at UM

%  step 1:  you do a coregistration by hand using the GUI and save
%  that job to a mat file that will serve as a template.
%  Alternativelly, you could build the structure by hand, but it's just
%  much easier to use the SPM5 GUI if you don't know the right fields. 
load SPMcoreg_template.mat

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
	jobs{n}.spatial{1}.smooth.data = ...
		{fullfile(Dirs{n}, sprintf('func/run_01/raprun_01.nii,%d',s)), ... 
		fullfile(Dirs{n}, 'func/run_02/raprun_02.nii') , ...
		fullfile(Dirs{n}, 'func/run_03/raprun_03.nii')};
	jobs{n}.spatial{1}.smooth.fwhm = [8 8 8];
	jobs{n}.spatial{1}.smooth.dtype = 0;
end

% step 5 : execute the batch
spm_jobman('run',jobs)

