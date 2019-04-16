function spmJr (path, file, reference)
% spmJr (path, file, reference)
%
warning off

    oldpath=pwd;
    cd (path);
    
    sz = size(file);
    root = file(1,1:sz(2)-8);
    
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

    tdata=zeros(1,sz(1));   
   
    for pix=1:hdr.xdim * hdr.ydim*hdr.zdim

        for time=1:sz(1)
            
            [fp mesg]= fopen(files(time).name);
                  
            if fp == -1
                disp(mesg);
                return
            end
            
            fseek(fp,pix*bytes,'bof');     
            tdata(time) = fread(fp,1,fmt);
 
            fclose(fp);
        end
        
        corrdata(pix) = my_glm(reference,tdata',[ 1 ]);
        
    end

    outh=hdr;
    outh.datatype=16;
    
    write_hdr('Tmap.hdr',outh);
    write_img2(outh,'Tmap.img');
    
    cd(oldpath);

    
    
	return
			




