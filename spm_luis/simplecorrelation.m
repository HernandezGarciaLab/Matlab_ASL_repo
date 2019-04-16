function simplecorrelation (root, reference)

% function simplecorrelation (root, reference)


if isstr(root)
	all_data = read_img_series(root);

	fprintf('\n Done reading the data. crunching ...');
	hnames = dir(sprintf('%s*.hdr',root));
	h = read_hdr(hnames(1).name);
else
	all_data=root;
end


rmap = zeros( 1, size(all_data, 2));

rmap(find(isnan(rmap)))=0;
rmap(find(isinf(rmap)))=0;

for p=1: size(rmap,2);
    [r, pval] = corrcoef(all_data(:,p), reference);
    rmap(p) = r(2,1);
end

fprintf('\n Writing output files (Rmap) ...');

    % make sure that we write stats maps as floats.
    outh = h;
    outh.tdim = 1;
    outh.datatype=16;
    outh.bits = 32;
    outh.glmax = max(rmap);
    outh.glmin = min(rmap);

    write_hdr( 'Rmap.hdr', outh);
    write_img_data('Rmap.img', rmap, outh);


fprintf('\n...Done');
return





