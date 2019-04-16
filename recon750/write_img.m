function  write_img(name, data, hdr)

% Luis hernandez
% last edit 7-26-2006
%
% function  write_img(name, data, hdr)
%
% Writes the data to an analyze format file 'name' containing mutislice image data 
% this also handles a timeseries in one file (ie -each image is a row )
%
%
% (c) 2005 Luis Hernandez-Garcia 
% University of Michigan
% report bugs to:  hernan@umich.edu
%

% $Id: write_img.m 1279 2014-03-24 20:06:25Z klitinas $
% $HeadURL: svn+ssh://klitinas@anger.engin.umich.edu/svn/matlab/img/trunk/write_img.m $


   [pFile,messg] = fopen(name, 'wb');
   if pFile == -1
      errormesg(messg);   
      return;
   end
   
      
   switch hdr.datatype     
   case 2
      fmt = 'uint8';
   case 4
      fmt = 'short';
   case 8
      fmt = 'int';
   case 16
      fmt = 'float';
   case 32
      fmt = 'float';
           
   otherwise
      errormesg(sprintf('Data Type %d Unsupported. Aborting',hdr.datatype));
      return
      
   end

   
   if hdr.tdim>1
	fwrite(pFile, data', fmt);
	else
	fwrite(pFile, data, fmt);
   end

   fclose(pFile);
   
   hname = [name(1:end-4) '.hdr'];
   write_hdr(hname, hdr);   
 return

