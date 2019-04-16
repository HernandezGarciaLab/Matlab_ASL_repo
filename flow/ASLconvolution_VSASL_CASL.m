function ASLconvolution_VSASL_CASL


allTR=1.2:0.2:6;
%allTR = 4;
snr=[];
snr2=[]

for TR=allTR
    %close all
    figure(1);
    [DeltaM1 DeltaMa1 Sa1 St1] = domodel(1,TR);
    figure(2);
    [DeltaM2 DeltaMa2 Sa2 St2] = domodel(2,TR);
    figure(3);
    [DeltaM3 DeltaMa3 Sa3 St3] = domodel(3,TR);
    
    DURATION = 15;
    t = linspace(0,DURATION,DURATION*1000);
    
    figure(15);clf;
    subplot(211)
    plot(t, Sa1,'b','LineWidth',2);hold on
    plot(t, Sa2,'r','LineWidth',2);
    plot(t, Sa3,'g','LineWidth',2);
    axis([0 2*TR-0.1 -0.1 2])
    title('Arterial Input')
    ylabel('Percent Magnetization ');
    legend('CASL','VSASL', 'CVSASL', 'Location', 'NorthEast')
    dofontsize(12)
    
    subplot(212)
    plot(t, St1, 'b','LineWidth',2);hold on
    plot(t, St2, 'r','LineWidth',2);
    plot(t, St3, 'g','LineWidth',2);
    axis([0 2*TR-0.1 -0.1 2])
    title('Tissue Label')
    
    xlabel('Time (sec.)')
    ylabel('Percent Magnetization');
    

    [DeltaM1' DeltaM2'  DeltaM3';]
    dofontsize(12)
    
    figure(16)
    snr = [ snr;
        DeltaM1(1)  DeltaM3(1)]

    snr2 = [ snr2;
        DeltaM1(1)/sqrt(TR)  DeltaM3(1)/sqrt(TR)]
    
    xlabel('Time (sec.)')
    ylabel('Percent Magnetization');
 
end

figure
plot(allTR,snr)

xlabel('Repetition Time (sec.)')
ylabel('ASL signal (%)');   
legend('CASL', 'CVSASL', 'Location', 'SouthEast')
    fatlines
    dofontsize(12)

return

%%

function [DeltaM DeltaMa Sa St] = domodel(asltype, TR)

if nargin==0
    asltype=2;
    TR = 4;
end

DURATION = 15;
t = linspace(0,DURATION,DURATION*1000);
dt = t(2)-t(1);
NSL = 20;  % number of slices (usually 20)

% Physiological constants
M0 = 100;
alpha = 0.9;
R1a = 1/1.6;  % sec-1
R1t = 1/1.4;  % sec-1
f = 0.010;    % ml/s/g
CBVa=0.02;  %ml/ml
lambda = 0.9;
Disp = exp(2);
% dispersion from Chappell Group's papers ?  prior= log(sp) = 2
% Gallichan? x/V = 0.4

% default parameters:
% Pulse Sequence Parameters
% This is how we choose our timing parameters:
% standard recommendations for tissue signal

delay1 = 1;
delay2  = 0.5;

PID = delay1 + delay2 + 0.1;

% To make it a fair comparison, there needs to be no post inversion delay
PID = 0.1;

PAD = 0;  % post Acquisition delay
AQtime = 0.5; % this is the time between the begining of TR and the labeling
width = TR - PID - AQtime
% image collection starts at the begining of AQtime - should be
% about 0.5 s spent on acquisition


if asltype==2
    %width = 1.8;
    delay1 = 0;
    %delay2 = 0.3;
    PID = delay2;
    PAD = 1;
end

% sampling occurs at every TR
%TR = width + PID + AQtime + PAD;
PAD = TR - width - PID - AQtime;

AQS = (TR-PAD):TR:DURATION;
AQS = AQS- AQtime ;

if asltype == 1
    %Make a rect input function for CASL
    inp = zeros(size(t));
    control = inp;
    for n=1:2:length(AQS)
        beg =   (n-1)*TR ;
        inp(1+beg*1000 : (beg + width)*1000) = 1;
    end
    for n=2:2:length(AQS)+1
        beg =   (n-1)*TR ;
        control(1+beg*1000 : (beg + width)*1000) = 1;
    end
    inp = inp(1:length(t));
    control = control(1:length(t));
end



if asltype==2
    %Make an input function for VSASL
    inp = zeros(size(t));
    control = inp;
    alpha = 0.95;
    
    delt = 1000*width/4;
    bolus_width = 2;
    decay = linspace(0,bolus_width, 1000*bolus_width);
    decay = exp(-R1a*decay);
    
    
    for n=1:2:length(AQS)
        
        beg =   (n-1)*TR *1000;
        fin = beg + length(decay);
        inp(beg +1 : fin) = decay * alpha;
        
    end
    
    for n=2:2:length(AQS)+1
        beg =   (n-1)*TR*1000 ;
        fin = beg + width *1000;
        control( beg + 1 : fin) = -1;
    end
    
    inp = inp(1:length(t));
    control = control(1:length(t));
    
    
end

if asltype==3
    %Make an input function for a 3 pulse VSASL
    inp = zeros(size(t));
    control = inp;
    alpha = 0.95;
    
    %delt = 1000*width/4;
    delt = 300; % (ms)
    
    bolus_width = 2;
    decay = linspace(0,bolus_width, 1000*bolus_width);
    decay = exp(-R1a*decay);
    
    for n=1:2:length(AQS)
                
        beg0 =   (n-1)*TR *1000;
        for p=1:floor(width*1000/delt)
            
            beg =   beg0 + delt*(p-1)
            fin = beg + length(decay);
            inp(beg +1 : fin) = decay * alpha;
        end
        
    end
    
    for n=2:2:length(AQS)+1
        beg =   (n-1)*TR*1000 ;
        fin = beg + 1000;
        control( beg + 1 : fin) = -1;
    end
    
    inp = inp(1:length(t));
    control = control(1:length(t));
    
    
end



if (asltype == 1)
    % form an arterial dispersion and decay  function
    %art_fun = Disp*(t-delay1).* exp(-(Disp + R1a) *(t-delay1));
    art_fun = Disp*(t-delay1).* exp(-Disp *(t-delay1));
    art_fun(art_fun<0)=0;
    art_fun = art_fun / sum(art_fun);  % normalize so that dispersion conserves mass
    art_fun = art_fun .* exp(- R1a*t);
    
    %  The arterial signal
    Sa = 2*M0*alpha* conv(inp, art_fun);
    Sa = Sa(1:length(inp));
    
    %    Sa = 2*M0*alpha*inp*exp(-delay1*R1a);
else
    
    Sa = M0*inp;
    
end

% form a tissue perfusion and decay function
tis_fun = exp(-(R1t + f/lambda ) *(t));
tis_fun = tis_fun / max(tis_fun);
% include small delay in the arterioles
tis_fun = [zeros(1,delay2*1000) tis_fun(1:end-delay2*1000)];

% The tissue signal is the convolution of the arterial input into the
% tissue. It assumes that the whole voxel feeding the tissue
St = f*conv( Sa , tis_fun);
St = St * 1e-3; % adjust into units of seconds
% St = Sa*f;  %testing - if there is no tissue dispersion or decay.
St = St(1:length(inp));

% NOW We adjust the arterial signal to the arterial blood volume
Sa = Sa * CBVa;

Stotal = St + Sa;


%area(t, 1*inp,'FaceColor','yellow');
%area(t, 1*control,'FaceColor','white');
hold off
plot(t, Sa,'r','LineWidth',2);
hold on
plot(t, St, 'b','LineWidth',2);
%plot(t, Stotal,'k','LineWidth',2);
axis([0 DURATION -1 1.5*max(Stotal)]);
%{
for n=1:length(AQS)
    h=rectangle('Position', [AQS(n) -0.2 0.5 15] );
    set(h,'LineStyle','--');
    set(h,'EdgeColor',[0.5 0.5 0.5]);
    
end
%}

% which acquisitions to sample
a1=1;
a2=2;

AQS2 = floor(AQS*1000);
%DeltaM = Stotal(AQS2(end-1)) - Stotal(AQS2(end));
%DeltaMa = Sa(AQS2(end-1)) - Sa(AQS2(end));

DeltaM  = -St(AQS2(a2)) + St(AQS2(a1));
DeltaMa = -Sa(AQS2(a2)) + Sa(AQS2(a1));

sltime = AQtime/NSL;


%plot([AQS(a1):sltime:AQS(a1)+AQtime], Stotal( round([AQS(a1):sltime:AQS(a1)+AQtime]/dt) ), 'rx');
%plot([AQS(a2):sltime:AQS(a2)+AQtime], Stotal( round([AQS(a2):sltime:AQS(a2)+AQtime]/dt) ), 'rx');

%legend('Labeling Function', 'Control Function', ...
%    'Arterial signal','Parenchymal signal', ...
%    'Total Signal','Slice Acquisition',...
%    'Location','NorthWest')

legend(...
    'Arterial Input','Tissue signal', ...
    'Location','NorthWest')

plot([AQS(a1):sltime:AQS(a1)+AQtime], St( round([AQS(a1):sltime:AQS(a1)+AQtime]/dt) ), 'gx');
plot([AQS(a2):sltime:AQS(a2)+AQtime], St( round([AQS(a2):sltime:AQS(a2)+AQtime]/dt) ), 'gx');

line([0 DURATION], [ St(round(AQS(a1)/dt))   St(round(AQS(a1)/dt))], 'LineStyle','--');
line([0 DURATION], [ St(round(AQS(a2)/dt))   St(round(AQS(a2)/dt))], 'LineStyle','--');
%line([0 DURATION], [ Stotal(round(AQS(a1)/dt))   Stotal(round(AQS(a1)/dt))],'Color','black', 'LineStyle','--');
%line([0 DURATION], [ Stotal(round(AQS(a2)/dt))   Stotal(round(AQS(a2)/dt))],'Color','black', 'LineStyle','--');

xlabel('Time (sec.)')
ylabel('Percent Signal Change');

% this is for scrutinizing the individual signals slice per slice
DeltaM = St( round([AQS(a1):sltime:AQS(a1)+AQtime]/dt) ) - St( round([AQS(a2):sltime:AQS(a2)+AQtime]/dt) );
DeltaMa = Sa( round([AQS(a1):sltime:AQS(a1)+AQtime]/dt) ) - Sa( round([AQS(a2):sltime:AQS(a2)+AQtime]/dt) );

title(sprintf('TR = %0.2f , Tag Width = %0.2f, Delay= %0.2f', TR, width, PID));
% save signal.dat Stotal -ascii
% save signal_parenchyma.dat St -ascii
% save signal_arterial.dat Sa -ascii

return

