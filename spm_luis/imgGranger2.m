function imgGranger2(rootname, exemplar,DesMat)
% function imgGranger(rootname,exemplar,DesMat)
% 
% Compute granger causality on a time series of images specified by
% rootname (this can be one of the images in the timeseries, or just the
% root part of the file names)
%
% exemplar is a time course that we want to compute the Granger causality
% relative to.
%
% Desmat is the design matrix containing the effects that 
% can be modeled by the experimental conditions
%
Nlag = 3;
doPlots = 0;

h = read_hdr(rootname);
fprintf('\n reading time series ...\n')
data = read_img_series(rootname(1:end-8));
fprintf('\n indexing ...\n')
ind = sub2ind([h.xdim, h.ydim, h.zdim], x,y,z);

exemplar = data(:,ind);
% average time series over pixels if we select several pixels 
% in the exemplar ROI.
fprintf('\n averaging ...\n')
exemplar = mean(exemplar,2);

F = zeros(1,size(data,2));
chi2 = zeros(1,size(data,2));

% threshold for analysis 10% of the max value in the 10th image
threshold = max(data(10,:)) *0.1
warning off
for pix=1:size(data,2)
    if data(10,pix) >= threshold
        if mod(pix,500)==0
            fprintf('\r Granger test pix: %d', pix)
        end
        tseries = data(:,pix);

        %keyboard
        [f , c] = granger(exemplar', tseries', DesMat, Nlag,  doPlots);
        F(pix) = f;
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
fprintf('\n writing results ...\n')

global SPM_scale_factor
SPM_scale_factor = 1/10;

write_hdr('grangerF.hdr',h);
write_hdr('grangerCHI2.hdr',h);
write_img('grangerF.img',F*10,h);
write_img('grangerCHI2.img',chi2*10,h);
fprintf('\n... Done\n')

return
