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

[raw h] = read_img(raw_file);

% things may not yet be at steady state, so ...
M01 = raw(1:2:M0frames,:);
M02 = raw(2:2:M0frames,:);

% skip another pair to make sure that there is equilibrium
c = raw(M0frames+3:2:end,:);
t = raw(M0frames+4:2:end,:);

M0 = mean(M02,1);
if isGrappa
    load fullysampled.mat
    M0=fullimg(:)';
end
s = c - t;

s = mean(s,1);
c = mean(c,1);
t = mean(t,1);

hdr = h;
hdr.tdim = hdr.tdim/2 -3;

% doing compcor on the time series
%{
dirty = s;
[clean junkcoms] = compcor12(dirty, hdr);
s = mean(clean,1);
%}


% is the order reversed?
if (mean(c(:)) <mean(t(:)) )
    tmp = c;
    c = t;
    t = tmp;
    s = -s;

    M0 = mean(M02,1);
end


%keyboard;
if ~isfield(h,'zsize')
    h=nii2avw_hdr(h);
end
h.tdim = 1;
global SPM_scale_factor

% correct for partial  T1 saturation effect
M0 = M0/(1 - cos(flip)* exp(-TR/T1));
% calculate |M| from its projection onto the xy plane
M0 = M0/sin(flip);
M0scale = sum(M0(:));

SPM_scale_factor = 1;

write_img('SpinDensity.img',M0/100 ,h);
write_img('Control.img',c ,h);
write_img('Tagged.img',t,h);

spm_smooth('SpinDensity.img','sSpinDensity.img',[ 8 8 8], 4 );

% the smoothing process causes rescaling of the image
% we want to rescale to original values!
[M0 h] = read_img('sSpinDensity.img');
M0 = M0scale*M0(:)'/sum(M0(:));

% 
mask = zeros(size(c));
mask(find(s>0.10*max(abs(s(:)))))=1;

lambda = 0.9;
T1a = 1.67;
T1app=1/(1/T1 + 0.01/lambda);

% average M0 over the mask:
M0 = M0.*mask;
M0 = mean(M0(find(M0)));

fprintf('\nAveraging all the M0 values for the gray matter together...\n') 

% This is equation 3 from Alsop et al: JCBFM 16, 1236-1249,1996
%den = T1app*2*M0*inv_alpha/lambda * exp(-Ttrans*(1/T1a-1/T1app))*exp(-pid/T1a);
num = c-t;

% modification by Wang et al MRM 48,1,p242-254, 2002:
%den = T1app*2*M0*inv_alpha/lambda * ...
%    (exp(-Ttrans*(1/T1a-1/T1app)) - exp((Ttrans-pid-Ttag)/T1app))...
%    *exp(- pid/T1a);

% looking at equation 1, delta_a and delta should be almost the same, we
% can drop a term.
den =  2 * M0* inv_alpha / lambda ...
    *( T1app*exp(-Ttrans/T1a) * ( exp( (Ttrans-pid)/T1app ) - exp( (Ttrans-Ttag-pid)/T1app)));


% Equation from White paper:
num = (s)*lambda*exp(pid/T1a);
den = 2*inv_alpha*T1app *M0 * (1 - exp(-Ttag/T1a));

f = num./den * 6000;  % adjust units to ml/min/100 g

%f = f.*mask;

write_img('mean_sub.img', s,h);

SPM_scale_factor = 0.01;  % multiply by 100 to use full dynamic range 
write_img('Flow.img',f *100 ,h);
save CASL_quant.mat
SPM_scale_factor = 1;
return
