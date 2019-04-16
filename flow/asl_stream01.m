%%%%%%%%%%%%%%%%% Stimulation stuff:
% Run #6
Nframes = 72;
Nslices = 16;
TR = 5;
Ttag = 4.5;
!mkdir retroicor blind_retroicor nocor

% make the design matrix
onsets = [30:60:Nframes*TR]
duration = 30;

reg = zeros(Nframes*TR,1);
for o=1: length(onsets)
    reg(onsets(o):onsets(o)+duration) = 1;
end
reg = conv(reg, spm_hrf(1));
ASLreg = reg(1:TR:Nframes*TR);
SUBreg = reg(1:TR*2:Nframes*TR);

DM = [SUBreg-mean(SUBreg)   ones(Nframes/2,1)];

ASLmodulation = ones(Nframes,1);
ASLmodulation(1:2:end) = -1;
rawDM = [ASLmodulation.*ASLreg ASLmodulation ones(Nframes,1) ASLreg  ];


%%%%%%%%%%%%% Image stuff:
despiker(pfile,2,0,0,2006)

str = sprintf('!cplx_recon f_%s', pfile); eval(str)
sliceTimer('vol',TR,Ttag);
str = sprintf('!mcflirt -in avol -out ravol -refvol 0 -cost normcorr -verbose 1 -stats -plots -mats');
eval(str)

% first analysis:  Blind RETROICOR
% cleaning up the data  physio correction and smoothing:
warning off
rmASLPhys('3Dout',5,[],[]); lightbox('mask');
rmASLPhys('p_3Dout',[],[],'mask'); lightbox('mask');

!rm *vol*
% % smoothing the magnitude data with FSL
% ! rm sclean_3Dout.*
% ! /opt/fsl/bin/ip clean_3Dout sclean_3Dout 10 -s 5
% ! avwchfiletype ANALYZE sclean_3Dout
% ! cp clean_3Dout.hdr sclean_3Dout.hdr
% 
% 
% % smoothing the phase data with FSL
% ! rm p_sclean_3Dout.*
% ! /opt/fsl/bin/ip p_clean_3Dout p_sclean_3Dout 10 -s 5
% ! avwchfiletype ANALYZE p_sclean_3Dout
% ! cp clean_3Dout.hdr p_sclean_3Dout.hdr

% ASL subtraction and GLM analysis stuff:
%aslsub('sclean_3Dout',1,1,Nframes,0,1,1);
aslsub('clean_3Dout',1,1,Nframes,0,1,1);
spmJr('sub',DM, [1 0]);
blind = lightbox('Zmap_0001',[],4);

% Put the files into the right analysis directory
!mv *clean* blind_retroicor
!mv *STD* blind_retroicor
!mv mask* blind_retroicor
!mv *map* blind_retroicor
!mv Con* blind_retroicor
!mv *mean* blind_retroicor
!mv *.mat blind_retroicor
!mv *con* blind_retroicor
!mv *tag* blind_retroicor
!mv *sub* blind_retroicor

% Second analysis:  NO RETROICOR
% smoothing the data with FSL
% ! rm s3Dout.*
% ! /opt/fsl/bin/ip 3Dout s3Dout 10 -s 5
% ! avwchfiletype ANALYZE s3Dout
% ! cp 3Dout.hdr s3Dout.hdr
% 
% ! rm p_s3Dout.*
% ! /opt/fsl/bin/ip p_3Dout p_s3Dout 10 -s 5
% ! avwchfiletype ANALYZE p_s3Dout
% ! cp 3Dout.hdr p_s3Dout.hdr

aslsub('3Dout',1,1,Nframes,0,1,1);
lightbox('mean_sub',[],4);
spmJr('sub',DM, [1 0]);
nocor = lightbox('Zmap_0001');

plot(nocor(:), blind(:),'.')
line([5 -5],[5 -5]) 

% Put the files into the right analysis directory
!mv *clean* nocor
!mv *STD* nocor
!mv mask* nocor
!mv *map* nocor
!mv Con* nocor
!mv *mean* nocor
!mv *.mat nocor
!mv *con* nocor
!mv *tag* nocor
!mv *sub* nocor

% make comparisons between cleaned up and not cleaned up data
stdd = (nocor - blind)./(blind);
lightbox(reshape(stdd,64,64,16),[0 10],4);


%  THIRD ANALYSIS: regular RETROICOR:
physdata = convertEXphysio('061115sp_phys_01',0.025);
PhysioMat = mkASLPhysioMat('physio.dat',0.025, 2, 16, 5, 4.5,1);

rmReg('p_3Dout', PhysioMat);
!mv residuals.nii p_retro_3Dout.nii
!mv varBefore.nii p_varBefore.nii
!mv varAfter.nii p_varAfter.nii
!mv rmASLPhysvars.mat p_rmASLPhysvars.mat
rmReg('3Dout', PhysioMat);
!mv residuals.nii retro_3Dout.nii

% Slice timeing correction happens after correction in 
% this case:
%sliceTimer('resuduals',TR,Ttag);

% % smoothing the data with FSL
% ! rm sretro_3Dout.*
% ! /opt/fsl/bin/ip retro_3Dout sretro_3Dout 10 -s 5
% ! avwchfiletype ANALYZE sretro_3Dout
% ! cp 3Dout.hdr sretro_3Dout.hdr
% 
% % smoothing the data with FSL
% ! rm p_sretro_3Dout.*
% ! /opt/fsl/bin/ip p_retro_3Dout p_sretro_3Dout 10 -s 5
% ! avwchfiletype ANALYZE p_sretro_3Dout
% ! cp 3Dout.hdr p_sretro_3Dout.hdr

%aslsub('sretro_3Dout',1,1,Nframes,0,1,1);
aslsub('retro_3Dout',1,1,Nframes,0,1,1);
spmJr('sub',DM, [1 0]);
retrocor = lightbox('Zmap_0001');

plot(nocor(:), retrocor(:),'.')
line([5 -5],[5 -5])

% Put the files into the right analysis directory
!mv *retro* retroicor
!mv *STD* retroicor 
!mv *var*  retroicor 
!mv *map*  retroicor 
!mv Con*  retroicor 
!mv *mean*  retroicor 
!mv *.mat  retroicor 
!mv *con*  retroicor 
!mv *tag*  retroicor 
!mv *sub*  retroicor 
!mv *residual* retroicor

% summary:
load blind_retroicor/rmASLPhysvars.mat
	CSFtimecourse = PM(:,4);

	resp = load('physio.dat');
	resp = resp(:,2);
	% skip 2 TRs and sample at the end of every T,
	% sampling rate for waveform = 0.025
	TR = 5;
	resp2 = resp(2*TR/0.025 : TR/0.025 : end-TR/0.025);
	resp_rho = corrcoef(resp2,CSFtimecourse);
	resp_rho = resp_rho(1,2);

	% compute the change in the variance 
	varRetro_0= read_img('retroicor/varBefore.nii');
	varRetro_1= read_img('retroicor/varAfter.nii');

	meanvar_Retro_0 = mean(varRetro_0(:));
	meanvar_Retro_1 = mean(varRetro_1(:));
	varChangeRetro = (meanvar_Retro_1 - meanvar_Retro_0)/ meanvar_Retro_0;

	% compute the change in the variance 
	varBlind_0= read_img('blind_retroicor/originalSTD.img');
	varBlind_1= read_img('blind_retroicor/correctedSTD.img');
	varBlind_R= read_img('blind_retroicor/residualSTD.img');

	varBlind_0 = varBlind_0 .^2;
	varBlind_1 = varBlind_1 .^2;
	varBlind_R = varBlind_R .^2;

	meanvar_Blind_0 = mean(varBlind_0(:));
	meanvar_Blind_1 = mean(varBlind_1(:));
    meanvar_Blind_R = mean(varBlind_R(:));
    
	varChangeBlind = (meanvar_Blind_1 - meanvar_Blind_0)/ meanvar_Blind_0;
	varChangeBlind_R = (meanvar_Blind_R - meanvar_Blind_0)/ meanvar_Blind_0;

	fprintf('varChangeBlind: %f\nvarChangeBlind_R: %f\nvarChangeRetro: %f\nresp_rho: %f\n', ...
		varChangeBlind, varChangeBlind_R, varChangeRetro, resp_rho); 
    
    % Z scores in visual cortex:
 
    