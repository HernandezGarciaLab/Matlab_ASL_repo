function [T1, M0]=IR_fit (TI, TR, Thres, reconFlag)
% function [T1,  M0]=IR_fit(TI_vector, TR, maskTh, doRecon)
%
% fits the parameters Mo and T1 to the function
%
%	M(t) = abs [ Mo(1-2exp(-t/T1) + exp(-TR/T1) ) ]
%
% at each pixel in the images in the Pfiles of the current directory
% the map is thrsholded according to the last image, expressed as
%
% threshold = median(image) * maskTh
% 

warning off
switch reconFlag
   case 0
   reconVersion='';
   case 1
   reconVersion='gsp20a';
   case 2
   reconVersion='gsp21a';
end


if reconFlag~=0
fnames=dir('P*');
for count=1:length(fnames)
    
	% do the recon with field map correction
	str = sprintf('! %s -m %s', reconVersion, fnames(count).name)
	eval(str)
	str = sprintf('! %s -h -A %s', reconVersion, fnames(count).name)
	eval(str)

    root =dir('vol*0001.img');
    root = root.name(1:end-4);

    tmp = read_img_series(root);
    h = read_hdr(sprintf('%s.hdr', root));
    % average the NEX
    tmp = mean(tmp,1);
    
    write_hdr(sprintf('TI_%04d.hdr', count),h);
    write_img(sprintf('TI_%04d.img', count), tmp, h);
    
    
end
end
!rm vol*'
Thres = median(tmp) * Thres

data = read_img_series('TI_');
M0 = zeros(size(tmp));
T1 = zeros(size(tmp));

fprintf('\n\n');
TI = reshape(TI,length(TI),1);

for pix=1:size(data,2)
    
    if tmp(pix)>Thres    
        fprintf('\rfitting ... %d of %d ', pix , size(data,2)); 

        Mo_guess = 1.2*data(end, pix);
        T1_guess = 1;
        
        LB = [100, 0.5]; 
        UB = [10e8, 3];
        
        guess0 = [Mo_guess; T1_guess];
        guess = lsqnonlin('ir_lsq', ...
            guess0, LB, UB, ...
            [],...
            TI, ...
            TR, ...
            data(:,pix));
        
        M0(pix) = guess(1);
        T1(pix) = guess(2);
    else
        M0(pix) = 0;
        T1(pix) = 0;
    end
        
end

write_hdr('M0.hdr',h);
write_hdr('T1.hdr',h);
write_img('M0.img', M0, h);
write_img('T1.img', T1*1000, h);

return
