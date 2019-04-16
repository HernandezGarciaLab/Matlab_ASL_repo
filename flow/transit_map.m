function transit_map(root, template, TI ,debug)
%function transit_map(root, template, TI ,debug)
%
% writes a transit time map based on ASL images with different 
% inversion times
%
% root - common rootname for the images eg: 'sub_'
% TI - vector of inversion times in milliseconds 
% template - name of one of the original images to mask out
%	noise outside the brain.  eg: 'vol_e101_1098_0004'  (no .img)
% show - debugging flag to indicate whether to plot pixels

%%%%%%%%%
debug=0;
threshold=100;  %(minimum signal for processing)


num_scans=max(size(TI));
    
files = dir(strcat(root,'*.img'));
if (size(files)==[0 1])
    tdata=0;
    fprintf('%s-----images not found',file);
    return;
end
    
hfiles = dir(strcat(root,'*.hdr'));
sz = size(files);
hfiles(1).name;
hdr = read_hdr(hfiles(1).name);
    
    
switch hdr.datatype     
case 0
	fmt = 'int8';
	bytes = 1;
    
case 2
	fmt = 'uint8';
	bytes = 1;
case 4
	fmt = 'short';
	bytes = 2;
case 8
	fmt = 'int';
	bytes = 2;
case 16
	fmt = 'float';
	bytes = 4;
case 32
	fmt = 'float';
	xdim = hdr.xdim * 2;
	ydim = hdr.ydim * 2;
	bytes = 8;
    
otherwise
	errormesg(sprintf('Data Type %d Unsupported. Aborting',hdr.bits));
	return
    
end

allData=[];
h2=read_hdr(sprintf('%s.hdr',template));
templ=read_img_data(h2,sprintf('%s.img', template));

% read everything into a matrix
% rows = pixels
% columns = time

for time=1:sz(1)
	fprintf('\r reading  ...%s', files(time).name);  
	allData=[allData; read_img_data(hdr,files(time).name) ];   
end;

fprintf('\n crunching ...'); 
opts=optimset('lsqcurvefit');
opts.Display='off';
opts.TolX=1.0e-5;

transit=[];
%keyboard
for pix=1:hdr.xdim*hdr.ydim*hdr.zdim
	% parameters in kinetics function
	% parms=[to , k , Mss];
	to=500;
	k=1/800;
	Mss = templ(pix);
	guess0 = [to, k, Mss];

	LBound=[500 , 1/1200, templ(pix)*0.01];
	UBound=[2200 ,1/500, templ(pix)*0.5]; 
	
	d=abs(allData(:,pix));

	if (templ(pix)>= threshold)
		guess = lsqcurvefit(@washIn, ...
				guess0',...
				TI,...
				d', ...
				LBound, UBound, ...
				opts); 
		tmp=guess(1);
		if(debug==1)
			plot(TI, d ,'*');
			hold on, plot(TI,washIn(guess,TI))
			hold off
			drawnow
		end
	
	else
		tmp=0;
	end

	transit=[transit; tmp];

end

write_hdr('transit.hdr',hdr);
write_img_data('transit.img', transit, hdr);
return

