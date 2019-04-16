close all
clear all

% c_out(index,:) = mean(c(count : count+navg-1 , :), 1);
% t_out(index,:) = mean(t(count : count+navg-1 , :), 1);
% ms = mean(s,1);
% mc = mean(c,1);
% mt = mean(t,1);


newline = sprintf('\n');

mask = lightbox('mask');

figure;mean_sub = lightbox('mean_sub'); %write_img('mean_sub.img',abs(ms),h);
	
figure;mean_con = lightbox('mean_con'); %write_img('mean_con.img',abs(mc),h);
	
figure;mean_tag = lightbox('mean_tag'); %write_img('mean_tag.img',abs(mt),h);

figure;mean_magdiff = lightbox('mean_magDiff');%mpd = mean(pd,1); pd = angle(c_out) - angle(t_out);

figure;mean_phasediff=lightbox('mean_phaseDiff');%mmd = mean(md,1);    md = abs  (c_out) - abs(t_out);

figure;p_mean_sub=lightbox('p_mean_sub'); % write_img('p_mean_sub.img',1000*angle(ms),h);

sub = mean_sub.*mask;
sub(find(sub==0))=[];
mean_diff_signal = mean(sub(:));

con = mean_con.*mask;
con(find(con==0))=[];
mean_control = mean(con(:));

mag = mean_magdiff.*mask;
mag(find(mag==0))=[];
mean_magnitude = mean(mag(:));

tag = mean_tag.*mask;
tag(find(tag==0))=[];
mean_tagg = mean(tag(:));

phase = mean_phasediff.*mask;
phase(find(phase==0))=[];
mean_phasediff = mean(phase(:));

phase2 = p_mean_sub.*mask;
phase2(find(phase2==0))=[];
p_mean_subb = mean(phase2(:));


inversion_efficiency1 = mean_diff_signal/(2*max(mean_control,mean_tagg));
inversion_efficiency2 = (mean_control +mean_tagg)/(2*max(mean_control,mean_tagg));


disp(newline);
disp(sprintf('%20s = %6.2f', 'mean_sub @ ROI', mean_diff_signal) );
disp(sprintf('%20s = %6.2f', 'mean_con @ ROI', mean_control) );
disp(sprintf('%20s = %6.2f', 'mean_tag @ ROI', mean_tagg) );
disp(sprintf('%20s = %6.2f', 'mean_magDiff @ ROI', mean_magnitude) );
disp(sprintf('%20s = %6.2f', 'mean_phaseDiff @ ROI', mean_phasediff/1000) );
disp(sprintf('%20s = %6.2f', 'p_mean_sub @ ROI', p_mean_subb/1000) );

disp(sprintf('%20s = %6.2f', 'Inversion Efficiency complex', inversion_efficiency1) );
disp(sprintf('%20s = %6.2f', 'Inversion Efficiency ', inversion_efficiency2) );



