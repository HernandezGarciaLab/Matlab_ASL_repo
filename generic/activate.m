
%clear all
close all

filename='no_grad2';
nimpertr=50;
ntr=4;
TR=2;
noff=8-1;
dthr=30;
bim=2:7;
aim=9:11;

%[raw, lro, lpe, thk, total_tr, te, ti, ref_pos, ss, sli_val] = epirecon(filename);

expLength = 419;
stimLength = 10/2; 


raw2avw(abs(raw), 'mag.img');
raw2avw(angle(raw)*1000, 'pha.img');


reg1 = ones(expLength,1);
onsets = [10:100:length(reg1)-20];
reg2 = zeros(size(reg1));

for n=1:length(onsets)
    reg2(onsets(n):onsets(n)+stimLength)=1;
end


hrf = make_hrf(0,3,30);

reg2 = conv(reg2,hrf);
reg2 = reg2(1:length(reg1));
reg2 = reg2/max(reg2);

modulator = ones(length(reg1),1);
modulator(1:2:end) = -1;
modulator = modulator/2;

reg3 = reg1.*modulator;
reg4 = reg2.*modulator;

X = [reg1 reg2 reg3  reg4];

% mean centering
xm = mean(X,1);
z2=repmat(xm,expLength,1);
X = X-z2;
X(:,1) = 1;

% X = X(4:2:end,1:2);
X = X(12:end-1, 1:2);
% X(:,2) = ref;

% aslsub('mag',1,3,418,0,1,0);
aslsub_sur('mag',10,418,0,1);

msk=lightbox('mean_con'); 
msk(msk<1500)=0; msk(msk>0)=1;
lightbox(msk);

spmJr('sub.img', X, [0 1]);

lightbox('Zmap_0001');

% display in ortho
ortho2005([],...,
    'ROItype','sphere',...
    'threshold', 1.5,...
    'tseries_file', 'sub.img',...
    'anat_file', 'mean_sub',...
    'spm_file', 'Zmap_0001.img',...
    'onsets',onsets);
    
