function imgvar(pathstr,filestr) 
% function imgvar(pathstring,filestring) 

    oldpath=pwd;
	cd (pathstr);
    
    sz = size(filestr);
	root = filestr(1,1:sz(2)-7);
     
	files = dir(strcat(root,'*.img'));
	hfiles = dir(strcat(root,'*.hdr'));
	nimgs = size(files,1);
	hfiles(1).name;
	hdr = read_hdr(hfiles(1).name);

    switch hdr.datatype     
    case 0
        fmt = 'int8';
        bytes = 1;mnj

        
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
    
    imgsz = hdr.zdim * hdr.xdim *hdr.ydim;
    varimg= zeros(imgsz,1);
    meanimg = zeros(imgsz,1);
    
    % compute the means image
    for m=1:nimgs;
        fprintf('\rAdding ...%s... to the mean',files(m).name);
        [fp mesg]= fopen(files(m).name);
        if fp == -1
            disp(mesg);
            return
        end
        
        tmp = fread(fp,[imgsz 1],fmt);
        meanimg = meanimg + tmp;
        fclose(fp);
        
    end
    meanimg = meanimg/nimgs;
    
    %Now do the variance:
     for m=1:nimgs;
        fprintf('\rAdding ...%s... to the variance',files(m).name);
        [fp mesg]= fopen(files(m).name);
        if fp == -1
            disp(mesg);
            return
        end
        
        tmp = fread(fp,[imgsz 1],fmt);
        varimg = varimg + sqrt( (meanimg - tmp).*(meanimg-tmp));
        fclose(fp);
        
    end
    varimg = varimg/(nimgs-1);
    
    write_hdr('var.hdr',hdr);
    write_img_data('var.img',varimg,hdr);
    
    write_hdr('mean.hdr',hdr);
    write_img_data('mean.img',meanimg,hdr);
    
return
    