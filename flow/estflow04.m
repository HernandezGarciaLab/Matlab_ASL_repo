function estflow( activepixfile , t1file, Ttransfile,  TR, Ttag, del, dist)
%function estflow( activepixfile , t1file, Ttransfile, TR, Ttag, del, dist)
%
% perfusion estimation given acquisition parameters and a timeseries
% parameters are assumed to be stored in the provided mat files.
% 
% this version estimates the mean perfusion assuming constant perfusion
% This value becomes the initial guess for the second step (dynamic estimation)
%
% uses kinetix_ss_lsq.m for the constant case and 
% kinetix_lsqb.m for the dynamic part...
% 
%

load(activepixfile);

%load activepix1700e
%time courses from two slices 
series=mean( atcC, 1 );
%TR=1.7;
%evdata = event_avg(series, [16:40:600]/TR, 40/TR , TR);
[evdata,v] = hrf_deconv(series',round([17:20:600]/TR) , floor(25/TR) );
evdata=evdata';

%load ../T1map/irvals.mat
load(t1file);

%M0vals(:,:,2)=pixtoim(pix_2,[64 64],M0_2');
%M0vals(:,:,3)=pixtoim(pix_3,[64 64],M0_3');
%M0vals=M0vals(:);
%
%actives(:,:,2)=pixtoim(pixC2,[64 64]);
%actives(:,:,3)=pixtoim(pixC3,[64 64]);
%actives=actives(:);
%
%meanM0= sum(M0vals(find(actives>0)))/sum(actives(:))

if ~exist('meanM01') meanM01 = 0; end
if ~exist('meanM02') meanM02 = 0; end
if ~exist('meanM03') meanM03 = 0; end

if ~exist('meanT11') meanT11 = 0; end
if ~exist('meanT12') meanT12 = 0; end
if ~exist('meanT13') meanT13 = 0; end

meanM0  = meanM01*weightsC(1) + meanM02*weightsC(2) + meanM03*weightsC(3);
meanM0 = meanM0/sum(weightsC);
% different format ...overwrite the earlier calc...
meanM0 = mean( [ M0_1 M0_2 M0_3 ]);

meanT1  = meanT11*weightsC(1) + meanT12*weightsC(2) + meanT13*weightsC(3);
meanT1 = meanT1/sum(weightsC);
% different format ...overwrite the earlier calc...
meanT1 = mean( [ T1_1 T1_2 T1_3 ]);


load (Ttransfile);
tmp = myTTim(:);
if (exist('myMSEvalues_scaled'))
    tmp = tmp.* (myMSEvalues_scaled(:)<2);
    %tmp = myMSEvalues_scaled(:);
end
Ttransit = sum(tmp) / length(find(tmp));

disp(' M0   T1   Ttransit')
disp([meanM0 meanT1 Ttransit])

%load twoevents
global rpenalty
rpenalty=300
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

t = [TR: TR: TR*(length(series))];

% Typical values:
fprintf(' Ttag, del, crushers, R1t, R1a, TR, alpha, dist, V0');
parms = [ Ttag del crushers R1t R1a TR alpha dist V0]

optvar=optimset('lsqnonlin');
optvar.TolFun = 1e-15;
optvar.TolX = 1e-10;
optvar.MaxIter = 10;
optvar.Diagnostics = 'off';
optvar.Display = 'iter';
optvar.DiffMinChange = 1.0e-6;


%%%%%%%% estimate the mean perfusion assuming steady state
LB=0.005;
UB=0.03;
[mean_est , resnorm, res, ex, output]  = lsqnonlin(@kinetix_ss_lsq,...
	0.016 ,LB ,UB, ...
	optvar,...
	t,parms, ...
	series);
mean_est
%%%%%%%%
fmean_bias= resnorm/sum(series.^2)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% let's try the whole time series
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if fmean_bias> 0.5
	mean_est=0.15
end
%keyboard
% create initial guess including a mean value...
est0 =mean_est*ones(size(series)) ;

% adjust the boundaries to include the mean flow estimate
LB = 0.005*ones(size(series));
UB = 0.03*ones(size(series));


[estimates , resnorm, res, ex, output]  = lsqnonlin(@kinetix_lsqb,...
    est0, LB, UB, ...
    optvar,...
    t,parms, ...
    series);
%keyboard
% Put the mean estimate into the function estimate
f_bias= resnorm/sum(series.^2)
fseries= estimates;
t = [TR: TR: TR*(length(series))];
modeled = kinetix_lsqb(estimates,t,parms);
fmean=mean(fseries)
save tmp_wksp 

figure
subplot(211);
[ax h1 h2] = plotyy(t,series, t,fseries);
hold on,
plot(t,modeled, '--');
axis([0 t(end) -10 35]);
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% event averages
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('\nEstimating perfusion from deconvolved single event')
%t = [0: TR: 100*length(f)];
t = [TR: TR: TR*(length(evdata))];

% trial average of the estimated time series:
[fevent,v] = hrf_deconv(fseries',round([17:20:600]/TR) , floor(25/TR) );
fevent=fevent';
t2=[TR:TR:length(fevent)*TR];
%fevent = event_avg(fseries, [16:40:600]/TR, 40/TR , TR);
modeled = kinetix_lsqb(fevent,t2,parms);

save tmp_wksp 

subplot(212)
[ax h1 h2] = plotyy(t,evdata, t2,fevent);
hold on,
plot(t2,modeled, '--');
axis([0 t2(end) 0 25])
title('Trial averaged flow estimate') ; grid
legend('Signal','Modeled signal',-1)
legend boxoff
ylabel('ASL signal (a.u.)')
fatlines, dofontsize(12)

axes(ax(2)), hold on
ylabel('Perfusion (ml/s*g)')
legend('Estimated Flow',-1)
legend boxoff
axis([0 t2(end) 0 0.025])
xlabel('Time (sec)')
fatlines, dofontsize(12)

drawnow
%save estimationResults2
save estimationResults3
return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% estimation from trial averages
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure
subplot(211);
t = [TR: TR: TR*(length(series))];
fseries2 = [fseries-mean(fseries)  mean(fseries)];
modeled = kinetix_lsqb(fseries2,t,parms);

subplot(211);
[ax h1 h2] = plotyy(t,series, t,fseries);
hold on;
plot(t,modeled, '--');
axis([0 t(end) -10 35]);
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
xlabel('Time (sec)');
fatlines, dofontsize(12);


t = [TR: TR: TR*(length(evdata))];
est0 = ones(size(t)) *  90/6000;
LB = est0*0.5;
UB = est0*2.5;
LB(:) = -0.02;
UB(:) = 0.02;
LB(end) = 0.005;
UB(end) = 0.03;

%rpenalty=0

[ev_estimates , resnorm, res, ex, output]  = lsqnonlin(@kinetix_lsqb,...
    est0, LB, UB, ...
    optvar,...
    t,parms, ...
    evdata);

fevent2 =[ev_estimates - mean(ev_estimates) mean(ev_estimates)];
modeled = kinetix_lsqb(fevent2,t,parms);

subplot(212)
[ax h1 h2] = plotyy(t,evdata, t,fevent2);
hold on,
plot(t,modeled, '--')
axis([0 40 0 25])
title('Estimated flow from ASL trial average') ; grid
legend('Signal','Modeled signal',-1)
legend boxoff
ylabel('ASL signal (a.u.)')
fatlines, dofontsize(12)

axes(ax(2)), hold on
ylabel('Perfusion (ml/s*g)')
legend('Estimated Flow',-1)
legend boxoff
axis([0 40 0 0.025])
xlabel('Time (sec)')
fatlines, dofontsize(12)

method='estflow03'
subj=pwd;
save estimationResults2

