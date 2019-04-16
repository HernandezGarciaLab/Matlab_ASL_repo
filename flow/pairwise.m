function s2 = pairwise(signal)
% c = signal(1:2:end);
% t = signal(2:2:end);
% s2 = (c - t)';


c = signal(1:2:end);
t = signal(2:2:end);
s2 = (c - t)';
return


%%%%%%%%%%%%%%%
% some test code:

inp= eye(200);
out = zeros(200);
for c=1:200
    out(c,:) = sincsub(inp(c,:));
end