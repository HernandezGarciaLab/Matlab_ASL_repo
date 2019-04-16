function imgAscendFun(h, data, xyz, DesMat)
%function imgAscendFun(header, timeseries_data, [xyz_coords], DesMat)
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
% 4) compute dominance (Hernandez)
% 5) compute Ascendency (Patel)

doWhiten = 0;
doFilter=1;

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
dominance = zeros(1,size(data,2));
H_asym = zeros(1,size(data,2));
rho = zeros(1,size(data,2));
ascendancy = zeros(1,size(data,2));

if doWhiten
    % whitening the noise in the data
    exemplar = whiten(exemplar , DesMat);
end

% mask out pixels below this value
Thres1 =  max(data(10,:)) *0.1
warning off

for pix=1:size(data,2)
    if data(10,pix) > Thres1

        tseries = data(:,pix);
        if doWhiten
            tseries = whiten(tseries, DesMat);
        end
        
        if ~isempty(DesMat)
            c = ones(1,size(DesMat,2));
            [t, beta_est, vBeta] = myLinReg(DesMat,tseries,c);
            tseries = tseries -  DesMat*beta_est;
        end
        
        [d, a, mi, r] = causal05(exemplar',tseries',doFilter);

        if mod(pix,500)==0
            fprintf('\r Dominance tests pix: %d of %d: Dom= %f Asc=%f MI=%f Rho= %f ',...
                                            pix, size(data,2), d,a,mi,r)
        end


        dominance(pix) = d;
        ascendancy(pix) = a;
        %H_asym(pix) = H2;
        rho(pix)=r;
        MI(pix) = mi;
    end
end
warning on 

figure
% show histograms of the results.
subplot(221)
hist(dominance(:),100);title('Dominance')
%axis([-0.2 0.2 0 50])
subplot(222)
hist(ascendancy(:),100);title('Ascendancy')
%hist(H_asym(:),100);title('Histogram Asymmetry')
%axis([-0.2 0.2 0 50])
subplot(223)
hist(rho(:),100); title('Correlation COeff')
%axis([-1 1 0 50])
subplot(224)
hist(MI(:),100); title('Mutual Information')
%axis([-1 1 0 50])

% 
% dominance = reshape(dominance,h.xdim, h.ydim,h.zdim);
% MI = reshape(MI,h.xdim, h.ydim,h.zdim);
% H_asym = reshape(H_asym,h.xdim, h.ydim,h.zdim);
% rho = reshape(rho,h.xdim, h.ydim,h.zdim);

global SPM_scale_factor
SPM_scale_factor = 1/1000;
mask = zeros(size(MI));
mask(MI>1.5)=1;

h.tdim = 1;

write_hdr('MI.hdr',h);
write_hdr('Rho.hdr',h);
write_hdr('Dominance.hdr',h);
write_hdr('Dominance_MIM.hdr',h);
write_hdr('Ascendancy.hdr',h);

%write_hdr('H_asym.hdr',h);
write_img('MI.img',MI/SPM_scale_factor,h);
write_img('Rho.img',rho/SPM_scale_factor,h);
write_img('Dominance.img',dominance/SPM_scale_factor,h);
write_img('Dominance_MIM.img', mask.*dominance/SPM_scale_factor,h);
write_img('Ascendancy.img',ascendancy/SPM_scale_factor,h);
%write_img('H_asym.img',H_asym*1000,h);
save ascendancy

return

