function [f, Ttrans]=turboFit02 ( tr_vec, Thres, alpha, root)
%function [f, Ttrans]=turboFit03 ( tr_vec, Thres,  alpha, root)
%
% Fits transit times anf flow values to Turbo series ASL data
% this version uses the analytical solution for the Turbo curve.
%
% tr_vec = vector containng the TRs for the TurboCurve 
% Thres = We only process the data whose M0 value is above this threshold.  
%       we expreses it as a fraction of the maximum M0 value (eg -= 0.2)
% alpha = yes, exaacly what you think it is. (a good guess = 0.85)
% root = the root name of the _subtracted_ images in the turbo series 
%       (do aslsub( ) first!)
%
% The script assumes you have already generated T1 and M0 maps (use sr_fit
% first.
%

fprintf('\nExecuting turboFit (fit to the TurboCASL model)...');

warning off
Verbose=1;
% smoother('sTR',[5 5 8]);

% read in the subtraction images
hnames = dir(sprintf('%s*.hdr',root));
Inames = dir(sprintf('%s*.img',root));

h = read_hdr(hnames(1).name);
data = read_img_series(root);
% reverse the order of acquisition = flip sign here!!!
data=-data;
tmp = data(end,:);
dims = [h.xdim, h.ydim, h.zdim];

f = zeros(size(tmp));
Ttrans = zeros(size(tmp));

fprintf('\n\n');
tr_vec = reshape(tr_vec,length(tr_vec),1);

%defaults
Ttag =tr_vec-0.2;  % seconds
del = 0.05;	 %seconds
crushers=1;
R1t = 1/1.2;    % 1/sec.
R1a = 1/1.6;    % 1/sec
Taq = 0.4;  % (sec) time to acquire all the slices

fprintf('Reading M0 and T1 images')
M0 = read_img('M0');
T1 = read_img('T1');
T1 = T1/1000;
Thres = max(M0)* Thres

optvar = optimset('lsqnonlin');
optvar.Display='off';
optvar.TolFun = 1e-15;
optvar.TolX = 1e-10;
optvar.MaxIter = 10;
optvar.Diagnostics = 'off';
optvar.DiffMinChange = 1.0e-6;

T1disp = reshape(T1,dims(1), dims(2), dims(3));
fprintf('\nBegin Fitting voxels to turboModel ...');
for pix=1:size(data,2)

    if M0(pix)>Thres

        turbo=data(:, pix);

        [x y sl] = ind2sub(dims,pix);
        del = (sl-1)*0.045;

        %R1t = 1/T1(pix);
        consts = [R1a R1t alpha del M0(pix) Taq];

        f_guess = 0.015;   %units are ml/s/g
        [val ind] = min(turbo);
        Ttrans_guess = tr_vec(ind)+ 0.2;
        Beta_guess = 0.02;

        LB = [0.2 0.0015 0.04 ];
        UB = [2.2 0.04 0.05];
        guess0 = [Ttrans_guess f_guess Beta_guess];
        guess = lsqnonlin(@turbo_lsq02, guess0, LB, UB, optvar,tr_vec,consts,turbo);

        Ttrans(pix) = guess(1);
        f(pix) = guess(2);
        Beta(pix) = guess(3);

        if Verbose==0 & rem(pix,1000)== 0
            str = sprintf('sl=%d - f^= %f Ttrans^= %f Beta^= %f ',...
                sl, f(pix), Ttrans(pix) , Beta(pix));
        end

        if Verbose==1
            fprintf('\rsl=%d - f^= %f Ttrans^= %f Beta^= %f ',...
                sl, f(pix), Ttrans(pix) , Beta(pix));
       
            if rem(pix,32)== 0
                subplot(211)
                plot(tr_vec,data(:,pix),'*')
                hold on
                plot(tr_vec, turbo_lsq(guess,tr_vec,consts));
                str = sprintf('sl=%d - f^= %f Ttrans^= %f Beta^= %f ',...
                     sl, f(pix), Ttrans(pix) , Beta(pix));
                title(str)
                hold off
                subplot(212)
                imagesc(squeeze(T1disp(:,:,sl))); colormap(gray)
                hold on; plot(x,y,'rx'); hold off
                drawnow
            end
        end
    else
        f(pix) = 0;
        Ttrans(pix) = 0;
        
    end

end
fprintf('\nWriting Flow ant TTrans images ...')

write_hdr('Flow.hdr',h);
write_hdr('TTrans.hdr',h);

write_img('Flow.img', f*100*6000, h); % units to ml/min/100g  *100
write_img('TTrans.img', Ttrans*1000, h);


fprintf('\n .... turboFit complete');

return

