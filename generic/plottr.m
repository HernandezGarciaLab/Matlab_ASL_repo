% plotter program
% usage plottr(points)
% enter color string

function plottr(a)

s ='aasd';
i = 1;

while ~isempty(s)
   clrstr = strcat(input('color:','s'), 'o');
   hold on;
	plot3(a(i,1),a(i,2),a(i,3),clrstr);
	i = i+1
end
