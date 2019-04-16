function t1_map2(root, TI, TR, NAVGS, verbose)
% function t1_map2(rootname, TI, TR,  NAVGS, verbose)
%
% Fits T1decay curve to a set of images to make a T1 map
%
% rootname:  the files must be named rootname_%04d.img and be in Analyze format
%           eg - fmri0001.img, ... fmri0006.img
% TI:   a ROW vector of inversion times.
% NAVGS:  number of images to average into each TI 
%
% generates a T1 map and an M(0) map from an 
% inversion recovery experiment using a FAIR acquisition
% sequence (alternating selective and non-selective inversion pulses)
%
% writes the files: T1.img and Mot.img

warning off
threshold = 1000; % signal intensity threshold

%%%%%%%%%
Npoints = size(TI,2);


disp('Loading data ...')

files = dir(strcat(root,'*.img'))
hfiles = dir(strcat(root,'*.hdr'));
NumFiles = size(files,1);

% determine format of files
h = read_hdr(hfiles(1).name);

    
% Allocate space for the data.  Each IR is in a row
IR_data = zeros(Npoints , h.xdim*h.ydim*h.zdim);
IR_size = size(IR_data);
IR_data_buffer = zeros(Npoints , 2);

% towi's sequence acquires them in this order:
%      NS, SS

% read the data
m=1;
for n=0: Npoints-1
   tmp = zeros(1,h.xdim*h.ydim*h.zdim);
   for k=0:NAVGS-1
       index=n*2*NAVGS +1 + 2*k ;
       fprintf('\nadding image %d to the data to point %d', index, m);
       tmp = tmp + read_img_data(h,files(index).name);
   end
   
   IR_data(m,:) = tmp/NAVGS;
   m=m+1;

end



optvar=optimset('lsqnonlin');
optvar.TolFun=1e-10;
optvar.TolX=1e-10;
optvar.MaxIter=600;
optvar.Display='off';

% look at pixels in the last image
% if their intensity is above a threshold, do the fit
for pix = 1: h.xdim*h.ydim*h.zdim
    
    IR_data_buffer(:,1) = TI';
    IR_data_buffer(:,2) = IR_data(:,pix) ;
    sz = size(IR_data_buffer);
    
    val = max(IR_data(:,pix));
    if val > threshold
        
        Mo_guess = 1.5*max(IR_data_buffer(:,2));
        T1_guess = 1.7;

        guess0 = [Mo_guess; T1_guess];
        guess_max = [20000  3];
        guess_min = [0 0];

        
        parms = lsqnonlin('IR_lsq',...
            guess0, guess_min, guess_max, ...
            optvar,...
            IR_data_buffer, TR);
        
        Mot = abs(parms(1));
        T1 = parms(2);
        
        if verbose ==1
            t = IR_data_buffer(:,1);
            M = IR_data_buffer(:,2);
            hold off
            plot (t,M, 'r*');
            M = abs( Mot * (1 - 2*exp(-t /T1) ) + exp(-2/T1) );
            hold on
            plot(t,M)
            
            fprintf('\n--------------------------')
            fprintf('\n pix= %6.2f   max val= %6.2f  M0= %6.2f  T1= %6.2f ', pix, val, Mot, T1);
            fprintf('\n ratio to initial guesses %f  %f', Mo_guess(1)/Mot , T1_guess/T1);
            fprintf('\n');
            drawnow
            %disp('Press Return to continue')
            %pause    
        end
        
        
    else
        Mot = 0;
        T1 = 0;    
        
    end
    
    T1_data(pix) = T1;
    Mot_data(pix) = Mot;
    
    
end

pFile = fopen('T1.img','wb');
fwrite(pFile, T1_data*1000, 'int16');
fclose(pFile);
write_hdr('T1.hdr',h);

pFile = fopen('Mot.img','wb');
fwrite(pFile, Mot_data, 'int16');
fclose(pFile);
write_hdr('Mot.hdr',h);


disp('Finished T1 map and Mo map')

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



















