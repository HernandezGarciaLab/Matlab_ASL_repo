function f = calc_cbf_wp(Diff_file, SpinDens_file, inv_alpha,  Ttag, TR, PLD, T1)
% 
% function f = calc_cbf_wp(Diff_file, SpinDens_File, inv_alpha,Ttag, TR, PLD, T1)
%
% We then use the input tagging time, TR , PostInversionDelay and T1 along 
% with the calculated spin density in 
% order to compute a CBF map.
% Notes:
% The spin Density map gets smooted to avoid funny spikes from the denominator.
% The CBF calculation uses the equaiton in Alsop and Detre paper from 1996:
%

if nargin==9
    isGrappa=0;
end


[s h] = read_img(Diff_file);
[M0 h]= read_img(SpinDens_file);


% % correct for partial  T1 saturation effect
% M0 = M0/(1 - cos(flip)* exp(-TR/T1));
% % calculate |M| from its projection onto the xy plane
% M0 = M0/sin(flip);

% Use Floats for flow images
h.datatype = 16;
h.bits = 32;

% smooth the spin density
M0 = reshape(M0, h.xdim, h.ydim, h.zdim);
M0 = smooth3(M0, 'gaussian', [5 5 3]);
M0 = M0(:)';


% smooth the subtraction images
s = reshape(s, h.xdim, h.ydim, h.zdim);
s = smooth3(s, 'gaussian', [3 3 1]);
s = s(:)';


% Masking the data (not used)
mask = zeros(size(M0));
mask(find(M0>0.2*max(abs(M0(:)))))=1;

% use the  average M0 over the mask:
%M0 = M0.*mask;
%M0 = mean(M0(find(M0)));

% necessary constants for model
lambda = 0.9;
T1a = 1.67;
T1app = T1;

% Equation from White paper: assumes single compartment, or that PLD>Ttrans
num = (s)*lambda*exp(PLD/T1a);
den = 2*inv_alpha*T1a *M0 * (1 - exp(-Ttag/T1a));
f = num./den * 6000;  % adjust units to ml/min/100 g

write_img('Flow.img',f  ,h);
write_img('sSpinDensity.img',M0 ,h);


return
