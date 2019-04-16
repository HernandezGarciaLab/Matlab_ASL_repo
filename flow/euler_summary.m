warning off
load CASL
whos ASL
CASL = ASL/ASL(end-2);
tCASL = tASL;

f_event = f;
tf = tvec;


load turboCASL
turboCASL = ASL/ASL(end-2);
tTurboCASL = tASL;


load FAIR
tFAIR = tASL;
FAIR = ASL/ASL(end-2);


plot(tCASL, 100*CASL, ...
    tTurboCASL,100* turboCASL , ...
    tFAIR, 100*FAIR, ...
    tf, 100*f_event/f_event(end))
    %tFAIR, 100*FAIR, ...

legend('CASL', 'turbo-CASL' , 'FAIR', 'True Flow',0)
title('Modeled ASL responses')
xlabel('Time (sec.)')
ylabel('Normalized signal (%)')
%axis([0 100 -150 150])
fatlines
dofontsize(16)


