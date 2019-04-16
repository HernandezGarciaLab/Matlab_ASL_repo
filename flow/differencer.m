function [outdata, D] = differencer(indata, option)
% function [outdata, D] = differencer(indata, option)
%
% does the differencing of ASL data using the differencing matrix of choice
% Make sure that time is in the rows dimension!
%
% option 1:  do nothing
% option 2:  pairwise differencing
% option 3:  running subtraction
% option 4:  surround subtraction
%
% the function returnd the dirrenced data and the differencing matrix used
% assumes order: control-tag

% differencing matrices

tlen = size(indata,1);

switch option
    case 1
        D = eye(tlen);
    case 2
        D = zeros(tlen/2,tlen);
        for count=1:tlen/2
            D(count,count*2-1)=1;
            D(count,count*2)=-1;
		end
		D = D;
    case 3
        D = zeros(tlen-1);
        for count=1:tlen-1
            D(count,count)=(-1)^(count-1);
            D(count,count+1)=(-1)^(count);
		end
		D = D;
    case 4
        D = zeros(tlen-2);
        for count=1:tlen-2
            D(count,count)=(-1)^(count-1);
            D(count,count+1)=2*(-1)^(count);
            D(count,count+2)=(-1)^(count-1);
		end
		D = D/2;
end

%imagesc(D)
outdata = D*indata;

return
