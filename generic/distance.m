function dist = distance(n1,n2)

%function dist = distance(n1,n2)
%
% Luis Hernandez
% last edit 2-17-98
%
% dist is a column of distances.
% n1 and n2 are the filenames of the matrices containing the sets of points.
% 


a = read_mat(n1, 4)
b = read_mat(n2,4)

a = a(:,1:3)
b = b(:,1:3)

dist = a - b
dist = dist.*dist
dist = (sum(dist'))'
dist = sqrt(dist)


return