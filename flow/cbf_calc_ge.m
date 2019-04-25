function [cbfmap]=cbf_calc_ge(asl_filename);
% this calculates cbf maps from the GE scanner's PCASL 
% sequence.  PCASL with BGS and 3D GRASE stack of spirals
% readout.
% Assumptions:
%
% alpha=0.9;  % partition coefficeint .. (usually lambda)
%
% ST=2;    % saturation time for 
%
% T1t=1.2;  % Tissue T1
%
% eff=0.6;  % inversion efficiency ...(usually alpha, and usually around 0.85)
%
% T1b=1.6;  % Blood T1
%
% LT=1.5;  % labeling time
%
% SF=32;   % the scanner's proton density image needs to be multiplied by SF
%	   % the image is also thresholded by 0.5*sum(pd(:).^2)/sum(pd(:))
%  UMMAP NEX=3   PLD=1.525
%  PTR   NEX=3   PLD=2.025
% ^ 

tst=read_nii_img(asl_filename);
tst=reshape(tst.',[128 128 40 2]);

pw=tst(:,:,:,1);
pd=tst(:,:,:,2);

msk1=(pw==0);   %mask outside spiral coverage
msk2=(pd<200);  %masks non-brain areas

%%
alpha=0.9;
ST=2;
T1t=1.2;
eff=0.6;
T1b=1.6;
LT=1.5; 
NEX=3;
PLD=1.525;   %for PTR change this to 2.025


eqnum=(1-exp(-ST/T1t))*exp(PLD/T1b);

eqdenom=2*T1b*(1-exp(-LT/T1b))*eff*NEX;

SF=32;

cbf=6000*alpha*(eqnum/eqdenom)*(pw./(SF*pd));

cbfmap=cbf;
cbfmap(find(msk1))=0;
cbfmap(find(msk2))=1;

%% Get original header, use it to write out cbfmap as nifti image

h=read_nii_hdr(asl_filename);

h2=h;
h2.dim(5)=1;

write_nii('cbfmap.nii', cbfmap, h2, 0)

%%  Make PD map, scale and write out as nifti image

pdmap=SF*pd;

pdmap(find(msk1))=0;
pdmap(find(msk2))=0;

write_nii('pdmap.nii', pdmap, h2, 0);

return

