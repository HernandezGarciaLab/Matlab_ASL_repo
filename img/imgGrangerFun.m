function imgGrangerFun(h, data, xyz, DesMat, Nlag)
% function imgGrangerFun(header, timeseries_data, xyz_coords,DesMat, Nlag)
%
% Compute granger causality on a time series of images specified by
% rootname (this can be one of the images in the timeseries, or just the
% root part of the file names)
%
% x,y,z are the voxel coordinates of the region that we
% want to use for extraction of the exemplar time course.
%
% Desmat is the design matrix containing the effects that
% can be modeled by the experimental conditions
%
% (c) 2005 Luis Hernandez-Garcia 
% University of Michigan
% report bugs to:  hernan@umich.edu
%
%

%Nlag = 7;
doPlots = 0;
doDetrend = 0;
doGlobal = 1;

x = xyz(:,1);
y = xyz(:,2);
z = xyz(:,3);
fprintf('\nBegin Granger Analysis ..')
fprintf('\n indexing ...\n')
ind = sub2ind([h.xdim, h.ydim, h.zdim], x,y,z);

if doGlobal
    globalseries = mean(data,2);
    DesMat = [DesMat globalseries];
end

exemplar = data(:,ind);
% average time series over pixels if we select several pixels
% in the exemplar ROI.
fprintf('\n averaging ...\n')
exemplar = mean(exemplar,2);

if doDetrend
    % filter the exemplar here
    exemplar = mydetrend(exemplar')';
end

F = zeros(1,size(data,2));
Fab = zeros(1,size(data,2));
Fba = zeros(1,size(data,2));
chi2 = zeros(1,size(data,2));

% threshold for analysis 10% of the max value in the 10th image
threshold = max(data(10,:)) *0.1
warning off
df = 0;
for pix=1:size(data,2)
    if data(10,pix) >= threshold
        df = df + 1;
        if mod(pix,500)==0
            fprintf('\r Granger test pix: %d', pix)
        end
        tseries = data(:,pix);

        if doDetrend
            % filter here:
            tseries = mydetrend(tseries')';
        end
        
        %keyboard
        [fab , fba, c] = granger(exemplar', tseries', DesMat, Nlag,  doPlots);
        F(pix) = fab - fba;
        Fab(pix) = fab;
        Fba(pix) = fba;
        chi2(pix) = c;
        if doPlots
            fprintf('\r Granger test pix: %d, chi2 = %f , F=%f  ', pix, c, f)
            plot(exemplar); hold on; plot(tseries); hold off
            drawnow
        end
    else
        F(pix) = NaN;
        chi2(pix) = NaN;
        %fprintf('\r Granger test pix: %d', pix)
    end
end

fprintf('Computing p values ...')
meanF = mean(F(~isnan(F)));
pval = 1 - spm_Fcdf(F, Nlag, length(exemplar)-2*Nlag-1);

figure
% show histograms of the results.
subplot(221)
hist(Fab(Fab~=0),100);title('Granger F_A->_B')
%axis([-0.2 0.2 0 50])
subplot(222)
hist(Fba(Fba~=0),100);title('Granger F_B->_A')
%axis([-0.2 0.2 0 50])
subplot(223)
hist(F(F~=0),100); title('Granger F (Fab-Fba)')
subplot(224)
hist(pval(pval~=0),100);title('P(F)')

fprintf('\n writing results ... Fab - Fba\n')
global SPM_scale_factor
SPM_scale_factor = 1/1000;
h.tdim=1;
write_hdr('grangerlog10P.hdr',h);
write_img('grangerlog10P.img',-10*log10(pval)/SPM_scale_factor, h);
write_hdr('grangerFab.hdr',h);
write_img('grangerFab.img',Fab/SPM_scale_factor,h);
write_hdr('grangerFba.hdr',h);
write_img('grangerFba.img',Fba/SPM_scale_factor,h);
write_hdr('grangerF.hdr',h);
write_img('grangerF.img',F/SPM_scale_factor,h);
write_hdr('grangerCHI2.hdr',h);
write_img('grangerCHI2.img',chi2/SPM_scale_factor,h);
save granger_wkspace
fprintf('\n... Done\n')

return
