% SPM_batch
% script for repeated SPM anaylyse

% copy all the parameter files into this directory
!cp ~hernan/bin/*.mat .


%smoothing
%---------------------
disp('smoothing ...')
load WS_smooth;
for i = 1:n
	Q = P(i,:);
	Q = Q(Q ~= ' ');
	d = max([find(Q == '/') 0]);
	U = [Q(1:d) 's' Q((d + 1):length(Q))];
     if ~strcmp(U([1:4] + length(U) - 4),'.img'); U = [U '.img']; end
     	spm_smooth(Q,U,s);
end

disp('done')

%realignment
%---------------------
disp('Realigning ...')
global MODALITY sptl_WhchPtn sptl_DjstFMRI sptl_CrtWht sptl_MskOptn
load WS_realign
spm_realign(P,Flags);
disp('done.')


% Statistics
%--------------------
global UFp

% Load workspace
disp('SPM-img ...')
load WS_stats

% Store scalefactors in file identifiers
%storeV = V;

%-Get file identifiers
V     = zeros(12,q);
for i = 1:q
V(:,i) = spm_map(P(i,:));
end
% Rescale them
%V(7, :) = storeV(7, :);

% run analysis
% for fMRI
spm_spm(V,H,C,B,G,CONTRAST,ORIGIN,GX,HCBGnames,P,SIGMA,RT);

% for PET
% spm_spm(V,H,C,B,G,CONTRAST,ORIGIN,THRESH*GX,HCBGnames,P,0,[])
disp('done')

%Results
%---------------------
disp('results...');
spm_results_noui
disp('done.')
%pause



