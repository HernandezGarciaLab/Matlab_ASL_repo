function out = normcenter(in)
% function out = normcenter(in)
% 
% in = in - mean(in);
% out = in/norm(in);
%
in = in - mean(in);
out = in/norm(in);

return