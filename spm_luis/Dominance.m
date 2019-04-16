function [dominance, thetas] = Dominance(a_events, b_events)
% function [dominance, thetas] = Dominance(a_events, b_events)
%
%   (c) Luis Hernandez-Garcia @ UM
%   11.22.2006
%   report bugs to: hernan@umich.edu
%
% Computes Dominance from two binary time courses (a_events to b_events)
% using the conditional probabilities.
%
% dominance calculation:  D = P(b|a) - P(a|b)
%
N = length(a_events);
thetas = zeros(1,4);
Nevents = zeros(1,4);

Nevents(1) = sum(a_events & b_events);
Nevents(2) = sum(a_events & ~b_events);
Nevents(3) = sum(~a_events & b_events);
Nevents(4) = sum(~a_events & ~b_events);

Ntotal = sum(Nevents(1:3));

thetas = Nevents / N;

% My dominance calculation:  P(b|a) - P(a|b)
Pab = thetas(1);
% P(b|a) = P(ab) / P(a)
Pb_a  = thetas(1) / (thetas(1) + thetas(2));

% P(a|b) = P(ab) / P(b)
Pa_b  = thetas(1) / (thetas(1) + thetas(3));
dominance = (Pb_a - Pa_b);
%dominance = (Pb_a - Pa_b)/Ntotal;

return
