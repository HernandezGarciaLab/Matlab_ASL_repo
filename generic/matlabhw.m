% Problem 1
load SPM_fMRIDesMtx
r1 =xX.X(:,1); 
....
   ....
   ....
   

plot(r1,'r');
hold on
plot( ... );
plot(... );
hold off


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Problem 2

% Our resolution will be 100 points per second.
points = 100;

% create a set of stimuli occurring at random times 
% in the time series
stim=zeros(100*points,1);
....
stim( .... ) =1;

subplot 312, plot(stim),title('A set of stimuli at randomized times')

% create the HRF using SPM's function
hrf = spm_hrf( ... );
subplot 311, plot(hrf),title('Response to a single stimulus')

% convolve the input and the HRF and clip out the end (empty)
resp=conv( .... );
resp = resp(1:size(stim));
subplot 313, plot(resp),title('Predicted Response to the stimuli')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Problem 3

function array = read_img(hdr, name)

% image_data = read_img(hdr, name)
%
% Luis hernandez
% last edit 6-29-2000
%
% Loads the data from an analyze format file 'name' containing mutislice image data
% 		hdr: is a header structure (use read_hdr())
% 		name:  file name (.img)
% The function returns a three dimensional array 


   [pFile,messg] = fopen(name, 'r');
   if pFile == -1
      disp(messg);   
      return;
   end
   

% figure out the format of the data file from the header.
% only three types are supported by this function right now ...
switch hdr.datatype     
   case 0
      fmt = 'int8';
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
      xdim = hdr.xdim * 2;
      ydim = hdr.ydim * 2;

   otherwise
         errormesg(sprintf('Data Type %d Unsupported. Aborting',hdr.datatype));
         return
end

	   
   
% Create a 3D array with the data ...
for i=1:hdr.zdim
   % read one plane at a time (Matlab won't let you read a 3D
   % matrix in one shot, but you can read a 2D one, though
   a  = fread( ... ) ;
      
   % append the new plane to existing matrix
	array ( .... ) = a;	
end

fclose(pFile);
   
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Problem 3B

function result = ortho(root, x, y, z)
% function result = ortho(root, x, y, z)
%
% this function thakes a file in analyze format and 
% displays orthogonal sections thru the planes interscting
% at x,y,z

	%figure out the whole name of the header and image files
	% and read them.  Note the use of strcat
	 h = read_hdr(strcat(root,'.hdr'));
    d = read_img2(h, (strcat(root,'.img') ));

    colormap(gray)
    
    % display the orthogonal sections
    subplot 221, imagesc(squeeze(d(:,:,z)))
    subplot 222, imagesc(squeeze(d(:,y,:))')
    subplot 223, imagesc(squeeze(d(x,:,:))')

    
return


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Problem 4

function ts = timeseries(root, start, finish, x, y, z )
% function ts = timeseries(root, start, finish, x, y, z )
%
% This function extracts the data from a time series by
% reading in the entire file at first, and then extracting the
% desired voxel from the images.
%
% Note that this is NOT an efficient way to do it, but it is a good exercise
% Extra Credit if you write a more efficient way to do it.

	% allocate some space for the resulting variable and initialize a counter
	ts = zeros(finish - start , 1);
   t = 1;
   
   for i=start:finish
   
   	%figure out the names of the files   
      hstring = sprintf( .... );
      istring = sprintf( .... );
   
   	% extract the data from the files
      hdr = .... 
      img =  read_img( .... );
      
   	% extract the voxel    
   	ts(t) = img( ... );
   	t =  .... ;
      
   end

return