TI=[1.5 1.5 1.5 1.5 1.5 1.5];
T1art=4
dt=0



for n=1:size(TI,2)
    FAIR_Name=sprintf('sub%04d',n)
	outName=sprintf('Flow%03d',n)
	ez_fair(FAIR_Name, TI(n), T1art,dt,outName);
end
 
