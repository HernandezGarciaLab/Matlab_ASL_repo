function tau = max_suppression()
%function tau = max_suppression(guess,  R)
% function result = suppression_lsq(guess, R)
%
% defines the longitudinal magnetization of a set of 3 tissue types
% after receiving the following sequence of pulses:
%
% 90-tau1-180-tau2-180-tau3-180-tau4-180-tau5
%
% the equation is 
% Mz = 1 - 2*exp(-R(1)* tau(1)) + 2*exp(-R(1)* tau(2)) ...
%         - 2*exp(-R(1)* tau(3) + 2*exp(-R(1)* tau(4) ...
%         - exp(-R(1)* tau(5)).... 

%      1  - 2*exp(-R(2)* tau(1)) + 2*exp(-R(2)* tau(2)) ...
%         - 2*exp(-R(2)* tau(3) + 2*exp(-R(2)* tau(4) ...
%         - exp(-R(2)* tau(5)) ...

%      1  - 2*exp(-R(3)* tau(1)) + 2*exp(-R(3)* tau(2)) ...
%         - 2*exp(-R(3)* tau(3) + 2*exp(-R(3)* tau(4)) 
%         - exp(-R(3)* tau(5)) 
%


% recommended T1 values for brains at 3 Tesla
% 
T1csf=2500e-3;	
T1blood=1500e-3;	% beware this T1 value is not accurate!
T1white=1100e-3;
T1gray=1400e-3;

R = [1/T1csf 1/T1white 1/T1gray];
guess = [0.5 1 1.5 2 2.5 ]; 

tau = guess;
stepsize = 10e-3;

M=3;

fprintf('\nstart M = %f   tau = %f %f %f %f ', M,tau(1), tau(2), tau(3), tau(4));
while abs(M) >0.05
    dMdTau = del_M(R,tau);
    if(signal(R, tau) > signal(R, tau + dMdTau.*stepsize))
        tau = tau + dMdTau.*stepsize ;
    else
        tau = tau - dMdTau.*stepsize ;
    end
    M = signal(R,tau);
    %fprintf('\rM = %f   tau = %f %f %f %f ',M,tau(1), tau(2), tau(3), tau(4));
end
fprintf('\nend M = %f   tau = %f %f %f %f ',M,tau(1), tau(2), tau(3), tau(4));
prep_time = max(tau)+1e-3;
seq_sim(prep_time-tau, prep_time*1e3);

return

function seq_sim(tau,nsteps)
% this function simulates the Mz during the process
    gamma=26752;		% rad / G s
    dt = 1e-3;
    B1=pi/(gamma*dt);	% one sample 180-degree pulse
    G2T=1e-4; s2ms=1000;	% conversions
    
    T1csf=2500e-3;	
    T1blood=1500e-3;	% beware this T1 value is not accurate!
    T1white=1100e-3;
    T1gray=1400e-3;
    
    T2csf=1500e-3;
    T2blood=160e-3;		% oxy blood ~ 160ms, deoxy blood ~ 50ms (rat data)
    T2white=90e-3;
    T2gray=110e-3;
    
    RF=zeros(nsteps,1);
    blnk=zeros(size(RF));

    RF(round(tau ./dt))= B1;
    RF(1)= 0.5*B1;

    RF = [RF blnk blnk];
    
    M0 = [0 0 1];
    Mcsf = blochsim2(M0, RF*G2T,  T1csf*s2ms, T2csf*s2ms, dt*s2ms, nsteps);
    Mwhite = blochsim2(M0, RF*G2T,  T1white*s2ms, T2white*s2ms, dt*s2ms, nsteps);
    Mgray = blochsim2(M0, RF*G2T,  T1gray*s2ms, T2gray*s2ms, dt*s2ms, nsteps);

    RF(1) =0;
    Mcontrol = blochsim2(M0, RF*G2T,  T1blood*s2ms, T2blood*s2ms, dt*s2ms, nsteps);
    M0 = [0 0 -1];
    Mtag = blochsim2(M0, RF*G2T,  T1blood*s2ms, T2blood*s2ms, dt*s2ms, nsteps);
    
    
    plot([Mcsf(:,3) Mwhite(:,3) Mgray(:,3) Mcontrol(:,3) Mtag(:,3)])
    legend('csf','white','gray','control','tag')
return

function dMdTau = del_M(R, tau)
    
    dMdtau = zeros(4,1);
    
    dMdTau(1) = ...
          2*R(1)*exp(-R(1)*tau(1)) ...
        + 2*R(2)*exp(-R(2)*tau(1)) ...
        + 2*R(3)*exp(-R(3)*tau(1));
    dMdTau(2) = ...
        - 2*R(1)*exp(-R(1)*tau(2)) ...
        - 2*R(2)*exp(-R(2)*tau(2)) ...
        - 2*R(3)*exp(-R(3)*tau(2));
    dMdTau(3) = ...
          2*R(1)*exp(-R(1)*tau(3)) ...
        + 2*R(2)*exp(-R(2)*tau(3)) ...
        + 2*R(3)*exp(-R(3)*tau(3));
    dMdTau(4) = ...
        - 2*R(1)*exp(-R(1)*tau(4)) ...
        - 2*R(2)*exp(-R(2)*tau(4)) ...
        - 2*R(3)*exp(-R(3)*tau(4));
    dMdTau(5) = ...
          R(1)*exp(-R(1)*tau(5)) ...
        + R(2)*exp(-R(2)*tau(5)) ...
        + R(3)*exp(-R(3)*tau(5));
    

return


function result = signal(R, tau)

 result = ...
      1 - 2*exp(-R(1)* tau(1)) + 2*exp(-R(1)* tau(2)) ...
         - 2*exp(-R(1)* tau(3)) + 2*exp(-R(1)* tau(4)) ...
         - exp(-R(1)* tau(5)) +... 
      1  - 2*exp(-R(2)* tau(1)) + 2*exp(-R(2)* tau(2)) ...
         - 2*exp(-R(2)* tau(3)) + 2*exp(-R(2)* tau(4)) ...
         - exp(-R(2)* tau(5)) + ...
      1  - 2*exp(-R(3)* tau(1)) + 2*exp(-R(3)* tau(2)) ...
         - 2*exp(-R(3)* tau(3)) + 2*exp(-R(3)* tau(4))... 
         - exp(-R(3)* tau(5))  ; 

return
