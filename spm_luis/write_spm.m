function write_spm(name)
% write_spm(name)
%
% Takes XYZ.mat, SPMt.mat, SPMF.mat files and creates
% name_spmt.txt and name_spmf.txt
% 
	load XYZ
	pix = XYZ_conv(XYZ)
	write_mat(pix,'xyz.txt')
	
	load SPMt
	write_mat(SPMt','SPMt.txt')
	
	load SPMF
	write_mat(SPMF','spmf.txt')

	write_mat( [pix SPMt'],   strcat(name, '_spmt.txt') );
	write_mat( [pix SPMF'],   strcat(name, '_spmf.txt') );

return