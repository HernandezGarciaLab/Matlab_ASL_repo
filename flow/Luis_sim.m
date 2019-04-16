%A second-order scdxeme 2/10/2004

%Set up a grid
%A(x,t)

J = 200; N = 400;      %number of temporal(N) and spatial(J) pts
A = zeros(J,N);    
dx=.25; %spatial step (cm)
dx=1;
dt=.25; %temporal step (seconds)
R = 0.025; %decay rate

v = ones(1,N)/2;
v([200:250])= .8;
v=conv(v,ones(1,32)/32);
v = v*5;

A(:,1) = 0;
A(:,2) = 0;
A(1,:) = 0;
A(1,[100:200])=1;
A(2,:) = A(1,:);

for n=2:N-1    %temporal loop
    for j = 2:J-1  %spatial loop
        Ax = (A(j+1,n)-A(j-1,n))/2/dx;
        Axx = (A(j-1,n)-2*A(j,n)+A(j+1,n))/dx/dx;
        At = -v(n)*Ax-R*A(j,n);
        vt = (v(n+1)-v(n-1))/2/dt;
        
        %Step forward in time
        %It is like a Lax-Wendroff scdxeme 
        A(j,n+1) = A(j,n) + (dt-R*dt*dt/2)*At + dt*dt*v(n)*v(n)*Axx/2 + (dt*dt*v(n)*R/2 - dt*dt*vt/2)*Ax;
        
    end
end

imagesc([dt:dt:dt*N],[dx:dx:dx*J],A);    
colorbar;
xlabel('time (seconds)');
ylabel('space (cm)');
