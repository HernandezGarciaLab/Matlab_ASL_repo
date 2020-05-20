 GAMMA_H1=26754; %rad/s/Gauss  
 dt = 1e-6 ; %us
 
 G=[linspace(0,1,300)';
     ones(3000,1);
     linspace(1,0,300)';
     zeros(50,1);
     -linspace(0,1,300)';
     -ones(3000,1);
     -linspace(1,0,300)';
     ];
 
 t=[0:length(G)-1]' * 1e-6; % s
 
 plot(t,G)
 
 mom = 4*sum(G.*t) * dt % in G*s
 
 venc = 2*pi/(GAMMA_H1 * mom) 
 
 