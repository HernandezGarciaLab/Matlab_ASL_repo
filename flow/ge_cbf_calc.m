function [cbfmap]=cbf_calc(asl_filename);
%Calculation of quantitative CBF map using GE's 3Dasl sequence.
% This uses same assumptions, masking and calculations as GE's maps.
%
%  2018, Scott Peltier

%% Read in data, reshape, do masking of images

tst=read_nii_img(asl_filename);
tst=reshape(tst.',[128 128 40 2]);

pw=tst(:,:,:,1);
pd=tst(:,:,:,2);

msk1=(pw==0);   %mask outside spiral coverage
msk2=(pd<200);  %masks non-brain areas


%%  Protocol dependent parameters, check if running new protocol

% UMMAP NEX=3 PLD=1.525
%  PTR   NEX=3   PLD=2.025

NEX=3;

PLD=1.525;   

%% GE-defined parameters

alpha=0.9;          %partition coefficient
ST=2;                %saturation time in seconds
T1t=1.2;             %partial saturation T1 in pd image

eff=0.6;            % overall efficiency

T1b=1.6;               % T1 of blood

LT=1.5;                 % labelling duration

SF=32;                  % scaling factor

%% Calculation for quantitative units (ml/100gm/min)

eqnum=(1-exp(-ST/T1t))*exp(PLD/T1b);

eqdenom=2*T1b*(1-exp(-LT/T1b))*eff*NEX;



cbf=6000*alpha*(eqnum/eqdenom)*(pw./(SF*pd));

cbfmap=cbf;
cbfmap(find(msk1))=0;
cbfmap(find(msk2))=1;

%% Get original header, use it to write out cbfmap as nifti image

h=read_nii_hdr(asl_filename);

h2=h;
h2.dim(5)=1;

write_nii('cbfmap.nii', cbfmap, h2, 0)



