a = read_mat(n1, 4)
b = read_mat(n2,4)

a = a(:,1:3)
b = b(:,1:3)

dist = a - b
dist = dist.*dist
dist = (sum(dist'))'
dist = sqrt(dist)
