function t1_map(BNameString, xdim, ydim,  NumScans, TI_range,show)
% function t1_map(BNameString, xdim, ydim,  NumScans, TI_range,show)
% Fit T1decay curve
% generates a T1 map and an M(0) map from an 
% inversion recovery experiment using a FAIR acquisition
% sequence (alternating selective and non-selective inversion pulses)
% writes the files: T1.img and Mot.img

%%  Assumed constants  %%%

lambda_T2 = 0.7;
T1b = 1.3;
threshold = 5000; % signal intensity threshold
ScaleFactor = 1000;

%%%%%%%%%

% Calculate TI for each point in the curve
D_TI = max(max(TI_range) - min(TI_range) )/(NumScans/2-1 )
for i=0: NumScans/2
   TI(i+1) = i * D_TI + min(TI_range);
end
TI =( TI(1:NumScans/2))'
size(TI)
pause
% Allocate space for the data
IR_data = zeros(NumScans/2 , xdim*ydim);
IR_size = size(IR_data);
IR_data_buffer = zeros(NumScans/2 , 2);

disp('Loading data ...')

for i=0:NumScans/2 -1 
   
   % determine the name of the appropriate file
   
   IRNameString = BNameString;
   if (i*2 )<10
      IRNameString = strcat(IRNameString ,'0');
   end
   IRNameString = strcat(IRNameString ,num2str(i*2));
   disp(IRNameString);
   IR_data(i+1,:) = (get_pix_arr(IRNameString, IR_size(2), 'int16'))';
   
   
  
end



% look at pixels in the last image
% if their intensity is above a threshold, do the fit
for pix = 1: xdim*ydim
   
   IR_data_buffer(:,1) = TI;
   IR_data_buffer(:,2) = IR_data(:,pix) / ScaleFactor;
   sz = size(IR_data_buffer);
      
   val = max(IR_data(:,pix));
   if val > threshold
      
      %%%%%%%%%%%%
      
      if show==1
         t = IR_data_buffer(:,1);
         M = IR_data_buffer(:,2);
         cla
         plot (t,M, 'r*');
      end
      %%%%%%%%%%%%%%%

      Mo_guess = 1.5*max(IR_data_buffer(:,2));
      T1_guess = 0.8;
      
      guess0 = [Mo_guess; T1_guess];

      %OPTIONS(2)=1e-3;
      %OPTIONS(3)=1e-3;
      %OPTIONS(14)=300;
      %OPTIONS(1) = 1;
      
      [parms,options,f,j] = curvefit('IR_func',guess0,...
          IR_data_buffer(:,1), IR_data_buffer(:,2),...
          [],[], 2);
      
      %parms = leastsq('IR_func2',guess0,[],[], IR_data_buffer);
      
      %save options
      Mot = abs(parms(1));
      T1 = parms(2);
      
      if show ==1
         M = abs( Mot * (1 - 2*exp(-t /T1) )); %+exp(-2/T1) ) );
         hold on
         plot(t,M)
         
         disp('--------------------------')
         
         disp([	'	pix' '		x' '	y' '	val'])
         disp([pix  mod(pix,xdim) floor(pix/ydim) val]);
         disp('	 Mot		T1')
         disp([Mot T1*ScaleFactor]);
         disp('ratio')
         disp([ Mo_guess(1)/Mot  T1_guess/T1])

         drawnow
         %disp('Press Return to continue')
         %pause    
      end
      
         
   else
      Mot = 0;
      T1 = 0;    
      
   end
        
   T1_data(pix) = T1*ScaleFactor;
   Mot_data(pix) = Mot* ScaleFactor;
   
   
end

pFile = fopen('T1.img','wb');
fwrite(pFile, T1_data, 'int16');
fclose(pFile);

pFile = fopen('Mot.img','wb');
fwrite(pFile, Mot_data, 'int16');
fclose(pFile);

disp('Finished T1 map and Mo map')

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



















