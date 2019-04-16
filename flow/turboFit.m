function [f, Ttrans]=turboFit ( tr_vec, Thres, dist, alpha, root)
%function [f, Ttrans]=turboFit ( tr_vec, Thres, dist, alpha, root)

fprintf('\nExecuting turboFit (fit to the TurboCASL model)...');

warning off
Verbose=0;
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
del = 0.02;	 %seconds
crushers=1;
R1t = 1/1.2;    % 1/sec.
R1a = 1/1.6;    % 1/sec

fprintf('Reading M0 and T1 images')
M0 = read_img('M0');
T1 = read_img('T1');
T1 = T1/1000;
Thres = max(M0)* 0.2;

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
	del = (sl-1)*0.05;

	R1t = 1/T1(pix);
	consts = [R1a R1t alpha del M0(pix)];

        f_guess = 0.015;   %units are ml/s/g
        [val ind] = min(turbo);
	Ttrans_guess = tr_vec(ind)+ 0.2;
        
        %LB = [ Ttrans_guess- 0.5     0.0002]; 
        %UB = [ Ttrans_guess + 0.5     0.03];
	LB = [0.5 0.0015];
	UB = [2.2 0.04];
        guess0 = [Ttrans_guess f_guess];
        guess = lsqnonlin(@turbo_lsq, guess0, LB, UB, optvar,tr_vec,consts,turbo);
        
        Ttrans(pix) = guess(1);
        f(pix) = guess(2);
        if Verbose==1
	    fprintf('\rfitting ...pix %d of %d ...sl=%d - f^= %f Ttrans^= %f - guessed: %f %f',...
                         pix , size(data,2),sl, f(pix), Ttrans(pix), f_guess, Ttrans_guess);
	
	    if rem(pix,32)== 0
		subplot(211)
		plot(tr_vec,data(:,pix),'*')
		hold on
		plot(tr_vec, turbo_lsq(guess,tr_vec,consts));
	    	str = sprintf('sl=%d - f^= %f Ttrans^= %f  ',...
                         sl, f(pix), Ttrans(pix) );
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

