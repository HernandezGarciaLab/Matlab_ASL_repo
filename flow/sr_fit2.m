function [T1, M0]=sr_fit2 ( TR, Thres, root)
% function [T1,  M0]=sr_fit2(TR_vector, maskTh, root)
%
% fits the parameters Mo and T1 to the function
%
%	M(t) = abs [ Mo(1-exp(-TR/T1) ) ]
%
% at each pixel in the images in the files that match "root"
% the map is thrsholded according to the last image, expressed as
%
% threshold = median(image) * maskTh
%
% This VERSION DOES NOT DO THE RECON
%

doFigs = 0;

fprintf('\nExecuting sr_fit2 (saturation-recovery fit) ...');
%h = read_hdr(sprintf('%s0001.hdr', root));
h = read_hdr(root);
%data = read_img_series(root);
data = read_img(root);
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
        %fprintf('\rfitting ... %d of %d ', pix , size(data,2));

        Mo_guess = 1.2*data(end, pix);
        T1_guess = 1;
        FlipFactor_guess = 1;

        LB = [100, 0.5 0 ];
        UB = [10e8, 3  2];

        guess0 = [Mo_guess; T1_guess; FlipFactor_guess];
        guess = lsqnonlin('sr_lsq', ...
            guess0, LB, UB, ...
            optvar, ...
            TR, ...
            data(:,pix));

        M0(pix) = guess(1);
        T1(pix) = guess(2);
        FlipFactor(pix) = guess(3);
        if mod(pix,1000)==0
            fprintf('\rProgress:... %0.2f percent', 100*pix/size(data,2));
        end
        if doFigs
            plot(TR,data(:,pix),'o')
            hold on
            plot(TR, M0(pix)*(1-FlipFactor(pix)*exp(-TR / T1(pix))));
            title(sprintf('M0: %0.2f T1: %0.2f  FA: %0.2f', M0(pix), T1(pix), FlipFactor(pix)));
            drawnow
            hold off
        end
    else
        M0(pix) = 0;
        T1(pix) = 0;
        FlipFactor(pix) = 0;
    end

end



write_hdr('M0.hdr',h);
write_hdr('T1.hdr',h);
write_img('M0.img', M0, h);
write_img('T1.img', T1*1000, h);
write_hdr('FlipF.hdr',h);
write_img('FlipF.img', FlipFactor*1000, h);
fprintf('\n ... sr_fit2 (saturation-recovery fit) done');

return
