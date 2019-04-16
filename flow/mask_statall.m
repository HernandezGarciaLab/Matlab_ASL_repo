close all
clear all

IE = [];
maskname = 'mask';
mask = lightb(maskname);
newline = sprintf('\n');
xvals = [00 01 02 04 06]; 
xvals= 0.033*xvals + 1.3;

xvals = [30 40 50 60 62 64 66 68 70 72 74 76 78 80 82 84 86 88 90 92 94 96 98 120 122 124 127 130 140]/100;
xvals=[38:2:98];
xvals = 1-xvals/100;
xvals = [10:-1:-10]/10;

%for i = [30 40 50 60 62 64 66 68 70 72 74 76 78 80 82 84 86 88 90 92 94 96 98 120 122 124 127 130 140];
%for i=[38:2:98]
%mask= lightb(maskname);
%xvals = -1*[2 3 4 5 6 7 8]/10;

%for i = [2 3 4 5 6 7 8];

for i = [10:-1:-10];
    
    if i<10
        foldername = strcat('m0',num2str (i));
    else
        foldername = strcat('m',num2str (i));
    end
    
    %foldername = num2str (i);
    
    str = ['cd ' foldername];
    eval(str)
    
   % mask = lightb(maskname); %%%%%%%%%%%%%% MASK in each folder
    mean_sub = lightb('mean_sub');
    mean_tag = lightb('mean_tag');
    mean_con = lightb('mean_con');
    mean_magDiff = lightb('mean_magDiff');
    
    mean_sub_mask = mean_sub .* mask;
    mean_sub_mask (find (mean_sub_mask == 0)) = [];
    MEAN_mean_sub_mask = mean( mean_sub_mask(:));
    
    mean_con_mask = mean_con .* mask;
    mean_con_mask (find (mean_con_mask == 0)) = [];
    MEAN_mean_con_mask = mean( mean_con_mask(:));
    
    mean_tag_mask = mean_tag .* mask;
    mean_tag_mask (find (mean_tag_mask == 0)) = [];
    MEAN_mean_tag_mask = mean( mean_tag_mask(:));
    
    mean_magDiff_mask = mean_magDiff .* mask;
    mean_magDiff_mask (find (mean_magDiff_mask == 0)) = [];
    MEAN_mean_magDiff_mask = mean( mean_magDiff_mask(:));
    
    
    
    inversion_efficiency = MEAN_mean_sub_mask/(2*max(MEAN_mean_con_mask ,MEAN_mean_tag_mask));
   
    disp('=================================');
    disp(sprintf('Mask Stat in folder : %s', foldername) );
    disp(sprintf('# of voxels in the mask : %d', size(mean_magDiff_mask,2)) );
    disp(newline);
    disp(sprintf('%20s = %6.2f', 'mean_sub @ ROI', MEAN_mean_sub_mask) );
    disp(sprintf('%20s = %6.2f', 'mean_con @ ROI', MEAN_mean_con_mask) );
    disp(sprintf('%20s = %6.2f', 'mean_tag @ ROI', MEAN_mean_tag_mask) );
    disp(sprintf('%20s = %6.2f', 'mean_magDiff @ ROI', MEAN_mean_magDiff_mask) );
    disp(sprintf('%20s = %6.2f', 'Inversion Efficiency', inversion_efficiency) );
    
    IE = [IE inversion_efficiency];
    plot(IE);
    
    cd ..
    
       
end


close all;
plot (xvals, IE,'*-');
ylabel('Inversion Efficiency');

xlabel('Additional Phase (rad)');

%xlabel('Residual Gradient Moment (\eta)');
% 
% ylabel('Inversion Efficiency');
% xlabel('Distance from iso-center (cm)');

% ylabel('Inversion Efficiency');
% xlabel('Flow velocity (cm/s)');

  
grid on


