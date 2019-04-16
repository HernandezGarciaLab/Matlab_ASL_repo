function sampled_IR(alpha, theta, TR, delay, T1)

% sampled_IR.m
%
% Simulation of what happens to spins after inversion followed by
% a bunch of pulses at a flip angle theta.  This is the case in an ASL experiment, where 
% the spins are inverted once, and sampled a few milliseconds later with
% a 3D sequence
%
% Parameters:    -- (use miliseconds and radians for units)---
%   alpha:  The inversion efficiency of the labeling pulse 
%   theta:  The flip angle of the 3D sequence
%   TR:     Repetition time of the acquisition sequence
%   delay:  The time it takes the spins to travel from the inversion 
%           plane to the slab of interest
%   T1:     longitudinal relaxation rate

if nargin ~= 5
   
   alpha = 0.85;
   theta = pi/6 ;  % 30 degrees
   TR = floor(2000/16);
   delay = 150;
   T1 = 1200;
      
end

POINTS = 1500;

M = zeros(POINTS,1);
M(1) = 1 - 2*alpha;    %  this is the starting magnetization of the spins (determined by alpha)
pulse_time = delay;


% T1 decay with the theta pulses
for i=2:POINTS
   
   % this is where we apply the theta pulse to sample the magnetization
   if i == pulse_time
      M(i-1) = M(i-1)* cos(theta);
      pulse_time = pulse_time + TR;
   end
   
   M(i) = M(i-1) - (M(i-1)-1)/T1;
   
end
hold off
subplot 211, plot(M)
MM = M;


%  Regular T1 decay
M(1) = 1 - 2*alpha;  
for i=2:POINTS
   M(i) = M(i-1) - (M(i-1)-1)/T1;
end
hold on
subplot 211, plot(M,'red')

%  Regular T1 decay
M(1) = 1 - 2*alpha;  
for i=2:POINTS
   M(i) = M(i-1) - (M(i-1)-1)/(T1 );
end
hold on
subplot 211, plot(M,'g')

% Difference between theta pulses and normal decay ...
diff = M - MM;
subplot 212, plot(diff)