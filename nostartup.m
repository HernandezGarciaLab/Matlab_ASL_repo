% Matlab Startup File:
% Use this file to update path and to perform
% Your own book keeping tasks

%! setenv LD_LIBRARY_PATH "${LD_LIBRARY_PATH}:${MATLAB_ROOT}/extern/lib/${ARCH}:${MATLAB_ROOT}/bin/${ARCH}:${MATLAB_ROOT}/sys/${ARCH}"

set(0,'DefaultFigurePosition',[1 1 480 380])
% SPM5 code:
addpath('/optnet/SPM5_local/')
addpath('/optnet/SPM5/')

% SPM99 code:
addpath( '~hernan/matlab/spm99/spm99')

% KUL scripts to automate SPM99 :
addpath( '~hernan/matlab/spm99_kul')

% SPM regressors generating functions
addpath( '~hernan/matlab/bold_sims/garavan')
addpath( '~hernan/matlab/bold_sims')

% My own SPM related functions:
addpath( '~hernan/matlab/spm_luis')

% Generic useful functions: (data I/O...)
addpath( '~hernan/matlab/generic')

% TMS corregistration, display, and quantitation library
addpath('~hernan/matlab/tms')

% MRI image display and and some times seris analysis 
addpath('~hernan/matlab/img')

% Adiabatic Inversion Model functions library
path(path, '~hernan/matlab/adiabatic')

% Statistical analysis for dissertation
addpath( '~hernan/matlab/dissert')

% Alignment functions akin to AIR reorient
addpath( '~hernan/matlab/align')

% Flow and perfusion related functions 
addpath( '~hernan/matlab/flow')

%  ICA code 
path(path, '~hernan/matlab/ica')

% SPECTROSCOPY functions
path(path, '~hernan/matlab/spec')

% Diffusion functions
path(path, '~hernan/matlab/diffusion')

% K space sampling and simulations 
path(path, '~hernan/matlab/kspace')

% Scott Peltier's physiological correction scripts:
addpath('~hernan/matlab/physio')

addpath('/Applications/MATLAB6p5p1/toolbox/signal')
