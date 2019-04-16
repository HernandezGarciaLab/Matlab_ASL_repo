% other tests for causality
myD=[];stats=[];
%for noise_events=0:5:100


duration=100;
TR=1;
nevents = 20;
extra_events = round(0.25*nevents);
noise_events = round(0.15*nevents);

a_events = zeros(duration,1);
a_events(1:nevents) = 1;
inds = randperm(length(a_events));
a_events(inds) = a_events;

% add some extra events in b
b_events = a_events;
inds = find(~b_events);
tmp = randperm(length(inds));
inds = inds(tmp);
b_events(inds(1:extra_events)) = 1;


% add noise to the system:
inds = find(~a_events);
tmp = randperm(length(inds));
inds = inds(tmp);
a_events(inds(1:noise_events)) = 1;

inds = find(~b_events);
tmp = randperm(length(inds));
inds = inds(tmp);
b_events(inds(1:noise_events)) = 1;


goodD = Dominance(a_events, b_events);

[p , D, allD]= Dominance_shoelace(a_events, b_events);

figure
subplot 211; stem(a_events); subplot(212); stem(b_events,'--r');hold off
figure
hist(allD);
title(sprintf('Dominance Null Distribution (Bootstrap)'))
xlabel('Dominance');
ylabel('Realizations');
fprintf(' %0.2f p= %0.04f',D, p);
dofontsize(16)