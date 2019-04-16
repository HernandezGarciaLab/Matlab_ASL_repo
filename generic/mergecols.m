function mergecols(n1,cols1 n2, cols2,  outname)
%     mergecols(n1,cols1 n2, cols2,  outname)
%
% Luis Hernandez
% last edit 1-14-97
%
% adds columns of data in n2 to columns of data in n1 and writes outname

             d1 = read_mat(n1, cols1);
             d2 = read_mat(n2, cols2);

             od = [d1 d2];

            write_mat(od, outname);

return
