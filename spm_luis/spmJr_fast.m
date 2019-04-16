function spmJr (root, DesMat, contrast)

% spmJr (path, file_root, Desmat)
%
%   (c) 2006 Luis Hernandez-Garcia 
%   University of Michigan
%   report bugs to:  hernan@umich.edu

all_data = read_img_series(root);

fprintf('\n Done reading the data. crunching ...');
hnames = dir(sprintf('%s*.hdr',root));
h = read_hdr(hnames(1).name);

Ncon = size(contrast,1);

tmap = zeros( Ncon, size(all_data, 2));
vCon = zeros( Ncon, size(all_data, 2));
Tol = 10^(-16);
df = size(all_data,1) - size(DesMat,2)+1;

warning off

fprintf('\n Estimating Beta parameters and variance ...');

xtx_inv = pinv(DesMat);
beta_est = xtx_inv*all_data;
V = var(all_data, 0, 1);

for n=1:size(contrast,1)
    fprintf('\n Contrast n. %d ...',n);

    for pix=1:size(all_data,2)
        vCon(n,pix) = contrast(n,:) * xtx_inv * V(pix) * xtx_inv' * contrast(n,:)';

    end
    
    tmap(n,:) = (beta_est' * contrast(n,:)') ./ sqrt(vCon(n,:))';
end



tmap(find(isnan(tmap)))=0;
tmap(find(isinf(tmap)))=0;
zmap = tmap;
zmap = spm_t2z(tmap(:),df);
zmap = reshape(zmap,Ncon, size(all_data, 2));

fprintf('\n Writing output files (Tmap, Zmap) ...');

for n=1:Ncon
    % make sure that we write stats maps as floats.
    outh = h;
    outh.datatype=16;
    outh.bits = 32;
    outh.glmax = max(tmap(:));
    outh.glmin = min(tmap(:));

    write_hdr( sprintf('Tmap_%04d.hdr', n), outh);
    write_img_data( sprintf('Tmap_%04d.img',n), tmap(n,:), outh);

    outh.glmax = max(zmap(:));
    outh.glmin = min(zmap(:));
    write_hdr( sprintf('Zmap_%04d.hdr',n), outh);
    write_img_data( sprintf('Zmap_%04d.img',n), zmap(n,:), outh);
    warning on
end
fprintf('\n...Done');
return





