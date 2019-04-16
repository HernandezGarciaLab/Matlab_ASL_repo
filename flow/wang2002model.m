


Ttrans = 1;
f = 50/6000;
T1app = 1.4;
pid = 0.7;
Ttag = 1.5;
inv_alpha = 0.85;
M0 = 1000;
lambda = 0.9;
T1a = 1.6;

% wang 2003
deltaM1 =  2 * M0* f* inv_alpha * T1a / lambda ...
    * ( exp( -pid/T1a ) - exp( -(Ttag+pid)/T1a))


%wang 2002
deltaM2 =  2 * M0* f* inv_alpha/lambda * ...
    (( exp( -Ttrans/T1a )*T1app* (exp( min([Ttrans,Ttag])/T1app) - exp((Ttrans -pid - Ttag)/T1app)) + ...
    T1a*(exp((min([Ttrans-pid, 0])-Ttrans)/T1a) - exp((min([Ttrans-pid, 0])-Ttrans)/T1a))))
