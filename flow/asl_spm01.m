function result = asl_spm01(args)
%
% function result = asl_spm01(args)
%
% (c) 2010 Luis Hernandez-Garcia @ University of Michigan
% report problems to hernan@umich.edu
%
% This function processes ASL data from a raw k-pace file to a
% QUANTITATIVE PERFUSION ACTIVATION map of the deisred effects
%
% some notes:  the name of the file that the work is being done is stored
% in the variable "workFile"
%
% if you call the function without arguments,
% you get the args structure with the default values:
% and the program exists.
% 
%
%     % default values:
%     args.inFile = 'vol_e6294_09_25_107_0099.nii';
%     args.doDespike = 0;
%     args.doRecon=0;
%     args.doSliceTime=0;
%     
%     args.doRealign = 0;
%     args.smoothSize= 0;
%     args.subType = 0;
%     args.physCorr = 1;
%     args.physFile='070925tl_phys_02';
%     
%     args.doGLM = 1;
%     args.doGlobalMean = 0;
%     args.designMat = X;
%     args.isSubtracted = 1;
%     args.contrasts = [0 0 -1 1];
%     args.doQuant = 0;
% 
%     args.aslParms.TR = 3;
%     args.aslParms.Ttag = 1.4;
%     args.aslParms.Tdelay = 1.2;
%     args.aslParms.Ttransit = 1.2;
%     args.aslParms.inv_alpha = 0.8;
%     args.aslParms.disdaqs = 2;
% 	
%     args.doLightbox = 0;
%     args.doOrtho = 1;
%

if nargin<1
    % if you call the function without arguments,
    % you get the args structure with the default values:
    % and the program exists.
    %
    % default values:
    args.inFile = 'vol_e6294_09_25_107_0099.nii';
    args.doDespike = 0;
    args.doRecon=0;
    args.doSliceTime=0;
    
    args.doRealign = 0;
    args.smoothSize= 0;
    args.subType = 0;
    args.physCorr = 0;
    args.physFile='070925tl_phys_02';
    
    args.doGLM = 1;
    args.designMat = [];
    args.isSubtracted = 1;
    args.contrasts = [0 0 -1 1];
    args.doQuant = 0;
    args.doGlobalMean = 0;

    args.aslParms.TR = 3;
    args.aslParms.Ttag = 1.4;
    args.aslParms.Tdelay = 1.2;
    args.aslParms.Ttransit = 1.2;
    args.aslParms.inv_alpha = 0.8;
    args.aslParms.disdaqs = 2;
	
    args.doLightbox = 0;
    args.doOrtho = 1;

    result = args;
    return
end

% save arguments for future use
save asl_spm01_params.mat args


%% First figure out the input working file name
workFile = args.inFile;
[pth name ext] = fileparts(workFile);
if strcmp(ext, '.img');
    [d h]=read_img(workFile);
    h = avw2nii_hdr(h);
    write_nii( fullfile(pth, [name '.nii']), d, h, 0);
    workFile = fullfile(pth, [name '.nii'])
end

%% recon section .. Found white pixel arttefact -> use despiker
if args.doRecon


    if args.doDespike
        fprintf('\ndespiking .... %s', workFile);
        despiker_ASL(workFile, 4, 0);
        workFile = ['f_' workFile];
    end

    fprintf('\ndoing recon on ....%s', workFile);
    sprec1_3d(workFile, 'm');
	sprec1_3d(workFile, 'l', 'fy','N','h');
    tmp = dir('vol*.nii');
    workFile = tmp(1).name;

end

%% transform a GE vasl_3dasl image into the time series we want
if args.is_GE_asl
   fprintf('\nconverting ....%s into a time series', workFile);
   fprintf('\n(putting the images in the right order and faking a control image\n');
   ge_asl_2_timeseries(workFile); 
   workFile = ['vol_' workFile];
end

%% SLice Timing correction for ASL
if args.doSliceTime
    
    fprintf('\ndoing slice timing on ....%s', workFile);
    asl_sliceTimer(workFile, args.aslParms.TR, args.aslParms.Ttag+args.aslParms.Tdelay);
    workFile = ['a' workFile];

end

%% REALIGN images
if args.doRealign
    %  realignment with MCFLIRT
    %  !setenv FSLOUTPUTTYPE NIFTI
    %  str = sprintf('!mcflirt -in %s -out rvol -refvol 0 -cost normcorr -verbose 1 -stats -plots -mats', n);
    %  eval(str)
    fprintf('\ndoing realignment on ....%s', workFile);
    % realignment with SPM
    opts.rtm=1;
    spm_realign(workFile, opts);
    spm_reslice(workFile);

    workFile = ['r' workFile];

end

%%  Gaussian Smoothing
if args.smoothSize >0
    fprintf('\ndoing smoothing on ....%s', workFile);
    smoother3(workFile,args.smoothSize);
    workFile = ['s' workFile];
end

%%  Physio Correction
if args.physCorr==1
      
    fprintf('\ndoing RETROICOR on ....%s (must be unsubtracted)', workFile);
    if args.doSliceTime==1 , timeType=1, else timeType=0; end
    
    [d h] = read_nii_img(workFile);
    Nslices = h.dim(4);
	args.aslParms.disdaq = 2;

    % step 1: read the physio  data from the scanner and change its format
    % this generates a file called physio.dat
    physdata = convertEXphysio(args.physFile, 0.025);

    % step 2: create a matrix with the physio data made up of
    % basis functions  
	PhysioMat = mkASLPhysioMat(...
		'physio.dat',...
		0.025, ...
		args.aslParms.disdaq, ...
		Nslices, ...
		args.aslParms.TR, ...
		args.aslParms.Ttag + args.aslParms.Tdelay,...
		timeType);

    % step 3:  estimate the parameters of the design matrix and remove iit from
    % the data .  This will generate a 4D image file called residuals.nii.
    rmReg(workFile, PhysioMat, 2);

    workFile = ['residuals.nii'];
end

%% Physio correction section using CompCor:
%  use this with subtracted data only
if args.physCorr==2
%     % %% clean the subtracted data with compcor
%     myCompCor_mod('sub', Dsursub);
%     !cpimg tCompCor/CompCor_residuals ./ccsub
%     workFile = 'ccsub.img';
end


%% subtraction section
h = read_nii_hdr(workFile);
Nframes = h.dim(5)
warning off
switch args.subType
    case 0
        fprintf('\nNo subtraction');


    case 1
        fprintf('\ndoing pairwise subtraction on ...%s', workFile);
        !rm sub.img sub.hdr    
        [p, rootname,e,v] = fileparts(workFile)
        aslsub(rootname, 1, 1, Nframes, 0, 1, 0);
        workFile = 'sub.img';

    case 2
        fprintf('\ndoing surround subtraction on ...%s', workFile);
        !rm sub.img sub.hdr
        [p, rootname,e,v] = fileparts(workFile)
        aslsub_sur(rootname, 1,Nframes, 0, 1);
        workFile = 'sub.img';

end

%% calculate a mean global at every image to create a global mean confound
if args.doGlobalMean==1
    
    fprintf('\ndoing Global Mean Computation ...%s', workFile);
    
    [tmp h] = read_img(workFile);
    gm = mean(tmp,2);
    gm = gm - mean(gm);
    gm = gm / max(gm);
    
    fprintf('\nIncluding Global Mean into GLN and contrasts ...%s', workFile);
    args.designMat = [args.designMat gm];
    args.contrasts = [args.contrasts zeros(size(args.contrasts,1),1) ] ;
    
end

%% Estimation of Parameters and Statistical Maps
if args.doGLM

    if args.isSubtracted==0
        flags.doWhiten=1;
    else
        flags.doWhiten=0;
    end
    
    spmJr(workFile, args.designMat ,args.contrasts, flags);

    % show the different Zmaps as a diagnostic:
    for z=1:size(args.contrasts,1);
        figure; lightbox(sprintf('Zmap_%04d.img', z),  [], 4);
    end
end


%% convert betas to perfusions!
if args.doQuant
    if args.subType >0
        isSubtracted=1
    else
        isSubtracted=0;
    end

    TR = args.aslParms.TR;
    Ttag = args.aslParms.Ttag;
    Tdelay = args.aslParms.Tdelay;,
    Ttransit = args.aslParms.Ttransit;
    inv_alpha = args.aslParms.inv_alpha;

    beta2flow02('ConBhats','ConVar_hats', TR, Ttag, Tdelay, Ttransit, inv_alpha, isSubtracted);
end

%% making nice overlays of the flows
if args.doLightbox
    
    [flows h] = read_img('ExpFlows');
    f0 = reshape(flows(1,:), h.xdim,h.ydim,h.zdim);
    
    for f=1:size(flows,1)
        f_act = reshape(flows(f , :), h.xdim,h.ydim,h.zdim) ;
        figure
        act_lightbox( f0, f_act, [10 80], [1 25], 1);
        title(sprintf('Contrast number %d', f));
    end
end

%% if needed, we can put it in ortho to explore the time course
if args.doOrtho
    
    tfile=args.inFile;
    contrasts = args.contrasts
    if args.subType
        tfile='sub.img';
    end
    fprintf('\nDisplaying the last contrast in Orthogonal views');

    asl_args = args;
    clear global args
    
    ortho2005([],...
        'anat_file', 'mean_sub', ...
        'tseries_file', tfile, ...
        'spm_file', sprintf('Zmap_%04d.img', size(contrasts,1)),...
        'threshold', 2 ...
        );

end


return
    
