function result = write_mat(data, name)
%       write_mat(data, name)
% Writes data to file
	[fp mesg]= fopen(name,'w');
   if fp ==-1 
      disp(mesg);
      return;
   end
   
	sz = size(data);
	for i=1:sz(1)
		for j=1:sz(2)
			fprintf(fp,'%f\t', data(i,j));
		end
		fprintf(fp,'\n');
	end

	fclose(fp);
	sprintf('Wrote: %s', name)
return
