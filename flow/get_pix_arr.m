function result = get_pix_arr( Filename, N, fmt)
% function result = get_pix_arr( Filename, N, fmt)
% opens file and extracts N pixels
% format must be specified

   pFile = fopen(Filename, 'r');
   result = fread(pFile, N , fmt);
   fclose(pFile);

return




