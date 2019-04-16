%ASLConvolution_batch01
% Physiological constants

M0 = 1000;
CBVa = 0.01;  %ml/ml
alpha = 0.9;
R1a = 1/1.6;  % sec-1
R1t = 1/1.4;  % sec-1
f = 0.01;        % ml/s/g
lambda = 0.9;
Disp = 5;    % 1/sec  - I don't know what this number should be

delay1 = 1 ;    % from the labeling plane to the slice
delay2 = 0.5 ;  % time spent in the arteries at the slice before getting into the tissue

%% first test:  If I know the delay times well, but I want to sample at
% different TR's...  what is the degreee of perfusion contaminatin in the
% CBVa signal?
PID = 0;
width = 2* delay1 + delay2;
n=1;
AQtimes = [0.5:0.1:2];
Stotal1 = zeros(length(AQtimes),1);
Sart1 = zeros(length(AQtimes),1);

for n=1:length(AQtimes);
    [Stotal1(n) Sart1(n)] = ASLconvolution(width, PID, AQtimes(n));
    n = n+1;
end
figure(15);
subplot(311)
plot(AQtimes, Stotal1,'k');hold on
plot(AQtimes, Stotal1-Sart1,'k--');
%axis([-0.5 0.5 -0.1 0.1])
hold off
legend('Total Signal', 'Tissue Contribution');
title('Signals as a function of TR')

%% second test: if I'm wrong about delay1 ...  what is the degreee of perfusion contamination in the
% CBVa signal?
delay1err = [-0.5:0.05:0.5];
Stotal2 = zeros(length(delay1err),1);
Sart2 = zeros(length(delay1err),1);
AQtime = 0.5;
PID = 0 ;
width = 2*delay1 + delay2 ;
for n=1:length(delay1err);
    [Stotal2(n) Sart2(n)] = ASLconvolution(width, PID, AQtime, delay1+delay1err(n), delay2);
    n = n+1;
end
figure(15)
subplot(121)
plot(delay1err, Stotal2, 'b'); hold on
plot(delay1err, Stotal2 - Sart2, 'b--');
legend('Total Signal', 'Tissue Contribution');
%axis([-0.5 0.5 -0.1 0.1])
hold off
xlabel('Errors in arterial arrival time (sec.)')
ylabel('ASL signal (a. u.)')
fatlines
dofontsize(16)


%% third test: if I'm wrong about delay2 ...  what is the degreee of perfusion contamination in the
% CBVa signal?
delay2err = [-0.5:0.05:0.5];
Stotal3 = zeros(length(delay2err),1);
Sart3 = zeros(length(delay2err),1);
AQtime = 0.5;
PID = 0 ;
width = 2*delay1 + delay2;
for n=1:length(delay2err);
    [Stotal3(n) Sart3(n)] = ASLconvolution(width, PID, AQtime, delay1 , delay2 + delay2err(n));
    n = n+1;
end
figure(15)
subplot(122)
plot(delay2err, Stotal3, 'r'); hold on
plot(delay2err, Stotal3 - Sart3, 'r--');
legend('Total Signal', 'Tissue Contribution','boxoff');
%axis([-0.5 0.5 -0.1 0.1])
hold off
xlabel('Errors in residency time (sec.)')
ylabel('ASL signal (a. u.)')
fatlines
dofontsize(16)

%% fourth test:  can we produce a turbo-curve?   YES!!!
widths = [0.1:0.1:3];
Stotal4 = zeros(length(widths),1);
Sart4 = zeros(length(widths),1);
AQtime = 0.5;
for n=1:length(widths);
    PID = 0 ;
    [Stotal4(n) Sart4(n)] = ASLconvolution(widths(n), PID, AQtime);
    n = n+1;
end
figure(16)
plot(widths, Stotal4,'k'); hold on
plot(widths, Stotal4-Sart4,'k--'); grid on; hold off
%plot(widths, 1-(Stotal ./ Sart), 'k--');
legend('Observed Signal', 'Contamination by tissue signal')
xlabel('Tagging Duration(s)'); ylabel('Signal (a. u.)')
title('Turbo-Curves with and without suppression')


%% fifth test: if I'm wrong about BOTH delay1 delay2 ...  what is the degreee of perfusion contamination in the
% CBVa signal?
delay2err = [-0.5:0.05:0.5];
Stotal3 = zeros(length(delay2err),1);
Sart3 = zeros(length(delay2err),1);
AQtime = 0.5;
PID = 0 ;
width = 2*delay1 + delay2;
for n=1:length(delay2err);
    [Stotal3(n) Sart3(n)] = ASLconvolution(width, PID, AQtime, delay1+delay2err(n) , delay2 + delay2err(n));
    n = n+1;
end
figure(15)
subplot(122)
plot(delay2err, Stotal3, 'r'); hold on
plot(delay2err, Stotal3 - Sart3, 'r--');
legend('Total Signal', 'Tissue Contribution','boxoff');
%axis([-0.5 0.5 -0.1 0.1])
hold off
xlabel('Errors in residency time (sec.)')
ylabel('ASL signal (a. u.)')
fatlines
dofontsize(16)

%% Making a Movie!!

% the acquisition parameters are:

% physio constants we assume:
d1=0.5; 
d2=0.5; % transit delays

R1 = 1/1.4;

f = 0.01;
deltaf = 0.005;

CBVa = 0.01;
deltaCBVa = 0.01;


aviobj = avifile('~/Desktop/turbo.avi','FPS',8)
for TR=[4:-0.2:1.4 1.3:-0.1:0.6]
    pid=0;
    aqtime=0.5;
    width = TR-pid-aqtime;
    [s0 sa0] = ASLconvolution(width, pid, aqtime, d1,d2,f,CBVa); 
    axis([0 15 -1 12])
    

    drawnow
    frm=getframe(gcf);
    aviobj = addframe(aviobj,frm);
end
aviobj = close(aviobj);
%

%% a movie for cincinnati
aviobj = avifile('~/Desktop/pid.avi','FPS',8)
TR = 4;
for pid=[0:0.1:1.5]
   
    aqtime=1.3;
    width = TR-pid-aqtime;
    [s0 sa0] = ASLconvolution(width, pid, aqtime, d1,d2,f,CBVa); 
    axis([0 15 -1 12])
    

    drawnow
    frm=getframe(gcf);
    aviobj = addframe(aviobj,frm);
end

aviobj = close(aviobj);

%% 
aviobj = avifile('~/Desktop/delay.avi','FPS',8)
TR = 4;
for d1=[0:0.05:1]
    d2=d1;
    pid=0.7;
    aqtime=1.3;
    width = TR-pid-aqtime;
    [s0 sa0] = ASLconvolution(width, pid, aqtime, d1,d2,f,CBVa); 
    axis([0 15 -1 12])
    title(sprintf('TR = %0.2f , Tag Width = %0.2f, Delay= %0.2f, Transits = %0.2f', TR, width, pid, d1));

    drawnow
    frm=getframe(gcf);
    aviobj = addframe(aviobj,frm);
end

aviobj = close(aviobj);
