function svd_clean(name, Ncomps)

[a h] = read_img(name);
[u,v,w] = svd(a,'econ');
X = u(:,2:Ncomps+1);

R = a - X*pinv(X)*a;

write_img(['clean_' name], R, h);

return
