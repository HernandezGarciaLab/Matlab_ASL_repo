function fseries = estflow( series , t1, Ttrans,  TR, Ttag, del, dist)
% function flow_series = estflow( ASLseries , T1_tissue, Ttrans,  TR, Ttag, del, dist)
%
% iterative estimation of perfusion from ASL data using a kinetic model in which 
% mean flow velocity changes dynamically (ie - transit time changes with flow)
%
% The model is in :   kinetix_lsq.m
%
% assumptions and other constants:
%
% alpha = 0.85; 
% R1a = 1/1.6;    % 1/sec
% crushers=1;
% reg. penalty = 500
% dVel / df = 0.2
%

global rpenalty
rpenalty=500
%
% Aquisition parameters:
 
% Ttag =1.52  % seconds
% del = 0.08;	 %seconds
crushers=1;
%R1t = 1/1.2;    % 1/sec.
R1t = 1/meanT1; 
R1a = 1/1.6;    % 1/sec
% TR=1.7;
 alpha = 0.85; 
% dist = 18;   %cm
V0 = dist/Ttransit;  %cm/sec

% include the proton density and partition coefficient terms:

alpha=meanM0*0.85/0.7;


% Typical values:
parms = [ Ttag del crushers R1t R1a TR alpha dist V0];

optvar=optimset('lsqnonlin');
optvar.TolFun = 1e-15;
optvar.TolX = 1e-10;
optvar.MaxIter = 10;
optvar.Diagnostics = 'off';
optvar.Display = 'iter';
optvar.DiffMinChange = 1.0e-6;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% let's try the whole time series
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


t = [TR: TR: TR*(length(series))];
est0 =ones(size(series)) * 90/6000;
LB = est0*0.5;
UB = est0*2.5;

[fseries , resnorm, res, ex, output]  = lsqnonlin(@kinetix_lsq,...
	est0, LB, UB, ...
	optvar,...
	t,parms, ...
	series);

t = [TR: TR: TR*(length(series))];
modeled = kinetix_lsq(fseries,t,parms);

[ax h1 h2] = plotyy(t,series, t,fseries)
hold on,
plot(t,modeled, '--')
axis([0 t(end) -10 35])
title('Estimated flow from ASL signal') ; grid
legend('Signal','Modeled signal',-1)
legend boxoff
ylabel('ASL signal (a.u.)')
fatlines, dofontsize(12)

axes(ax(2)), hold on
axis([0 t(end)  -0.01 0.035])
ylabel('Perfusion (ml/s*g)')
legend('Estimated Flow',-1)
legend boxoff
xlabel('Time (sec)')
fatlines, dofontsize(12)

save estimationResults

return

