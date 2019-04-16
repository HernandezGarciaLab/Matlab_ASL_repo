%% Build the Design Matrix
%% experiment date:  10.26.09
TR = 4;

duration = 1144;
% 150 * TR;
% add three seconds for instructions on each trial
%shifts = [1:5]*3;

one_on = [
	13
	66
	303
	380
	681
	1046 ] -8;

one_dur = [
	48
	96
	72
	48
	72
	96];

four_on = [
	167
	468
	604
	758
	870
	958 ] -8 ;

four_dur = [
	96
	96
	72
	72
	48
	48] ;

instr_on = [
	8
	61
	162
	263
	298
	375
	428
	463
	564
	599
	676
	753
	830
	865
	918
	953
	1006
	1041] - 8 ;

instr_dur = ones(size(instr_on))*5;

D = zeros(duration , 4);
for c=1:length(one_on)
	D( one_on(c) +1 : (one_on(c) + one_dur(c) ) +1, 2) = 1;
	D( four_on(c) +1 : (four_on(c) + four_dur(c) ) +1, 3) = 1;
end
for c = 1:length(instr_on)
	D( instr_on(c) +1 : (instr_on(c) + instr_dur(c) ) +1, 4) = 1;
end



h = spm_hrf(1);
for r=1:3
	reg = D(:,r);
	reg = conv(reg,h);
	reg = reg(1:duration);
	D(:,r) =  reg;
end
D(:,1) = 1;

D = D(1:TR:end, :);
D2 = D;
D2(1:2:end,:) = -D2(1:2:end,:);


Dsub = D(1:2:end,:);
% surround subtraction case
%Dsursub = D(2:end-1, :);
Dsursub = -differencer(D2,4);

D2 = D2/2;
imagesc([D D2])

save DesMat_full D D2 Dsub Dsursub

%% recon section .. Found white pixel arttefact -> use despiker
if 1
	pname = 'P_task';
	despiker_ASL(pname, 4, 0);
	sprec1(['f_' pname], 'l', 'fx', 'fy','fz','N', 'com');
end

vfile = dir('vol*.nii');

vfile = vfile(1).name;
[p, n,e,v] = fileparts(vfile)
vfile = n

%% realignment
!setenv FSLOUTPUTTYPE NIFTI
str = sprintf('!mcflirt -in %s -out rvol -refvol 0 -cost normcorr -verbose 1 -stats -plots -mats', n);
eval(str)
n= 'rvol';
vfile = n;

%% subtraction section
!rm sub.img sub.hdr
warning off
% note that we can only analyze the first 110 seconds of the time course
% *** surround subtraction is proving very beneficial in this case  ***
aslsub(n, 1, 1, 286, 0, 1, 0);
aslsub_sur(n, 1,286,0,1);
!cpimg sub un_sub


% %% clean the subtracted data with compcor
% myCompCor_mod('sub', Dsursub);
%
% !cpimg tCompCor/CompCor_residuals ./ccsub

%smoother2('ccsub',3);
smoother2(vfile,3);
smoother2('sub',3);


%% analysis 1 : magnitude only analysis of uncorrected, smoothed, subtracted data

spmJr('ssub',Dsursub(:,1:3),[...
	1 0 0  ; ...
	0 0 1  ; ...
	0 1 0 ; ...
	0 -1 1 ; ...
	]);

close all
figure; lightbox('Zmap_0001.img', [], 4);
figure; lightbox('Zmap_0002.img', [], 4);
figure; lightbox('Zmap_0003.img', [], 4);
figure; lightbox('Zmap_0004.img', [], 4);

% convert betas to perfusions!
%beta2flow('Bhats_mag', 4, 1.4, 1.5, 2.3, 0.9, 1);
beta2flow02('ConBhats','ConVar_hats', 4,1.2, 1.5, 2.1, 0.9, 1);

%
beta2flow02('ConBhats','ConVar_hats', 4,1.4, 1.5, 2, 0.8, 1);


% let's make some interesting figures:
msk = read_img('Zmap_0004.img');  % four back task
msk = reshape(msk(1,:) , 64,64,12);
msk(abs(msk)<3) = 0;
msk(abs(msk)>=3) = 1;
flows = read_img('ExpFlows');
f0 = reshape(flows(1,:), 64,64,12);
f1back = reshape(flows(2,:), 64,64,12) .* msk ;
f4back = reshape(flows(3,:), 64,64,12) .* msk;

sl = 3
figure
subplot(211)
lightbox(f0(:,:,sl), [0 100],1);
subplot(212)
lightbox([f1back(:,:,sl); f4back(:,:,sl) ], [-20 20],1);
figure
act_lightbox([f0(:,:,sl); f0(:,:,sl) ], [f1back(:,:,sl); f4back(:,:,sl) ], [10 120], [1 25], 1);

print -dtiff slice8perfusion


%  now the variance maps:
% let's make some interesting figures:
flowvars = read_img('ExpFlow_vars');
fv0 = reshape(flowvars(1,:), 64,64,12);
fv1back = reshape(flowvars(2,:), 64,64,12);
fv4back = reshape(flowvars(3,:), 64,64,12);
lightbox([fv1back(:,:,sl); fv4back(:,:,sl) ], [0 20],1);

figure
fv1back = reshape(flowvars(2,:), 64,64,12) .* msk ;
fv4back = reshape(flowvars(3,:), 64,64,12) .* msk;
act_lightbox([fv0(:,:,sl); fv0(:,:,sl) ], ...
	[fv1back(:,:,sl); fv4back(:,:,sl) ], ...
	[1 20], [1 15], 1);
title('Variance of Perfusion Estimates (ml/min/100g)');
dofontsize(16)

return
sdfgsdfg
%%%%  stop here
!mkdir A1
!mv Zmap* A1
!mv Bhat* A1
!mv ExpF* A1

!mkdir A1
!mv Zmap* A1



%% analysis 2 : magnitude only analysis of unsubtracted data
[voldata, h] = read_img(['s' vfile]);

flags.header = h;
flags.doWhiten = 1;

% Note:  adding a linear trend is very helpful!!
Dfull =[D D2 ([1:236]/236-0.5)'];

spmJr(voldata , Dfull, ...
	[...
	1 0 0 0  0 0 0 0  0;...
	0 1 0 0  0 0 0 0  0;...
	0 0 1 0  0 0 0 0  0;...
	0 0 0 0  0 -1 1 0  0; ...
	0 0 0 0  1 0 0 0  0;  ...
	0 0 0 0  0 1 0 0  0;  ...
	0 0 0 0  0 0 1 0  0], flags);

%
close all
figure; lightbox('Zmap_0001.img', [-3 3], 4);
figure; lightbox('Zmap_0002.img', [-3 3], 4);
figure; lightbox('Zmap_0003.img', [-3 3], 4);
figure; lightbox('Zmap_0004.img', [3 -3], 4);
figure; lightbox('Zmap_0005.img', [-3 3], 4);
figure; lightbox('Zmap_0006.img', [-3 3], 4);
figure; lightbox('Zmap_0007.img', [-3 3], 4);

% convert betas to perfusions!
%beta2flow('Bhats', 4,1.2, 1.5, 2.3, 0.9, 0);

beta2flow02('ConBhats','ConVar_hats', 4,1.2, 1.5, 2.3, 0.9, 0);


% let's make some interesting figures:
msk = read_img('Zmap_0007.img');  % four back task
msk = reshape(msk(1,:) , 64,64,12);
msk(abs(msk)<2) = 0;
msk(abs(msk)>=2) = 1;
flows = read_img('ExpFlows');
f1back = reshape(flows(6,:), 64,64,12) .*msk;
f4back = reshape(flows(7,:), 64,64,12) .*msk;
f0 = reshape(flows(5,:), 64,64,12);

sl = 7
figure
lightbox(f0(:,:,sl), [0 100],1);
figure
act_lightbox([f0(:,:,sl); f0(:,:,sl) ], [f1back(:,:,sl); f4back(:,:,sl) ], [10 100], [5 20], 1);
title('Perfusion Estimates (ml/min/100g)');
dofontsize(16)

%  now the variance maps:
% let's make some interesting figures:
flowvars = read_img('ExpFlow_vars');
fv0 = reshape(flowvars(1,:), 64,64,12);
fv1back = reshape(flowvars(2,:), 64,64,12);
fv4back = reshape(flowvars(3,:), 64,64,12);
lightbox([fv1back(:,:,sl); fv4back(:,:,sl) ], [0 20],1);

figure
fv1back = reshape(flowvars(2,:), 64,64,12) .* msk ;
fv4back = reshape(flowvars(3,:), 64,64,12) .* msk;
act_lightbox([fv0(:,:,sl); fv0(:,:,sl) ], ...
	[fv1back(:,:,sl); fv4back(:,:,sl) ], ...
	[1 20], [1 15], 1);
title('Variance of Perfusion Estimates (ml/min/100g)');
dofontsize(16)


!mkdir A2
!mv Zmap* A2
!mv Bhat* A2
!mv ExpF* A2

%% analysis 3 : complex analysis of unsubtracted data
[FdaSNR,BhatFdaSNR,GammahatFdaSNR,sigma2hatFdaSNR] = ...
	spmJr_cplx2('svol_e7747_10_01_108_0127.nii',[Dfull],[0 0 0   0 -1 1 0]);
fc1 = lightbox('Fmap_cplx2');

[FdaSNR,BhatFdaSNR,GammahatFdaSNR,sigma2hatFdaSNR] = ...
	spmJr_cplx2('svol_e7747_10_01_108_0127.nii',[Dfull],[0 0 0  0 0 1 0]);
fc2 = lightbox('Fmap_cplx2');

phis = read_img(['p_' vfile]);
mags = read_img(vfile);
Ycomp = mags.*exp(i*phis/1000);
Ycomp = Ycomp(1:110,:);

[FdaSNR,BhatFdaSNR,GammahatFdaSNR,sigma2hatFdaSNR] = ...
	spmJr_cplx2(Ycomp,[Dfull],[0 0 0  0 1 0 0]);
fc3 = lightbox('Fmap_cplx2');

!mkdir A3
!mv *cplx* A3
