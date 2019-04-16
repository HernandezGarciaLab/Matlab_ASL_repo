
parms = [  2 1 2 ];
t=[0:0.5:10];


alpha = 0.8;
Mob=5000;
T1b=1;


Tau_guess = 1;
Mobf_guess = 1;
dt_guess = 2;

guess0 = [  Tau_guess Mobf_guess dt_guess ];
guess_max = [50   50   50];
guess_min = [1    1    1];

optvar=optimset('lsqnonlin');
optvar.TolFun=1e-15;
optvar.TolX=1e-15;
optvar.MaxIter=600;
optvar.Display='iter';

m = FAIR_lsq( parms , ...
    t, ...
    alpha,  T1b);


guess = lsqnonlin('FAIR_lsq',...
    guess0, guess_min, guess_max, ...
    optvar,...
    t, ...
    alpha, T1b, ...
    m);


m2 = FAIR_lsq( guess, ...
    t, ...
    alpha,  T1b);
            
            
plot(t,m,'*', t,m2);
