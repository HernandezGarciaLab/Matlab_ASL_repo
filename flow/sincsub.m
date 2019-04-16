function s2 = sincsub(signal)
% function s2 = sincsub(signal)
%
% n = 1:length(signal);
% 
% c = signal(1:2:end);
% nc = n(1:2:end);
% t = signal(2:2:end);
% nt = n(2:2:end);
% 
% c = interp1(nc, c, n,'sinc');
% t = interp1(nt, t, n,'sinc');
% s2 = (c - t)';
% return


n = 1:length(signal);

c = signal(1:2:end);
nc = n(1:2:end);
t = signal(2:2:end);
nt = n(2:2:end);

c = interp1(nc, c, n,'sinc');
t = interp1(nt, t, n,'sinc');
s2 = (c - t)';
return


%%%%%%%%%%%%%%%
% some test code:

inp= eye(200);
out = zeros(200);
for c=1:200
    out(c,:) = sincsub(inp(c,:));
end