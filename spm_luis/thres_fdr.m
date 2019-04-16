function result = thres_fdr(rootname, FDR_level, df)
%function result = thres_fdr(rootname, FDR_level, deg_of_freedom)
% this function takes an image of T values and finds 
% the T threshold according to FDR theory.
% In the process, it writes an image of FDR corrected p values.
%

    % read the t img
    inname = sprintf('%s.hdr',rootname);
    hdr = read_hdr(inname);
    inname = sprintf('%s.img',rootname);
    Timg = read_img_data(hdr, inname);
    
    Timg(~isfinite(Timg(:))) = [];
    
    P        = 1-cdf('T',Timg(:),df);
    
    [pID pN] = FDR(P, FDR_level);
    
    tID      = icdf('T',1-pID,df)     % T threshold
    tN       = icdf('T',1-pN,df)      % T threshold, no correl. assumptions
    
    result = tID;
    
    
    
    outname = sprintf('p_%s.img',rootname);
    write_img_data(outname, P , hdr);
    
    outname = sprintf('p_%s.hdr',rootname);
    write_hdr(outname, hdr);
    
	if isempty(tID)
		tID=1000;
	end
	
	th=Timg;
	th( find(Timg< tID) ) = 0;
	outname = sprintf('thres_%s.img',rootname);
	write_img_data(outname,th,hdr);
	
	outname = sprintf('thres_%s.hdr',rootname);
	write_hdr(outname,hdr);
	
return
