function [DeltaM DeltaMa] = ASLconvolution(width, PID, AQtime, delay1, delay2, f,CBVa)
% function [DeltaM DeltaMa] = ASLconvolution(width, PID, AQtime, delay1, delay2 [, f, CBVa])


DURATION = 15;
t = linspace(0,DURATION,DURATION*1000);
dt = t(2)-t(1);
NSL = 20;  % number of slices (usually 20)

% Physiological constants
M0 = 1000;
alpha = 0.9;
R1a = 1/1.6;  % sec-1

R1t = 1/1.4;  % sec-1
if nargin < 6
    f = 0.010;    % ml/s/g
end
if nargin < 7
    CBVa=0.02;  %ml/ml
end

lambda = 0.9;
Disp = exp(2);    
            % dispersion from Chappell Group's papers ?  prior= log(sp) = 2
            % Gallichan? x/V = 0.4 

% delay1 = 0.5;
% delay2 = 1;

if nargin==0
    % default parameters:
    % Pulse Sequence Parameters
    % This is how we choose our timing parameters:
    % standard recommendations for tissue signal
    delay1 = 0.8;
    delay2  = 0.8;
    width = 1.8;
    PID = delay1 + delay2;
    AQtime = 0.5; % this is the time between the begining of TR and the labeling
    % image collection starts at the begining of AQtime - should be
    % about 0.5 s spent on acquisition
    
    if 0% recommendations for CBVa
        width =  delay2;
        PID = delay1;
        
    end
end

if nargin<4  
    delay1 = 1 ;    % from the labeling plane to the slice
    delay2 = 0.5 ;  % time spent in the arteries at the slice before getting into the tissue
end

% sampling occurs at every TR
TR = width + PID + AQtime;

AQS = TR:TR:DURATION;
AQS = AQS- AQtime ;


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

% form an arterial dispersion and decay  function
%art_fun = Disp*(t-delay1).* exp(-(Disp + R1a) *(t-delay1));
art_fun = Disp*(t-delay1).* exp(-Disp *(t-delay1));
art_fun(art_fun<0)=0;
art_fun = art_fun / sum(art_fun);  % normalize in order to conserve mass in the input function
art_fun = art_fun .* exp(- R1a*t);


% This is the definition of CBVa

%  The arterial signal
Sa = 2*M0*alpha* conv(inp, art_fun);
%Sa = Sa *1e-3;  % adjust to seconds
Sa = Sa(1:length(inp));

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

figure (14); clf ; hold on
area(t, 1*inp,'FaceColor','yellow');
area(t, 1*control,'FaceColor','red');
plot(t, Sa,'r','LineWidth',2);
plot(t, St, 'b','LineWidth',2);
plot(t, Stotal,'k','LineWidth',2);
axis([0 DURATION -1 1.5*max(Stotal)]);
%{
for n=1:length(AQS)
    h=rectangle('Position', [AQS(n) -0.2 0.5 15] );
    set(h,'LineStyle','--');
    set(h,'EdgeColor',[0.5 0.5 0.5]);
    
end
%}


AQS2 = floor(AQS*1000);
%DeltaM = Stotal(AQS2(end-1)) - Stotal(AQS2(end));
%DeltaMa = Sa(AQS2(end-1)) - Sa(AQS2(end));

DeltaM  = -Stotal(AQS2(3)) + Stotal(AQS2(2));
DeltaMa = -Sa(AQS2(3)) + Sa(AQS2(2));

sltime = AQtime/NSL;

plot([AQS(2):sltime:AQS(2)+AQtime], Stotal( round([AQS(2):sltime:AQS(2)+AQtime]/dt) ), 'rx');
plot([AQS(3):sltime:AQS(3)+AQtime], Stotal( round([AQS(3):sltime:AQS(3)+AQtime]/dt) ), 'rx');

legend('Labeling Pulses', 'Control Pulses', ...
    'Arterial signal','Parenchymal signal', ...
    'Total Signal','Slice Acquisition',...
    'Location','NorthWest')

plot([AQS(2):sltime:AQS(2)+AQtime], St( round([AQS(2):sltime:AQS(2)+AQtime]/dt) ), 'gx');
plot([AQS(3):sltime:AQS(3)+AQtime], St( round([AQS(3):sltime:AQS(3)+AQtime]/dt) ), 'gx');

line([0 DURATION], [ St(round(AQS(2)/dt))   St(round(AQS(2)/dt))], 'LineStyle','--');
line([0 DURATION], [ St(round(AQS(3)/dt))   St(round(AQS(3)/dt))], 'LineStyle','--');
line([0 DURATION], [ Stotal(round(AQS(2)/dt))   Stotal(round(AQS(2)/dt))],'Color','black', 'LineStyle','--');
line([0 DURATION], [ Stotal(round(AQS(3)/dt))   Stotal(round(AQS(3)/dt))],'Color','black', 'LineStyle','--');

% this is for scrutinizing the individual signals slice per slice
DeltaM = Stotal( round([AQS(1):sltime:AQS(1)+AQtime]/dt) ) - St( round([AQS(2):sltime:AQS(2)+AQtime]/dt) );
DeltaMa = Sa( round([AQS(1):sltime:AQS(1)+AQtime]/dt) ) - St( round([AQS(2):sltime:AQS(2)+AQtime]/dt) );

title(sprintf('TR = %0.2f , Tag Width = %0.2f, Delay= %0.2f', TR, width, PID));
% save signal.dat Stotal -ascii
% save signal_parenchyma.dat St -ascii
% save signal_arterial.dat Sa -ascii

return

