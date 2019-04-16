% Simulates the Kinetics of an arterial inversion tag from the 
% arteries to the brain tissue
% 
% also simulates the deconvolution of the arterial flow from the 
% detected perfusion signal
%
% Continuous ASL model Using two coils : simulation
%


% this is my time units: each time step is 1/10 sec.
SECONDS = 10;
t = [0:1/SECONDS:15];

alpha = 0.8 
Mao = 1
Mssa = 0.1


f = 90 / 60;   % ml/sec.ml
lambda = 0.9
R1t = 1/0.9 ; % 1/sec.
R1a = 1/1.2  ; % 1/sec
Ka = 200       ; % 1/sec

% get the units right:
f = f*SECONDS
R1t = R1t/SECONDS;
R1a = R1a/SECONDS;
Ka = Ka/SECONDS;

a = f/ lambda  + R1t
b = R1a + Ka 
c = Ka 

variance = 0.005;
noise = randn(size(t)) * variance ;

skipFlag=1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  newer version  (jan 2002) %%%%%%%%%%%%%%%%%%%%%%%%

close all
input = zeros(size(t));
input(1*SECONDS:end) = 1;
input(9*SECONDS:end) = 0;
%input(5*SECONDS:6*SECONDS) = 1.2;
transit = 2*SECONDS;
% 
h_art = exp(-(Ka + R1a).* t );
h_art = [zeros(1,transit) h_art(1:15*SECONDS-transit+1)]; %(shift by transit time)
%h_art(1:transit) = 0;

h_tis = exp(-( f/lambda + R1t ) .* t);

% normalize the impulse response functions before the  convolution
h_art = exp(-(R1a ) * transit) * h_art / sum(h_art);
h_tis = exp(-(R1a ) * transit)  * h_tis / sum(h_tis);

% h_art = h_art / sum(h_art);
% h_tis = h_tis / sum(h_tis);


% arterial compartment:
art = conv(input,h_art);

% art=art(1:size(h_decay,2));
% This is definitely wrong:    art = art .* h_decay;

% tissue compartment
tissue = conv(art , h_tis);

% tissue = tissue(1:size(h_decay2,2));
% This is definitely wrong:tissue = tissue.*h_decay2;

art = art(1:size(t,2));
tissue = tissue(1:size(t,2));

signal = tissue + noise;
% 
% % make pretty pictures
% figure
% plot(t,input, 'r'); 
% axis([0 15 0 3]);
% xlabel('time'); ylabel('signal')
% legend('input'); 
% fatlines ; dofontsize(15) ; %print -dtiff uptake1.tif
% 
% figure ; hold on
% plot(t,input, 'r'); legend('input')
% plot(t,art, 'g'); 
% axis([0 15 0 3]);
% xlabel('time'); ylabel('signal')
% legend('input','arterial'); 
% fatlines ; dofontsize(15) ; %print -dtiff uptake2.tif

% figure ; hold on
% plot(t,input, 'r'); legend('input')
% plot(t,art, 'g');
% plot(t,tissue,'b');
% axis([0 15 0 3]);
% xlabel('time'); ylabel('signal');
% legend('input','arterial','tissue'); 
% fatlines ; dofontsize(15) ; %print -dtiff uptake3.tif


figure ; hold on
plot(t,input, 'r'); legend('input')
plot(t,art, 'g');
%plot(t,tissue,'b');
plot(t,signal,'b'); 
axis([0 15 0 3]);
xlabel('time'); ylabel('signal')
legend('input','arterial', 'tissue+noise')
fatlines ; dofontsize(15) ; %print -dtiff uptake4.tif





% apply Wiener Filter to remove the arterial component from the raw signal

if skipFlag==0
    filter1 = conj(fft(h_art)) ./ ( (abs(fft(h_art)).^2 + abs(fft(noise)).^2) );
    
    signal_f = fft(signal);
    filtered_signal = ifft (signal_f .* filter1);
    filtered_signal = filtered_signal / sum(filtered_signal) * size(filtered_signal,2);
    
    % compute the model without the arterial compartment to verify our result
    tissue2 = conv(input,h_tis);
    tissue2 = tissue2(1:size(t,2));
    
    tissue2 = tissue2/ sum(tissue2) * size(tissue2,2);
    
    plot(t,tissue2);
    plot(t,abs(filtered_signal),'y');
    %title('Use filter to Remove arterial dispersion only');
    axis([0 15 0 3]);
    xlabel('time'); ylabel('signal')
    legend('input','arterial', 'tissue+noise','deconvolved signal')
    fatlines ; dofontsize(15) ; print -dtiff filtered1.tif
    %pause
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% apply Wiener Filter to remove the tissue dispersion from the raw signal

    filter2 = conj(fft(h_tis)) ./ ( (abs(fft(h_tis)).^2 + abs(fft(noise)).^2) );
    
    signal_f = fft(signal);
    filtered_signal = ifft (signal_f .* filter2);

%   normalization:
%   filtered_signal = filtered_signal / sum(filtered_signal) * size(filtered_signal,2);
    
    plot(t,abs(filtered_signal),'k--');
    %title('Use filter to Remove tissue compartment only');
    axis([0 15 0 3]);
    xlabel('time'); ylabel('signal')
    legend('input','arterial', 'tissue+noise','deconvolved')
    fatlines ; dofontsize(14) ; print -dtiff filtered2.tif
    %pause

    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
% apply a second Wiener Filter to remove the arterial compartment too.
if skipFlag==0
    tmp = filtered_signal;
    signal_f = fft(tmp);

    filter2 = conj(fft(h_art)) ./ ( (abs(fft(h_art)).^2 +  abs(fft(noise)).^2 ));  %assuming the noise is gone already)
    
    filtered_signal = ifft (signal_f .* filter2);
    filtered_signal = filtered_signal / sum(filtered_signal) * size(filtered_signal,2);
    
    figure 
    hold on
    plot(t,signal,'b');
    plot(t,input,'r');
    plot(t,abs(filtered_signal),'g');
    title('Applied second filter to remove arterial effect too')
    
    %pause
    
% apply  Wiener Filter to remove both the tissue and the arterial compartments in one shot

    H_whole = fft(h_tis) .* fft(h_art);
        
    filter3 = conj(H_whole) ./ ( (abs(H_whole)).^2 + abs(fft(noise)).^2);
    
    signal_f = fft(signal);
    filtered_signal = ifft (signal_f .* filter3);
    filtered_signal = filtered_signal / sum(filtered_signal) * size(filtered_signal,2);
    
    hold on
    plot(t,signal,'b');
    plot(t,input,'r');
    plot(t,abs(filtered_signal),'g');
    
    legend('signal','model input','filtered signal')
    title('for fun:  tried to remove both together with one filter')
    hold off
    
    %pause
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
  % now let's use a dynamic convolution to see what happens in activation
  % we simulate activation by altering the arterial ouput side
  
    art(5*SECONDS:6*SECONDS) = art(5*SECONDS:6*SECONDS) + 0.1;


    for k=1:max(size(input))
        h_tis3 = exp(-( f/lambda + R1t ) .* t);
        tissue3(k) = dyn_conv(k,art', h_tis3');
    end
    
     %tissue3 = tissue3/sum(tissue3) * size(tissue3,2);
     tissue3 = conv(art,h_tis);
     tissue3 = tissue3(1:size(t,2));
     %tissue3 = tissue3/sum(tissue3) * size(tissue3,2);
     
    signal = tissue3 + noise;
    
    figure, hold on
    %plot(t,tissue,'b')
    plot(t,art,'g');
    plot(t,signal,'b')
    
% apply Wiener Filter to remove the tissue component from the raw signal

    filter2 = conj(fft(h_tis)) ./ ( (abs(fft(h_tis)).^2 + abs(fft(noise)).^2) );
    
    signal_f = fft(signal);
    filtered_signal = ifft (signal_f .* filter2);
    
    %filtered_signal = filtered_signal / sum(filtered_signal) * size(filtered_signal,2);
    
    plot(t,abs(filtered_signal),'k--');
%    title(sprintf('Removed tissue compartment only: arterial output. \n Activation is simulated as a change in arterial output'));
    axis([0 15 0 3]);
    xlabel('time'); ylabel('signal')
    legend('arterial','signal','deconvolved')
    fatlines ; dofontsize(15) ; print -dtiff arterial_activation1.tif
%pause
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
% now let's use a dynamic convolution to see what happens in activation
% now let's look at using a variable function of f
if skipFlag==0
    f = f*ones(size(t));
    f(5*SECONDS:6*SECONDS) = 140/60;
 

    for k=1:max(size(input))
        h_tis3 = exp(-( f(k)/lambda + R1t ) .* t);
        tissue3(k) = dyn_conv(k,art', h_tis3');
        
    end
    
    tissue3 = tissue3/sum(tissue3) * size(tissue3,2);
    signal = tissue3 + noise;
    
    figure, hold on
    plot(t,signal,'k')
    
% apply Wiener Filter to remove the tissue component from the raw signal

    filter2 = conj(fft(h_tis)) ./ ( (abs(fft(h_tis)).^2 + abs(fft(noise)).^2) );
    
    signal_f = fft(signal);
    filtered_signal = ifft (signal_f .* filter2);
    filtered_signal = filtered_signal / sum(filtered_signal) * size(filtered_signal,2);
    
    plot(t,abs(filtered_signal),'g');
    title(sprintf('Simulated activation by changing the tissue response function,\n then Removed tissue compartment only: arterial output'));
    %pause
end