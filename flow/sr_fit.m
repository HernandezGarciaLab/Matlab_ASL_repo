function [T1, M0]=sr_fit ( TR, Thres, filter_range, isEX)
% function [T1,  M0]=sr_fit(TR_vector, maskTh, filter_range,isEXcite)
%
% fits the parameters Mo and T1 to the function
%
%	M(t) = abs [ Mo(1-exp(-TR/T1) ) ]
%
% at each pixel in the images in the Pfiles of the current directory
% the map is thrsholded according to the last image, expressed as
%
% threshold = median(image) * maskTh
% 
if isempty(filter_range)
	doFilter=0;
else
	doFilter=1;
end
if isEX==1
	filterProg='filterrawEX';
	reconProg='gsp21a';
else
	filterProg='filterraw';
	reconProg='gsp20a';
end

fnames=dir('P*');
if 1
for count=1:length(fnames)
    
	% do the recon with field map correction
	%str = sprintf('! gsp20a -m %s', fnames(count).name)
	%eval(str)
	if (doFilter)
		str = sprintf('a = %s(''%s'' , [%s], 1,0);', filterProg, fnames(count).name, num2str(filter_range))
		eval(str)
		str = sprintf('! %s -m f_%s', reconProg, fnames(count).name)
		eval(str)
		str = sprintf('! %s -h -A f_%s', reconProg, fnames(count).name)
		eval(str)
	else
		str = sprintf('! %s -m %s', reconProg, fnames(count).name)
		eval(str)
		str = sprintf('! %s -h -A %s', reconProg, fnames(count).name)
		eval(str)
	end


    root =dir('vol*0001.img');
    root = root.name(1:end-8);

    tmp = read_img_series(root);
    h = read_hdr(sprintf('%s0001.hdr', root));
    % average the NEX (controls only)
    tmp = mean(tmp(1:2:end,:) , 1);
    
    write_hdr(sprintf('TR_%04d.hdr', count),h);
    write_img(sprintf('TR_%04d.img', count), tmp, h);
    
    
end
end
!rm vol*'

h = read_hdr('TR_0001.hdr');
data = read_img_series('TR_');
tmp = data(end,:);
Thres = median(tmp) * Thres
M0 = zeros(size(tmp));
T1 = zeros(size(tmp));

fprintf('\n\n');
TR = reshape(TR,length(TR),1);

optvar = optimset('lsqnonlin');
optvar.Display='off';

for pix=1:size(data,2)
    
    if tmp(pix)>Thres    
        fprintf('\rfitting ... %d of %d ', pix , size(data,2)); 

        Mo_guess = 1.2*data(end, pix);
        T1_guess = 1;
        
        LB = [100, 0.5]; 
        UB = [10e8, 3];
        
        guess0 = [Mo_guess; T1_guess];
        guess = lsqnonlin('sr_lsq', ...
            guess0, LB, UB, ...
            optvar, ...
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
