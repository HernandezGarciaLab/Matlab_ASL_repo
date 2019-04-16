% Matlab Startup File:
% Use this file to update path and to perform
% Your own book keeping tasks

%! setenv LD_LIBRARY_PATH "${LD_LIBRARY_PATH}:${MATLAB_ROOT}/extern/lib/${ARCH}:${MATLAB_ROOT}/bin/${ARCH}:${MATLAB_ROOT}/sys/${ARCH}"
warning off

set(0,'DefaultFigurePosition',[0 600 600 600])

format compact

addpath( '~/hernan/matlab/recon750')

% Generic useful functions: (data I/O...)
addpath( '~/hernan/matlab/generic')

% MRI image display and and some times seris analysis 
addpath('~/hernan/matlab/img')

% Flow and perfusion related functions 
addpath( '~/hernan/matlab/flow')
addpath( '~/hernan/matlab/flow/milf')
addpath( '~/hernan/matlab/flow/vsasl')

path(path, '~/hernan/matlab/kspace')

