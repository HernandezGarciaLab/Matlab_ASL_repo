function [h_est] = dec_glm(data, stim)
%dec_glm.m
% deconvolution via general linear model

rev_stim = stim(end:-1:1); 
len = length(data); 
m = length(stim); 
n = len + 1 - m; 
stim_matrix = zeros(len, len); 
for ind_row = 1:len
    stim_matrix(ind_row, ind_row:(ind_row+m-1)) = rev_stim;  
end
stim_matrix = stim_matrix(:,m:len);
% data = data + 100;
% x = zeros(size(data,1)+length, length);
% for count=1:length
% 	x(onsets+count, count) = 1;
% end
% x = x(1:size(data,1) , 1:end);
% x = [x ones(size(data,1),1)];
% figure(100); imagesc(x);

st = stim_matrix; 
h_est = pinv(st'*st) * st' * data'; 
h_est = h_est'; 

return
