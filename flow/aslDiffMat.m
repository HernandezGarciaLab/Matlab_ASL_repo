function aslDiffMat(root, Dtype);

[raw h] = read_img_series(root);

% Make the differencing matrices
tlen = h.tdim;

switch Dtype

    case 'none'
        D= eye(tlen);
    case 'pairwise'

        D = zeros(tlen/2,tlen);
        for count=1:tlen/2
            D(count,count*2-1)=1;
            D(count,count*2)=-1;
        end
        h.tdim = tlen/2;

    case 'running'
        D = zeros(tlen-1,tlen);
        for count=1:tlen-1
            D(count,count)=(-1)^(count-1);
            D(count,count+1)=(-1)^(count);
        end
        h.tdim = tlen-1;

    case 'surround'
        D = zeros(tlen-2,tlen);
        for count=1:tlen-2
            D(count,count)=(-1)^(count-1);
            D(count,count+1)=2*(-1)^(count);
            D(count,count+2)=(-1)^(count-1);
        end
        h.tdim = tlen-2;

end

out = D*raw;

write_img(['sub_' Dtype '.img'] , out, h)
save DiffMat.dat D -ascii