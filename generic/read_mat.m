function mat = read_mat(name, cols)

% reads in a N x cols matrix from a text file:
% usage:
% 		result_matrix = read_mat(file_name, cols)


	
   [fp mesg]= fopen(name);
   if fp == -1
      disp(mesg);
      return
   end
   
	temp = fscanf(fp,'%f');
	sz = size(temp);
	fclose (fp);

	for i=1:sz(1)/cols
		for j=1:cols
			mat(i,j) = temp((i-1)*cols+j); 
		end
	end
return;
