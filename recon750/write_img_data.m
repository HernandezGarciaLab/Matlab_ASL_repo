function  write_img_data(name, data, hdr)

% Luis hernandez
% last edit 4-6-98
%
% function  write_img_data(name, data, hdr)
%
% Writes the data to an analyze format file 'name' containing mutislice image data 
%
%
% (c) 2005 Luis Hernandez-Garcia 
% University of Michigan
% report bugs to:  hernan@umich.edu
%

% $Id: write_img_data.m 1279 2014-03-24 20:06:25Z klitinas $
% $HeadURL: svn+ssh://klitinas@anger.engin.umich.edu/svn/matlab/img/trunk/write_img_data.m $


   [pFile,messg] = fopen(name, 'wb');
   if pFile == -1
      errormesg(messg);   
      return;
   end
   
      
   switch hdr.datatype     
   case 2
      fmt = 'char';
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

   
   fwrite(pFile, data, fmt);
   fclose(pFile);
   
   
 return

