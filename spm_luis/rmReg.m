function rmReg (root, allDesMat)

% rmReg (file_root, allslices_Desmats)
%
% removes known trends in time series of images.  Aimed at Physio correction
%
%   (c) 2006 Luis Hernandez-Garcia
%   University of Michigan
%   report bugs to:  hernan@umich.edu
%
% The program solves the linear model specified in DesMat for the
% parameters by ordinary least squares. It returns the residuals to a 4D image file
% called residuals.img
%
% important note.  we estimate the intercept regressor, but we do not remove it from
% the data.  The program assumes the intercept is the FIRST column in the 
% input (allDesMat).
%

all_data = read_img_series(root);
output = zeros(size(all_data));

fprintf('\n Done reading the data. crunching ...');
hnames = dir(sprintf('%s*.hdr',root));
h = read_hdr(hnames(1).name);
Spix = h.xdim *h.ydim;

% for sl=1:size(allDesMat,1)
%     fprintf('\n Estimating Beta parameters for slice %d ...',sl);
% 
%     range = [(sl-1)*Spix+1, sl*Spix]
%     DesMat = squeeze(allDesMat(sl,:,:));
%     sl_data = all_data(:,  range(1):range(2) );
%     
%     xtx_inv = pinv(DesMat);
%     beta_est = xtx_inv*sl_data;
%     output(:, range(1):range(2) ) = sl_data - DesMat(:,2:end) * beta_est(2:end,:);
% whos
% %     plot(sl_data(:,Spix/2 + 32))
% %     hold on
% %     plot(output(:,range(1) + Spix/2+32),'r')
% %     title(sprintf('varin:  %f varout = %f', ...
% %         var(sl_data(:,Spix/2+32)),var(output(:,range(1)+Spix/2+32))));
% %     hold off
% %     pause
% end

slice = 0;
pcount = inf;

for pix =1:size(all_data,2)
    %fprintf('\r Estimating Beta parameters for pix %d ...',pix);
    if pcount > Spix
        pcount=1;
        slice = slice +1;
        DesMat = squeeze(allDesMat(slice,:,:));
        xtx_inv = pinv(DesMat);
        fprintf('\r  slice %d ...',slice);
    end

    pix_data = all_data(:,  pix );
    beta_est = xtx_inv*pix_data;


    output(:, pix ) = pix_data - DesMat(:,2:end) * beta_est(2:end,:);
    pcount = pcount +1;
    %plot(pix_data)
    %     hold on
%     plot(output(:,pix),'r')
%     title(sprintf('varin:  %f varout = %f', ...
%         var(pix_data),var(output(:,pix))));
%     hold off
%     pause
    %
end

fprintf('\n Writing output residuals ...');
outh = h;
outh.tdim = size(all_data,1);


write_hdr( 'residuals.hdr', outh);
write_img( 'residuals.img', output, outh);

warning on

fprintf('\n...Done');
return





