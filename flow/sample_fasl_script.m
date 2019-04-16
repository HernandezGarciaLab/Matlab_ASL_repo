%% Build the Design Matrix
%% experiment date:  10.26.09
TR = 4;
exp_duration = 1144;

% one back blocks
onsets{1} = [	13	66	303	380	681	1046 ]' -7;
durations{1} = [48	96	72	48	72	96]';

% four back blocks
onsets{2} = [	167	468	604	758	870	958 ]' -7 ;
durations{2} =[ 96	96	72	72	48	48]' ;

% instructions
onsets{3} = [	8	61	162	263	298	375	428	463	564	599	676	753	830	865	918	953	1006  1041]' - 7 ;
durations{3} = ones(size(onsets{3}))*5;

% Build a Design Matrix with the specified onset times and durations
X = buildDesMat(TR, exp_duration, onsets, durations, 1);
% X = differencer(X,4);
% X = -X(:,5:end);
imagesc(X)

% add nuisance
nn = load('wm_junk_tdata.dat');
nn = nn-mean(nn);
nn = nn/max(nn);

%X = [X nn];

save Unsubtracted.txt X -ascii

args.designMat = X;
% create astructure for the input parameters:
args = asl_spm01;

% name of the raw data file we're starting out with
args.inFile = 'sravol_e10640_07_06_110_0285.nii';

% Choose whether the data needs to be reconned (spiral recon)
args.doRecon=0;
% this next one is to run the despiker on the k-space data first
args.doDespike=0;

args.physCorr = 0;

% Do realignment using SPM 5
args.doRealign = 0;

% Smooth the image data.  This function requires an odd number
args.smoothSize = 0;


% Do subtractions on ASL data
% ( 0 = no subtraction,  1 = pairwise subtraction, 2 = surround
% subtraction)
args.subType = 0;
args.isSubtracted = 0;

% Do GLM analysis (estimation of parameters of the linear model specified
% above
args.doGLM = 1;
args.designMat = X;
args.contrasts = [...
    1 0 0 0 ;   % this one is the baseline perfusion!!
    0 0 1 0 ; 
    0 1 0 0 ; 
    0 -1 1 0 ];

args.contrasts = [zeros(4,4) args.contrasts ];

% Choose whether to convert the beta parameter estimates into perfusion.
args.doQuant=1;
args.aslParms.TR = 4;
args.aslParms.Ttag = 1.8;
args.aslParms.Tdelay = 1.5;
args.aslParms.Ttransit = 1.2;
args.aslParms.inv_alpha = 0.8;

% Choose display options for the results: as a lightbox of the
% contrasts
args.doLightbox = 1;
args.fThreshold = 5;

% Choose display options for the results: as an interactive display 
% of orthogonal sections that also let's you look at the time course.
% the last contrast is the one used for the overlay
args.doOrtho = 1;

asl_spm01(args);