% comparison between labeting schemes

r1a = 1/1.7;
bat = 1.4;
f = 50/6000 ; % ml/s*g
Disp = 100;

dt = 1e-3;  % the time steps are 1 ms.  

ttmp = linspace(0,10, 10/dt)';
decay = ones(size(ttmp));
decay = exp(- ttmp  *r1a);

input = zeros(size(ttmp));

% arterial dispersion for pulsed input
p_art_kernel = ttmp.* exp(-Disp/2 *ttmp);
p_art_kernel(ttmp <= 0) = 0;
p_art_kernel = p_art_kernel / sum(p_art_kernel);  %normalize the mass in the dispersion

% Arterial dispersion and decay Kernel for continuous input
art_kernel = ttmp.^(bat*Disp) .* exp(-Disp *ttmp);
art_kernel(ttmp <= 0) = 0;
art_kernel = abs(art_kernel);
art_kernel = art_kernel / sum(art_kernel);  %normalize the mass in the dispersion



% scheme 1  : saturation based velocity selective ASL
vsasl_inp = input;
vsasl_inp(1:1.5/dt) = 0.5;
vsasl_inp = vsasl_inp .* decay;

vsasl_inp = conv(vsasl_inp, p_art_kernel);
vsasl_inp = vsasl_inp(1:length(input));

vsasl_sig = f * conv(vsasl_inp, exp(-ttmp*(f/0.9 + 1/1.2) ));
vsasl_sig = vsasl_sig(1:length(input));

% scheme 2  : inversion based velocity selective ASL
vsai_inp = input;
vsai_inp(1:1.5/dt) = 0.9;
vsai_inp = vsai_inp .* decay;

vsai_inp = conv(vsai_inp, p_art_kernel);
vsai_inp = vsai_inp(1:length(input));

vsai_sig = f * conv(vsai_inp, exp(-ttmp*(f/0.9 + 1/1.2) ));
vsai_sig = vsai_sig(1:length(input));


% scheme 3: continuous ASL
pcasl_inp = input;
pcasl_inp(1:2/dt) = 0.9;

pcasl_inp = conv(pcasl_inp , art_kernel .* decay);
pcasl_inp = pcasl_inp(1:length(input));

pcasl_sig = f * conv(pcasl_inp, exp(-ttmp*(f/0.9 + 1/1.2) ));
pcasl_sig = pcasl_sig(1:length(input));


% scheme 4: PASL
pasl_inp = input;
pasl_inp(1/dt:1.5/dt) = 0.99;
pasl_inp = pasl_inp .* decay;

pasl_inp = conv(pasl_inp, p_art_kernel);
pasl_inp = pasl_inp(1:length(input));

pasl_sig = f * conv(pasl_inp, exp(-ttmp*(f/0.9 + 1/1.2) ));
pasl_sig = pasl_sig(1:length(input));




subplot(211)
hold off
plot(ttmp, vsasl_inp,'r'); hold on
plot(ttmp, vsai_inp,'g'); hold on
plot(ttmp, pcasl_inp,'b'); hold on
plot(ttmp, pasl_inp,'k'); hold on
legend('sat. VSASL', 'Inv VSASL', 'PCASL', 'PASL');
title('Arterial Input Function')
xlabel('time (sec.)');

fatlines
dofontsize(16)

subplot(212)
hold off
plot(ttmp, vsasl_sig,'r'); hold on
plot(ttmp, vsai_sig,'g'); hold on
plot(ttmp, pcasl_sig,'b'); hold on
plot(ttmp, pasl_sig,'k'); hold on
legend('sat. VSASL', 'Inv VSASL', 'PCASL', 'PASL');
title('Amt. of Label in the Tissue')
xlabel('time (sec.)');
fatlines
dofontsize(16)


print -dpng compare_input_functions


