% Processing of the first run: blocked design Faces- Houses paradigm

% Physiological  correction in image domain
physdata = convertEXphysio('../../../060504kr_phys_2',0.025);
PhysioMat = mkPhysioMat('physio.dat',0.025, 10, 22,1);
rmReg('vol_e4633_05_04_106_',PhysioMat);
% The output is residuals.img

% do slice timing correction in FSL

% do realignment with MCFLIRT

% smooth the images spatially


% Make a design matrix from the onset times of the stimuli:
fo = load('../../../run2_faces_onsets.txt')
ho = load('../../../run2_houses_onsets.txt')

TR = 1
hrf = spm_hrf(1);
disdaq = 10;

fo = [fo(2:end) - fo(1)] / 1000 /TR - disdaq
ho = [ho(2:end) - ho(1)] / 1000 /TR - disdaq

reg = zeros(250,1);
reg(round(fo)) = 1;


reg = conv(reg,hrf);
freg = reg(1:250);

reg = zeros(250,1);
reg(round(ho)) = 1;


reg = conv(reg,hrf);
hreg = reg(1:250);

DesMat = [freg hreg];


DesMat = [DesMat ones(250,1)];
imagesc(DesMat)

contrasts = [1 0 0; 0 1 0; 1 -1 0; -1 1 0];

% Do Linear Regression to identify activet regions
spmJr('residuals', DesMat, contrasts);