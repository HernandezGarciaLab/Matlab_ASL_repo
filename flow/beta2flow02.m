function beta2flow03(betafile, varfile, TR,Ttag,pid,Ttrans, inv_alpha, isSubtracted)
% function beta2flow03(betafile, varfile, TR,Ttag,pid,Ttrans, inv_alpha, isSubtracted)
%
% Takes the parameter estimates of a GLM for ASL data and turns them into 
% perfusion values.
% 
% version 02 also computes the variance estimates using the variance
% estimates of the betas
% version 03 takes into account the difference in slice timing.  If it
% doesn't find a file called slicetiming.dat, then it assumes the order is
% sequential
%
% note this also works for contrasts of paramater estimates and their
% variances

% important assumptions:
% - if data are unsubtracted, beta_0 is the intercept = the baseline (Mcontrol)
%     we assume betas(1,:) = beta_0 map
% - at 3Tesla, constants are approxiamated as:
%     partition coeff. lambda = 0.9;
%     gray matter T1 = 1.4;
%     arterial blood T1a = 1.65;
% - output units are in 100* ml/min/100g
% - all voxels are treated the same. ie - no distinction between white and grey.
%   Best mask out the white matter.
%
% Outputs:
% ExpFlow.img:  contains a perfusion map for every beta in the beta file.
% NOTE: since the first set of betas is related to the spin density, the
% first Flow file is not really flow, but some useless large values.
%
% ExpFlow_vars:  the variance estimates obtained from the above flow
% estimates
%
% assumptions:

lambda = 0.9;

% Relaxation and MT constants are from Stanisz's paper : MRM 54,3,p.507-512, 2005
T1 = 1.47;  % Ethofer , MRM Volume 50, Issue 6, pages 1296?1301, December 2003
%T1 = 1.820;  % Stanisz 2005
R1 = 1/T1;

MTR = .84 ;    % Stanisz 2005
T1sat = T1*MTR ;  % I'm not sure about this one....
MTC = 1 - T1sat/T1 ;
MTC = 0;  % neglect MTC effects

T1a = 1.65;   % Lu 2006?
%T1a = 1.93;  % Stanisz 2005
R1a = 1/T1a;

T1app=1/(1/T1 + 0.015/lambda);
R1app = 1/T1app;


% Transit time is assumed to be the time to get to the tissue
% assume it get to teh arteries .4 seconds earlier before the exchange
Ttransart = Ttrans - 0.400;


[betas h] = read_img(betafile);
if isSubtracted
	c = read_img('mean_con');
else
	c = betas(1,:) ; % beta_0 is the intercept = the baseline (Mcontrol)
end

if h.tdim==1
	betas=betas(:)';
	c=c(:)';
end

Nbetas = size(betas,1);
f = zeros(size(betas));
mask = zeros(size(betas));
mask(find(c>0.2*max(c(:))))=1;

M0 = c/(1 - exp(-TR/T1));

Nslices = h.zdim;
Spix = h.xdim * h.ydim;
sltime = [0:Nslices-1] * (TR - Ttag - pid)/Nslices;

if exist('sliceorder.dat')
    tmp = load('sliceorder.dat');
    sltime = (tmp-1) * (TR - Ttag - pid)/Nslices;
end
pid0 = pid;

for sl=1:Nslices
    
    slstart = (sl-1)*(Spix)+1;
    slend = sl*Spix;
    
    pid = pid0; %  + sltime(sl);  No slice timing difference in 3D mode!

    fprintf('\nComputing slice %d with PID = %f', sl, pid);
    
    % This is equations  9 and 10 from Alsop et al: JCBFM 16,
    % 1236-1249,1996
    %
    %
    A = min(Ttrans - pid,0);
    B = min(Ttransart - pid, 0);
    
%     dummy =  2 *  (inv_alpha / lambda)*...
%         T1app*exp(-Ttrans/T1a) * (exp(A/T1app) - exp(-pid*R1app)*MTC ) + ...
%            T1a*(exp((B - Ttransart)/T1a)  -  exp((A-Ttrans)/T1a) );
       
    den(slstart:slend) =  2 * M0(slstart:slend) * (inv_alpha / lambda)*...
        T1app*exp(-Ttrans/T1a) * (exp(A/T1app) - exp(-pid*R1app)*MTC ) + ...
           T1a*(exp((B - Ttransart)/T1a)  -  exp((A-Ttrans)/T1a) );
end

den = repmat(den, Nbetas,1);
mask = repmat(mask, Nbetas,1);
f = betas./den * 6000;  % conversion factor from ml/s/g to ml/min/100g
f = f.*mask;

f(find(isnan(f))) = 0;


%% now do the variance estimates using error propagation
[vars h] = read_img(varfile);


if isSubtracted
	allM0 = read_img('control.img');
	allM0 = allM0/(1 - exp(-TR/T1));
	varM0 = var(allM0, [], 1 );
else
	% assume var(Beta0) is the first one in the file
	varM0 = vars(1,:);
end

varM0 = repmat(varM0, Nbetas,1);

% compute partial derivatives of perfusion relative to each variable  (use
% the stuff above!

df_dBeta = 1 ./ den;

df_dM0 = - betas ./ (den .*  repmat(M0,Nbetas,1) );

%    * T1app * exp(-Ttrans/T1a) ...
%	* ( exp( (Ttrans-pid)/T1app ) - exp( (Ttrans-Ttag-pid)/T1app))...
%	);

flowVars =   varM0 .* df_dM0.^2  + vars .* df_dBeta.^2;


flowVars = flowVars * 6000^2;  % units conversion
flowVars = flowVars .* mask;


write_img('ExpFlows.img',f ,h);
write_hdr('ExpFlows.hdr',h);

write_img('ExpFlow_vars.img',flowVars ,h);
write_hdr('ExpFlow_vars.hdr',h);

