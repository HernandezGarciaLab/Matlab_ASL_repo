
% Batch script to reproduce the dependence of the ASL signal on TR
% simulation used kinetix_lsq for a flat perfusion and different TRs
% it does both the resting and active cases

% Put sequence parameters here:
% Typical values:
Ttag =0.8  % seconds
del = 0.02;	 %seconds
crushers=1;
R1t = 1/1.2;    % 1/sec.
R1a = 1/1.6;    % 1/sec
TR = Ttag + 0.2;
xchange_time = 0.1;  % sec.
dist = 16;   %cm
V0 = 10;  %cm/sec
Ttransit=dist/V0
% adjust for the proton density
alpha=6000*0.7*0.85;

parms(1) = Ttag;     % seconds
parms(2) = del ;	 %seconds
parms(3) = crushers ;
parms(4)= R1t ;    % 1/sec.
parms(5) = R1a;   % 1/secparms(6)=
parms(6) = TR ;  % sec.
parms(7) = alpha; 
parms(8) = dist ;
parms(9) = V0 ;

% make the flow function...
duration = 50;   % this is in seconds !!

f0=90/(60*100);edit 
f = f0*ones(1,duration/TR);
t = [TR: TR: TR*(length(f))];

s = []; 
for TR=0.2:0.1:4
    parms(6)=TR;
    parms(1)=TR-0.2;
    signal1 = kinetix_lsq(f ,t, parms); plot(signal1)
    s = [s ; -mean(signal1)];
end



% Now do the active case:
f=f*1.5;
V0=V0*1.1;
parms(9)=V0;

s2 = []; 
for TR=0.2:0.1:4
    parms(6)=TR;
    parms(1)=TR-0.2;
    signal1 = kinetix_lsq(f ,t, parms); plot(signal1)
    s2 = [s2 ; -mean(signal1)];
end

plot([0.2:0.1:4], s)
hold on, 
plot([0.2:0.1:4], s2,'r')
title('Modeled Rest vs. Activation states')
legend('Rest', 'Active')
xlabel('TR (seconds)')
ylabel('ASL signal (a.u.)')
dofontsize(16)
fatlines

print -dpng sim_ss_rest_active.png
