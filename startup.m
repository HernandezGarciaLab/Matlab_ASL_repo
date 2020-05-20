% Matlab Startup File:
% Use this file to update path and to perform
% Your own book keeping tasks

%! setenv LD_LIBRARY_PATH "${LD_LIBRARY_PATH}:${MATLAB_ROOT}/extern/lib/${ARCH}:${MATLAB_ROOT}/bin/${ARCH}:${MATLAB_ROOT}/sys/${ARCH}"

format short

set(0,'DefaultFigurePosition',[1 50 480 480])

% varian format files
addpath( '~hernan/matlab/Varian')

% Sufficiency and Necessity Fucntions
addpath( '~hernan/matlab/NetworkAnalysis/sufnec')

% Scripts to be called from C using the Matlab Engine
addpath( '~hernan/matlab/eventDetection')

% Scripts to be called from C using the Matlab Engine
addpath( '~hernan/matlab/engScripts')

% SPM99 code:
addpath( '~hernan/matlab/spm99/spm99')

% KUL scripts to automate SPM99 :
addpath( '~hernan/matlab/spm99_kul')

% SPM5 code:
addpath( '~hernan/matlab/spm12')

% SPM regressors generating functions
addpath( '~hernan/matlab/bold_sims/garavan')
addpath( '~hernan/matlab/bold_sims')

% My own SPM related functions:
addpath( '~hernan/matlab/spm_luis')

% Generic useful functions: (data I/O...)
addpath( '~hernan/matlab/generic')

% TMS corregistration, display, and quantitation library
% addpath('~hernan/matlab/tms')

% MRI image display and and some times seris analysis 
addpath('~hernan/matlab/img')

% Adiabatic Inversion Model functions library
addpath( '~hernan/matlab/adiabatic')

% Statistical analysis for dissertation
addpath( '~hernan/matlab/dissert')

% Alignment functions akin to AIR reorient
addpath( '~hernan/matlab/align')

% Flow and perfusion related functions 
addpath( '~hernan/matlab/flow')

%  ICA code 
addpath( '~hernan/matlab/ica')

% SPECTROSCOPY functions
addpath( '~hernan/matlab/spec')

% Diffusion functions
addpath( '~hernan/matlab/diffusion')

% K space sampling and simulations 
addpath( '~hernan/matlab/kspace')

% Doug's reconstruction code:
addpath( '~hernan/matlab/recon')
addpath( '~hernan/matlab/recon750')

% Scott Peltier's physiological correction scripts:
addpath('~hernan/matlab/physio')

% SPM5 libs
%addpath('/optnet/SPM5')
%addpath('/optnet/SPM5_local')

%addpath('/Applications/MATLAB6p5p1/toolbox/signal')
setenv( 'FSLDIR', '/usr/local/fsl' );
fsldir = getenv('FSLDIR');
fsldirmpath = sprintf('%s/etc/matlab',fsldir);
path(path, fsldirmpath);
clear fsldir fsldirmpath;
