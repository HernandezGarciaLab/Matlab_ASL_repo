function result = LPFilter01(a, doPlots)
% function result = LPFilter01(a, doPlots)
%
% this is a hard coded low pass filter followed by polynomial detrending.
%
% the following filter taps were designed with this:
% cutoff = 0.3;
% N_coeffs = 10;
% taps = remez(N_coeffs, [0 cutoff-0.05  cutoff+0.05  1], [1 1 0 0]);

% taps for cutoff = 0.5
taps=[0.0865 -0.0535 -0.1288  -0.0023 0.2976 0.4618 0.2976 -0.0023  -0.1288 -0.0535 0.0865];
% taps for cutoff 0.3
%taps= [-0.1058 -0.0348 0.0416 0.1589 0.2661 0.3094 0.2661  0.1589 0.0416 -0.0348 -0.1058];

b = filtfilt(taps,1,a);

if doPlots
    tmpa = a-mean(a);
    tmpb = b-mean(b);
    tmpa = tmpa/(sum(tmpa.^2));
    tmpb = tmpb/(sum(tmpb.^2));
end

result = b;

return
