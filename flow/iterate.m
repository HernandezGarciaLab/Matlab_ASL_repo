
% Put sequence parameters here:
parms(1) = Ttag;     % seconds
parms(2) = del ;	 %seconds
parms(3) = crushers ;
parms(4)= R1t ;    % 1/sec.
parms(5) = R1a;   % 1/secparms(6)=
parms(6) = TR ;  % sec.
parms(7) = alpha; 
parms(8) = dist ;
parms(9) = V0 ;


s = []; 
parms(1) = 0.1 ; signal1 = kinetix_lsq(f ,t, parms); plot(signal1)
s = [s ; signal1]
parms(1) = 0.2 ; signal1 = kinetix_lsq(f ,t, parms); plot(signal1)
s = [s ; signal1]
parms(1) = 0.3 ; signal1 = kinetix_lsq(f ,t, parms); plot(signal1)
s = [s ; signal1]
parms(1) = 0.4 ; signal1 = kinetix_lsq(f ,t, parms); plot(signal1)
s = [s ; signal1]
parms(1) = 0.5 ; signal1 = kinetix_lsq(f ,t, parms); plot(signal1)
s = [s ; signal1]
parms(1) = 0.6 ; signal1 = kinetix_lsq(f ,t, parms); plot(signal1)
s = [s ; signal1]
parms(1) = 0.7 ; signal1 = kinetix_lsq(f ,t, parms); plot(signal1)
s = [s ; signal1]
parms(1) = 0.8 ; signal1 = kinetix_lsq(f ,t, parms); plot(signal1)
s = [s ; signal1]
parms(1) = 0.9 ; signal1 = kinetix_lsq(f ,t, parms); plot(signal1)
s = [s ; signal1]
parms(1) = 1.0 ; signal1 = kinetix_lsq(f ,t, parms); plot(signal1)
s = [s ; signal1]
parms(1) = 1.1 ; signal1 = kinetix_lsq(f ,t, parms); plot(signal1)
s = [s ; signal1]
parms(1) = 1.2 ; signal1 = kinetix_lsq(f ,t, parms); plot(signal1)
s = [s ; signal1]
parms(1) = 1.3 ; signal1 = kinetix_lsq(f ,t, parms); plot(signal1)
s = [s ; signal1]
parms(1) = 1.4 ; signal1 = kinetix_lsq(f ,t, parms); plot(signal1)
s = [s ; signal1]
parms(1) = 1.5 ; signal1 = kinetix_lsq(f ,t, parms); plot(signal1)
s = [s ; signal1]
parms(1) = 1.6 ; signal1 = kinetix_lsq(f ,t, parms); plot(signal1)
s = [s ; signal1]
parms(1) = 1.7 ; signal1 = kinetix_lsq(f ,t, parms); plot(signal1)
s = [s ; signal1]
parms(1) = 1.8 ; signal1 = kinetix_lsq(f ,t, parms); plot(signal1)
s = [s ; signal1]
parms(1) = 1.9 ; signal1 = kinetix_lsq(f ,t, parms); plot(signal1)
s = [s ; signal1]

 plot(s(6:14,:)') ; legend('0.6','0.7', '0.8' ,' 0.9',  '1.0' ,' 1.1' , '1.2' , '1.3' , '1.4')

figure

plot([0.1:0.1:1.9], s(:,5),'*-')

save signals.mat s
