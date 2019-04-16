% CBVa illustration plots
width=1.9; PID=1.6; AQtime=0.5;                           
[Stotal2 Sart2] = ASLconvolution(width, PID, AQtime);
print -dpng ~/Desktop/standardCASL_PID.png 



width=3.5; PID=0; AQtime=0.5;                           
[Stotal2 Sart2] = ASLconvolution(width, PID, AQtime);
print -dpng ~/Desktop/standardCASL_NOPID.png 



width=2.5; PID=0; AQtime=0.5;                           
[Stotal2 Sart2] = ASLconvolution(width, PID, AQtime);
print -dpng ~/Desktop/turboCASL_TR3.0.png 

width=1.8 ; PID=0; AQtime=0.5;                      
delay1 = 1; delay2 = 0.8;
[Stotal2 Sart2] = ASLconvolution(width, PID, AQtime, delay1, delay2)

print -dpng ~/Desktop/turboCASL_TR2.5.png

width=1.6; PID=0; AQtime=0.5;                           
[Stotal2 Sart2] = ASLconvolution(width, PID, AQtime);
print -dpng ~/Desktop/turboCASL_TR2.1.png


width=0.8; PID=0; AQtime=0.5;                           
[Stotal2 Sart2] = ASLconvolution(width, PID, AQtime);
print -dpng ~/Desktop/turboCASL_TR1.3.png



