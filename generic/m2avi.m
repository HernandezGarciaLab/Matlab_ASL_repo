function mov = m2avi(M, avifname, fps)
% function mov = m2avi(M, avifname, fps)
%
% Plot magnetization path in 3D, and make movie.
%
% INPUTS:
%    M         - 3xN array (time-series)
%    avifname  - output AVI file name
%    fps       - AVI file frame rate (frames per second)
% 
% $Id: m2avi.m 521 2013-04-24 19:10:38Z klitinas $
%
% Example:
%  m = runsimpaths(300,100,60,5,50,5,0);
%  m = m(:,:);
%  m2avi(m, 'mymovie.avi', 20);

[tmp, N] = size(M);

figure;
for n = 1:N
	set(gcf, 'Color', [0 0 150]/255);
	[lh,ah] = sub_plotspin(M(:,n)');
	ht = title(avifname);
	set(ht, 'Color', [1 1 1]);
	set(ht, 'FontSize', 12);
	set(ht, 'FontWeight', 'bold');
	mov(n) = getframe(gcf);
   pause(0.1);
   set(lh, 'Visible', 'off');
   set(ah, 'Visible', 'off');
end
close(gcf);

movie2avi(mov, avifname, 'fps', fps);

return;




function [lh, ah] = sub_plotspin(m)

lim = 1.0;
axlim = lim*1/sqrt(2);

% set up axes
axis([-axlim axlim -axlim axlim -axlim axlim ]);
axis off;
xah = line([-lim, lim], [0,0], [0,0]);
yah = line([0,0],[-lim, lim], [0,0]);
zah = line([0,0], [0,0], [-1.1*lim, 1.1*lim]);
sub_setaxprops(xah);
sub_setaxprops(yah);
sub_setaxprops(zah);

ht = text(1.1*lim, 0, 0, 'y');
sub_settextprops(ht);
ht = text(0, -1.1*lim, 0,  'x');
sub_settextprops(ht);
ht = text(0, 0, 1.1*lim, 'z');
sub_settextprops(ht);

[lh,ah] = arrow3d([0,0,0], m, 15, 'cylinder', [0.3, 0.3]);
set(lh, 'LineWidth', 3);

% ht = plot([0,0,0], m(:,n)', '.');
% ht = line([0,0,0], m(:,n)');
% set(ht, 'LineWidth', .3);
% set(ht, 'LineStyle', '.');

return;




function sub_settextprops(ht)

set(ht, 'Color', [80 80 255]/255);
set(ht, 'FontSize', 16);
set(ht, 'FontWeight', 'bold');

return;



function sub_setaxprops(h) 

set(h, 'Color', 'blue');
set(h, 'Color', [80 80 255]/255);
set(h, 'LineStyle', '--');
set(h, 'LineWidth', 0.1);

return;

% EOF
