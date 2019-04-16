function nex(ListFile,NEX,NumScans,dim, type,opuser2)
% function nex(ListFile,NEX, NumScans,dim, type, opuser2)
%
% This function reads the filenames from a file and averages the 
% contents of the files together.
%
% ListFile	- name of the file containing the listing of the 
%			files to be averaged.  This file was made with 
%			ls -1 P????? > listfile.txt
% NEX	 		- the number of image _PAIRS_ to be averaged %
% 			(eg- if running opsuer1 = 1, NEX = opfphases/2
%			beware that the first pair is discarded)
% NumScans	- number of time points on the curve
% dim			- the dimensions of the images (assume square)
% type			- magnitude 'M' or complex 'X'
% opuser1		- this is a variable from the sprt sequence.
%			when its value is 1, each P file contains a group 
%			of scans to be averaged together in pairs
%			when it is 2, each P file contains a set of of TI values

if opuser2==1
   disp('op1');
   op1(ListFile,NEX,NumScans,dim, type);
end

if opuser2==2
   disp('op2')
   op2(ListFile,NEX,NumScans,dim, type);
end

return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function op1(ListFile,NEX,NumScans,dim, type)

pFile = fopen(ListFile,'r');
odd=0;

for i=0:NumScans*2 -1
   
   % Allocate space for the data and zero the buffers
   if(strcmp(type,'M'))
      disp('The input data are magnitude images')
      data=zeros(1,dim*dim);
   else if (strcmp(type,'X'))
         disp('The input data are complex images')
         data=zeros(1,2*dim*dim);
         mdata = zeros(1,dim*dim);
      end
   end
   
   
   
   % Read in the file names from the listing of Pfiles 
   % determine the name of the appropriate file
   
  
   if ~odd
      % read a new file name only for the even images.
      % if they are odd, use the last filename
      BaseNameString = fgetl(pFile);
   end
   disp(strcat('reading ...',BaseNameString));
   
   % skip the first pair of images, since they are used only
   % to calculate the field and their scale is incorrect
   for j=2:2:(NEX*2-1)
      
      if odd
         j=j+1;
      end
      
         % determine the suffix that gets appended to the particular P-file
         % by the reconstruction program (spirec)
         suffix =strcat('.',type,'_000D0');
         if (j)<10
            suffix = strcat(suffix ,'0');
         end
         suffix = strcat(suffix ,num2str(j));
         
         NameString = strcat(BaseNameString,suffix);
         disp(strcat('adding ... ',NameString));

   
      % Read the file and add it to the buffer.
      
      if (strcmp(type,'M'))
         
         buffer= get_pix_arr(NameString,dim*dim, 'int16')';
         data = data + buffer;
         
      else if (strcmp(type,'X'))
            
            buffer= get_pix_arr(NameString, 2*dim*dim, 'float32')';
            data = data + buffer;

            % IF the images are complex we want to
            % create magnitude images for display purposes
            % of all the individual images
            
            disp(strcat('Creating magnitude image ... M', NameString))
            pOut = fopen(strcat('M',NameString),'w');
            for k=2:2:dim*dim*2 -1
               mdata(k/2) = sqrt(buffer(k)^2 + buffer(k+1)^2 );
            end
            fwrite(pOut,mdata,'int16');
            fclose(pOut);
            
            
            %%%%%%%%%%%%%%%%%

         end
      end
            
         
      
   end %NEX Loop
   
      
   
      
   % Divide by the NEX and write the output files
   % determine the output format
   
   data=data/(NEX-1);
      
   %determine the name for the average image
      
   if (i)<10
      suffix = strcat('0',num2str(i));   
   else
      suffix=num2str(i);
   end
   
   
   if (strcmp(type,'M'))
      
      disp(strcat('writing ... M_av',suffix));
      
      pOut = fopen(strcat(type,'_av',suffix),'w');
      fwrite(pOut,data ,'int16');
      fclose(pOut);
      
   else if (strcmp(type,'X'))
         disp(strcat('writing ... X_av',suffix));
         
         pOut = fopen(strcat('X_av',suffix),'w');
	      fwrite(pOut,data,'float32');
         fclose(pOut);
                  
         % Creating a magnitude image of the average
         for k=2:2:dim*dim*2 -1
            mdata(k/2) = sqrt(data(k)^2 + data(k+1)^2 );
         end
         
         disp(strcat('writing ... MX_av',suffix));
         pOut = fopen(strcat('MX_av',suffix),'w');
         fwrite(pOut,mdata,'int16');
         fclose(pOut);
         
      end
   end
   
   odd = ~odd;
   %disp('press enter to continue averaging')
   %pause
end % NumScans loop
fclose(pFile);

return



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function op2(ListFile,NEX,NumScans,dim, type)



for i=0:NumScans -1
   
   % Allocate space for the data and zero the buffers
   if(strcmp(type,'M'))
      disp('The input data are magnitude images')
      data=zeros(1,dim*dim);
   else if (strcmp(type,'X'))
         disp('The input data are complex images')
         data=zeros(1,2*dim*dim);
         mdata = zeros(1,dim*dim);
      end
   end
   
   
   
   % Read in the file names from the listing of Pfiles 
   % determine the name of the appropriate file
   pFile = fopen(ListFile,'r');
   
   start=1;
   if opuser2 == 1
      BaseNameString = fgetl(pFile);
      start=2;
   end
   
   for j=1:NEX
      
      if (opuser2==1) & (j*2 <= NEX)
         
         % determine the suffix that gets appended to the particular P-file
         % by the reconstruction program (spirec)
         suffix =strcat('.',type,'_000D0');
         
         if (2*j)<10
            suffix = strcat(suffix ,'0');
         end
         
         suffix = strcat(suffix ,num2str(2*j));
         NameString = strcat(BaseNameString,suffix);
         
      end

      
      if opuser2==2
         
         BaseNameString = fgetl(pFile);
         % determine the suffix that gets appended to the particular P-file
         % by the reconstruction program (spirec)
         suffix =strcat('.',type,'_000D0');
         
         if (i)<10
            suffix = strcat(suffix ,'0');
         end
         
         suffix = strcat(suffix ,num2str(i));
         NameString = strcat(BaseNameString,suffix);
         
      end
      
       
   
      % Read the files and add them together.
      if (strcmp(type,'M'))
         
         buffer= get_pix_arr(NameString,dim*dim, 'int16')';
         test(j)=sum(buffer);
         data = data + buffer;
         disp(strcat('adding ... ',NameString));
         
      else if (strcmp(type,'X'))
            buffer= get_pix_arr(NameString, 2*dim*dim, 'float32')';
            test(j)=sum(buffer);
            data = data + buffer;
            disp(strcat('adding ... ',NameString));

            
            % create magnitude images for display purposes
            % of all the individual images
            for k=2:2:dim*dim*2 -1
               mdata(k/2) = sqrt(buffer(k)^2 + buffer(k+1)^2 );
            end
            disp(strcat('writing ... M', NameString))
            pOut = fopen(strcat('M',NameString),'w');
            fwrite(pOut,mdata,'int16');
            fclose(pOut);
            %%%%%%%%%%%%%%%%%

         end
      end
            
         
      
   end %NEX Loop
   
   fclose(pFile);
   
   
   % Divide by the NEX and write the output files
   % determine the output format
   
   if (strcmp(type,'M'))
      fmt='int16';
      pOut = fopen(strcat(type,'_av',suffix(8:10)),'w');
      fwrite(pOut,data/NEX,fmt);
      fclose(pOut);

   else if (strcmp(type,'X'))
         fmt='float32';
         pOut = fopen(strcat(type,'_av',suffix(8:10)),'w');
	      fwrite(pOut,data/NEX,fmt);
         fclose(pOut);
         
         % Creating a magnitude image of the average
         for k=2:2:dim*dim*2 -1
            mdata(k/2) = sqrt(data(k)^2 + data(k+1)^2 );
         end
         
         disp(strcat('writing ... MX_av',suffix(8:10)));
         pOut = fopen(strcat('MX_av',suffix(8:10)),'w');
         fwrite(pOut,mdata/NEX,'int16');
         fclose(pOut);
         
      end
   end
   
   
   
end % NumScans loop

save test

return



















