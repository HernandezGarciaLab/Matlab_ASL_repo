function [Pa_b, Pb_a, Pa, Pb, Pab ] = cprob02(a,b)
% function [Pa_b, Pb_a,  Pa, Pb, Pab ] = cprob02(a, b)
%
% (c) 2005 Luis Hernandez-Garcia 
% University of Michigan
% report bugs to:  hernan@umich.edu
%
% Find the conditional probability of A being in the aRange interval
% given that B is in the bRange interval
%
% this version takes a binary signal input (i.e- it's already been through
% the indicator function. Does not return a Joint histogram

% 
doPlots=0;


a = reshape(a,1,length(a));
b = reshape(b,1,length(b));

% calculate probability of A
a_event = find(a);
Pa = length(a_event) / length(a);

% calculate probability of B
b_event = find(b);
Pb = length(b_event) / length(b);

% calculate P(AB)
a2 = a(b_event);
ab_event = find(a & b );
Pab = length(ab_event) / length(a) ;
Pba = Pab;

% calculate P(A|B)
Pa_b = Pab/Pb;


% calculate P(B|A)
Pb_a = Pba/Pa;

return
