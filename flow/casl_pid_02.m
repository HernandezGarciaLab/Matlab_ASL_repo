function f = casl_pid_02(raw_file, M0frames, inv_alpha, flip, Ttag, TR, pid, Ttrans, T1, isGrappa)
%function f = casl_pid_02(rawfile, M0frames, inv_alpha, flip, Ttag, TR, pid, Ttrans, T1, [isGrappa])
% 
% this function assumes that the first M0frames are acquired without
% Background sppression pulses and uses them to calculate a spin density
% map.
% The remaining frames are used to compute the deltaM measurement
% We then use the input tagging time, TR , PostInversionDelay and T1 along 
% with the calculated spin density in 
% order to compute a CBF map.
% Notes:
% The spin Density map gets smooted to avoid funny spikes from the denominator.
% The CBF calculation uses the equaiton in the ASL white paper:
%

if nargin==9
    isGrappa=0;
end

doMask = 1;
MskLevel = 0.25;

doCompCor = 0 ;
doDespike=1;
DespikeLevel = 1.25;  % in units of standard deviation
%DespikeLevel = 1.5;  % in units of standard deviation
%DespikeLevel = 1.0;  % in units of standard deviation

[raw h] = read_img(raw_file);

% if GRAPPA recon, then the Spin Density is stored in a separate file:
if isGrappa
    load fullysampled.mat
    M0=fullimg(:)';
    M0frames = 0;
else
    M01 = raw(1:2:M0frames,:);
    M02 = raw(2:2:M0frames,:);
    M0 = mean(M02,1);
end

% skip a pair of frames to make sure that there is equilibrium
c = raw(M0frames+3:2:end,:);
t = raw(M0frames+4:2:end,:);

% is the order reversed?
if (mean(c(:)) <mean(t(:)) )
    tmp = c;
    c = t;
    t = tmp;
    
end


% correction for T1 settling 
M0 = M0/(1 - exp(-TR/T1));

%
if doDespike
    
    fprintf('\n Removing raw frames that are more than %f Sigma from the mean ...\n',DespikeLevel );
    
    mc = mean(c,2);
    stdmc = std(mc);
    mmc = mean(mc);
    badinds = find( abs(mc - mmc) > DespikeLevel *stdmc)
    c(badinds,:) = [];

    
    mt = mean(t,2);
    stdmt = std(mt);
    mmt = mean(mt);
    badinds = find( abs(mt - mmt) > DespikeLevel*stdmt)
    t(badinds,:) = [];

end
%
%
% 
%{
%begin new despike
if doDespike
    
    fprintf('\n Removing timponts that are more than %f Sigma from the mean (voxelwise)...\n',DespikeLevel );
    for p=1:size(c,2)
        % tagged images 
        tseries = t(:,p);
        tm = mean(tseries);
        tstd = std(tseries);
        badinds = find( abs(tm - tseries) > DespikeLevel*tstd);
        tseries(badinds) = [];
        t_tmp(p) = mean(tseries);

        
        % control images 
        cseries = c(:,p);
        cm = mean(cseries);
        cstd = std(cseries);
        badinds = find( abs(cm - cseries) > DespikeLevel*cstd);
        cseries(badinds) = [];
        c_tmp(p) = mean(cseries);

    end
    c = c_tmp;
    t = t_tmp;
        
else
    c = mean(c,1);
    t = mean(t,1);
end
%}
%- end new despike
if doCompCor
   
    Ncomps = 6;
    fprintf('\nApplyting Compcor with %d junkcomps...\n', Ncomps );
    s = c-t;
    % doing compcor on the time series
    %
    hdr = h;
    hdr.tdim = hdr.tdim/2-4 ;
    
    dirty = s;
    [clean junkcoms] = compcor12(dirty, hdr, Ncomps);
    s = mean(clean,1);
end

c = mean(c,1);
t = mean(t,1);

if ~doCompCor
    s = c-t;
end


if doMask
    fprintf('\n Masking voxels that are below %f of the mean of M0 ...\n',MskLevel );

    msk = ones(size(M0));
    msk(M0 < MskLevel*mean(M0))= 0 ;
    c = c .* msk;
    t = t .* msk;
end



write_img('Control.img',c ,h);
write_img('Tagged.img',t, h);


if ~isfield(h,'zsize')
    h=nii2avw_hdr(h);
end
h.tdim = 1;
write_img('mean_sub.img', s,h);


% % correct for partial  T1 saturation effect
% M0 = M0/(1 - cos(flip)* exp(-TR/T1));
% % calculate |M| from its projection onto the xy plane
% M0 = M0/sin(flip);

% Use Floats for flow images
h.datatype = 16;
h.bits = 32;
write_img('SpinDensity.img',M0 ,h);

% smooth the spin density
M0 = reshape(M0, h.xdim, h.ydim, h.zdim);
M0 = smooth3(M0, 'gaussian', [7 7 7]);
M0 = M0(:)';


% smooth the subtraction images
s = reshape(s, h.xdim, h.ydim, h.zdim);
s = smooth3(s, 'gaussian', [3 3 1]);
s = s(:)';


% Masking the data (not used)
mask = zeros(size(M0));
mask(find(M0 > 0.1*max(abs(M0(:)))))=1;

% use the  average M0 over the mask:
%fprintf('\nAveraging all the M0 values for the gray matter together...\n') 
%M0 = M0.*mask;
%M0 = mean(M0(find(M0)));

% necessary constants for model
lambda = 0.9;
T1a = 1.67;
% T1app=1/(1/T1 + 0.01/lambda);
T1app = T1;


% This is equation 3 from Alsop et al: JCBFM 16, 1236-1249,1996
% num = c-t;
% den = T1app*2*M0*inv_alpha/lambda * exp(-Ttrans*(1/T1a-1/T1app))*exp(-pid/T1a);

% modification by Wang et al MRM 48,1,p242-254, 2002:
% den = T1app*2*M0*inv_alpha/lambda * ...
%    (exp(-Ttrans*(1/T1a-1/T1app)) - exp((Ttrans-pid-Ttag)/T1app))...
%    *exp(- pid/T1a);

% looking at equation 1, delta_a and delta should be almost the same, we
% can drop a term.
% den =  2 * M0* inv_alpha / lambda ...
%     *( T1app*exp(-Ttrans/T1a) * ( exp( (Ttrans-pid)/T1app ) - exp( (Ttrans-Ttag-pid)/T1app)));


% Equation from White paper: assumes single compartment, or that PID>Ttrans
num = (s)*lambda*exp(pid/T1a);
den = 2*inv_alpha*T1a *M0 * (1 - exp(-Ttag/T1a));

f = num./den * 6000;  % adjust units to ml/min/100 g

% Use the stuff in the mask only (not used) 
% f = f.*mask;
f(f>1000)=0;

write_img('Flow.img',f  ,h);
write_img('sSpinDensity.img',M0 ,h);

save CASL_quant.mat

return
