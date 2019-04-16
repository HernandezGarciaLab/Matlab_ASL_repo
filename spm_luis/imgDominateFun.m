function imgDominateFun(h, data, xyz, DesMat)
%function imgDominateFun(header, timeseries_data, [xyz_coords], DesMat)
%
% (c) 2005 Luis Hernandez-Garcia
% University of Michigan
% report bugs to:  hernan@umich.edu
%
% hard coded: choose whether we filter or pre-whiten
%
% this function goes through all the pixels and
% 1) pre-conditions the signals (filter, regress out effects of interest, whiten ...etc)
% 2) binarize them by calling the indicator function
% 3) compute the conditional probabilities relative to the exemplar time
% course extracted fromt he xyz voxels.
%
global threshold
if isempty(threshold)
    threshold=0.9;
end


doWhiten = 0;
doFilter=1;
binsize = 2;

x = xyz(:,1);
y = xyz(:,2);
z = xyz(:,3);

fprintf('\nBegin conditional probability Analysis ...');
ind = sub2ind([h.xdim, h.ydim, h.zdim], x,y,z);
exemplar = mean(data(:,ind),2);

if ~isempty(DesMat)
    % remove the known effects of interest (specified in design matrix):
    c = ones(1,size(DesMat,2));
    %[t, beta_est, vBeta, RSS] = my_glm(DesMat,exemplar,c);
    [t, beta_est, vCon] = myLinReg(DesMat,exemplar,c);
    exemplar = exemplar - DesMat*beta_est;
    fprintf('\nregressed out the design matrix')
end

MI = zeros(1,size(data,2));
mask1 = zeros(1,size(data,2));
dominance = zeros(1,size(data,2));
dominance(:) = nan;
ascendancy = zeros(1,size(data,2));
%dominance2 = zeros(1,size(data,2));
rho = zeros(1,size(data,2));
pval = zeros(1,size(data,2));
pval(:) = nan;
Pa_b = zeros(1,size(data,2));
Pb_a = zeros(1,size(data,2));
Nevents = zeros(1,size(data,2));

if doWhiten
    % whitening the noise in the data
    exemplar = whiten(exemplar , DesMat);
end

% mask out pixels below this value
Thres1 =  mean(data(10,:)) *0.5;
fprintf('\nAnalyzing pixels above : %0.3f ', Thres1);
warning off

% low pass filter
exemplar = LPFilter01(exemplar, 0);

% detrend data - added in 070629
exemplar = mydetrend(exemplar);

% event detection
 exemplar_events = indicator(exemplar, threshold, binsize);


%
%hrfn = spm_hrf(0.5);
%exemplar = exemplar - min(exemplar);
%exemplar_events = events_detect(exemplar', hrfn);
%


for pix=1:size(data,2)
    if data(10,pix) > Thres1
        mask1(pix) = 1;

        % select a pixel's time course:
        tseries = data(:,pix);

        % whiten the data if necessary
        if doWhiten
            tseries = whiten(tseries, DesMat);
        end

        % remove Design matrix from pixels
        if ~isempty(DesMat)
            c = ones(1,size(DesMat,2));
            [t, beta_est, vBeta] = myLinReg(DesMat,tseries,c);
            tseries = tseries -  DesMat*beta_est;
        end

        % update a progress histogram
        if mod(pix,500)==0
            fprintf('\r Dominance tests pix: %d of %d  ', pix, size(data,2))
            hist(pval(find(~isnan(pval)))); title('Histogram so far ... -10*log(p)');
            drawnow
        end

        % old stuff (it works, though)
        % [d, a, mi, r] = causal05(exemplar',tseries',doFilter);
        % [d, a, mi, r, d2] = causal05(exemplar',tseries',doFilter);

        % low pass filter and linear detrend the data
        tseries = LPFilter01(tseries, 0);

        % detrending (3rd order) of the data.  (7/3/07)
        tseries = mydetrend(tseries);

        % peak detection:
         tseries_events = indicator(tseries, threshold, binsize);
       
        %tseries = tseries - min(tseries); 
	  %tseries_events = events_detect(tseries',hrfn);


	  Nevents(pix) = sum(tseries_events);

        % Dominance calculation:
        [D, thetas] = Dominance(exemplar_events, tseries_events);

        % Compute Inference (significance level) on pixels above a given
        % Dominance threshold
        if abs(D) >= 0.05
            [p, D, allD]= Dominance_shoelace(exemplar_events , tseries_events);
        else
            p=NaN;
            %D = NaN;
        end

        r = corrcoef(exemplar, tseries);
        mi = mutual_info(exemplar, tseries);

        % Bonus: Ascendancy calculation:
        if thetas(2) > thetas(3)
            a = 1 - (thetas(1) + thetas(3))/(thetas(1) + thetas(2));
            %d2 = -Pa_b*ascend;
        else
            a = (thetas(1) + thetas(2))/(thetas(1) + thetas(3))-1;
            %d2 = -Pb_a*ascend;
        end

        % For diagnostic purposes - let's store the conditional probs.
        % P(b|a) = P(ab) / P(a)
        Pb_a(pix)  = thetas(1) / (thetas(1) + thetas(2));
        % P(a|b) = P(ab) / P(b)
        Pa_b(pix)  = thetas(1) / (thetas(1) + thetas(3));

        dominance(pix) = D;
        pval(pix) = -10*log(p);
        ascendancy(pix) = a;
        % dominance2(pix) = d2;
        rho(pix)=r(2,1);
        MI(pix) = mi;
    end
end
warning on

figure
% show histograms of the results.
subplot(221)
hist(dominance(dominance~=0),100);title('Dominance')
%axis([-0.2 0.2 0 50])
subplot(222)
hist(ascendancy(ascendancy~=0),100);title('Ascendancy')
%axis([-0.2 0.2 0 50])
subplot(223)
hist(rho(rho~=0),100); title('Correlation COeff')
%axis([-1 1 0 50])
subplot(224)
hist(MI(MI~=0),100); title('Mutual Information')
%axis([-1 1 0 50])

%
% dominance = reshape(dominance,h.xdim, h.ydim,h.zdim);
% MI = reshape(MI,h.xdim, h.ydim,h.zdim);
% H_asym = reshape(H_asym,h.xdim, h.ydim,h.zdim);
% rho = reshape(rho,h.xdim, h.ydim,h.zdim);

global SPM_scale_factor
SPM_scale_factor = 1/1000;
mask = zeros(size(MI));
meanMI = mean(MI(:))
stdMI = std(MI(:));
mask(MI> meanMI + stdMI  )=1;

h.tdim = 1;

write_hdr('MI.hdr',h);
write_hdr('Rho.hdr',h);
write_hdr('Dominance.hdr',h);
write_hdr('Dominance_MIM.hdr',h);
write_hdr('Pa_b.hdr',h);
write_hdr('Pb_a.hdr',h);

%write_hdr('H_asym.hdr',h);
write_img('MI.img',MI/SPM_scale_factor,h);
write_img('Rho.img',rho/SPM_scale_factor,h);
write_img('Dominance.img',dominance/SPM_scale_factor,h);
write_img('Dominance_MIM.img', mask.*dominance/SPM_scale_factor,h);
write_img('Pa_b.img',Pa_b/SPM_scale_factor,h);
write_img('Pb_a.img',Pb_a/SPM_scale_factor,h);

SPM_scale_factor = 1;
write_hdr('Nevents.hdr',h);
write_hdr('10logP_MIM.hdr',h);
write_img('10logP_MIM.img', mask.*pval,h);
write_img('Nevents.img', Nevents , h);
%write_img('H_asym.img',H_asym*1000,h);

save dominance

return

