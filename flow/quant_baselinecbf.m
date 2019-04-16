function quant_baselinecbf(baseDir, doRecon)

myDir = pwd;
baseDir = [myDir '/' baseDir]

M0frames = 8;  % the first frames do not have background suppression
inv_alpha = 0.85;
flip = 20 * pi/180;
Ttag = 1.8;
TR = 4.3;
Ttrans = 1.2;
pid = 1.7;
T1 = 1.4;



quantDir = [baseDir '/quant/'];
anatomyDir = [baseDir '/anatomy/'];
overlayfile='t1overlay_6mm_20.nii';
spgrfile='t1spgr.nii';

cd(quantDir)


if doRecon
    !rm *.nii *.hdr *.img *.mat

    
    fprintf('\nP files in directory: \n');
    dir P*.7
    
    Pfile = dir('P*.7');
    Pfile = Pfile(end).name;
    
    fprintf('... using %s \n', Pfile);
    
    sprec1_3d(Pfile,'m','fy','l');
    sprec1_3d(Pfile,'h', 'N', 'fy', 'l');
end

volfile = dir('vol*.nii');
volfile = volfile(1).name;

f = casl_pid_02(volfile, M0frames, inv_alpha, flip, Ttag, TR, pid, Ttrans, T1);

%% do coregistration

str = ['! cp ' anatomyDir overlayfile ' .']
eval(str)
str = ['! cp ' anatomyDir spgrfile ' .']
eval(str)

save myworkspace.mat

% coregistration: anatomy overlay to fMRI
fprintf('\nCoregistering %s to mean_sub ...', overlayfile); 
flags.cost_fun='nmi';
flags.tol = [0.01 0.01 0.01 0.001 0.001 0.001];

Vref = spm_vol(fullfile(cd,'mean_sub.img'));
Vtgt = spm_vol(fullfile(cd, overlayfile));
% Vref.mat = Vtgt.mat;

x = spm_coreg(Vref,Vtgt, flags);

% set the affine xformation for the output image's header
mat = spm_matrix(x);
xform = inv(mat)*Vtgt.mat ;

spm_get_space(Vtgt.fname,xform);


% Now the spgr
fprintf('\nCoregistering %s to mean_sub ...', spgrfile); 

Vref = spm_vol(fullfile(cd,'mean_sub.img'));
Vtgt = spm_vol(fullfile(cd, spgrfile));
% Vref.mat = Vtgt.mat;

x = spm_coreg(Vref,Vtgt, flags);

% set the affine xformation for the output image's header
mat = spm_matrix(x);
xform = inv(mat)*Vtgt.mat ;

spm_get_space(Vtgt.fname,xform);


% normalization fMRI to template
fprintf('\nNormalising %s to template with SPM 8 ...\n', spgrfile); 
rmpath /home/hernan/matlab/spm12
clear classes
load myworkspace.mat
addpath /home/hernan/matlab/spm8

Vref = spm_vol(fullfile('/home/hernan/matlab/spm12/canonical/','avg152T1.nii' )); 
Vtgt = spm_vol(fullfile(spgrfile));

spm_normalise(Vref, Vtgt, 'mynorm_parms.mat');


% apply the normalization to the CBF images
spm_write_sn( fullfile(cd, 'Flow.img')  , 'mynorm_parms.mat');
spm_write_sn( fullfile(cd, 'SpinDensity.img')  , 'mynorm_parms.mat');
spm_write_sn( fullfile(cd, 'mean_sub.img')  , 'mynorm_parms.mat');
spm_write_sn( fullfile(cd, spgrfile)  , 'mynorm_parms.mat');
spm_write_sn( fullfile(cd, overlayfile)  , 'mynorm_parms.mat');


%% spatial smoothing
sz=8;
spm_smooth( 'wFlow.img' , 'swFlow.img',[ sz sz sz], 4 );
  
%% show me the results
fprintf('\nGoing back to  SPM 12 ...\n'); 

clear classes
load myworkspace.mat
addpath /home/hernan/matlab/spm12

spm_check_registration(...
    '/home/hernan/matlab/spm12/canonical/avg152T1.nii' , ...
    fullfile(pwd,'wmean_sub.img') , ...
    fullfile(pwd,['w' overlayfile]), ...
    fullfile(pwd,['w' spgrfile]), ...
    fullfile(pwd,'wFlow.img'), ...;
    fullfile(pwd,'swFlow.img'));

  
cd(myDir)

return
