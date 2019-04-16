function V = makeAR1mat(rho, N)
%
% function V = makeAR1mat(rho, N)
%
% making an AR(1) cov matrix
% rho is the autocorrelation parameter
% N is the size of the data and thus the size of the cov matrix
%
a=[0:N];
coeffs = rho* ones(size(a));
aa = coeffs.^a;
aa = [aa(end:-1:2)  aa];

V = zeros(N);


for n=1:N;
    for row=1:N
        for col=1:N
            V(row, col) = aa(N + col -row +1);
         end
    end
end
%imagesc(V)
return
