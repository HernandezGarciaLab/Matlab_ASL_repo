function [Pa_b, Pb_a, jh, Pa, Pb, Pab ] = cprob(a,aRange, b, bRange)
% function [Pa_b, Pb_a, jhist, Pa, Pb, Pab ] = cprob(a,aRange, b, bRange)
%
% (c) 2005 Luis Hernandez-Garcia 
% University of Michigan
% report bugs to:  hernan@umich.edu
%
% Find the conditional probability of A being in the aRange interval
% given that B is in the bRange interval

% 
doPlots=0;

if 0
    a = randn(1,1000);
    b = -2+randn(1,1000);
    aRange=[0.5 0.8];
    bRange=[0.4 0.6];
end

a = reshape(a,1,length(a));
b = reshape(b,1,length(b));

% calculate probability of A
a_event = find(a>aRange(1) & a< aRange(2) );
Pa = length(a_event) / length(a);

% calculate probability of B
b_event = find(b>bRange(1) & b< bRange(2) );
Pb = length(b_event) / length(b);

% calculate P(AB)
a2 = a(b_event);
ab_event = find(a2 > aRange(1) & a2 < aRange(2) );
Pab = length(ab_event) / length(a) ;

% calculate P(A|B)
Pa_b = Pab/Pb;

% calculate P(BA)...should be the same as P(AB)
b2 = b(a_event);
ba_event = find(b2 > bRange(1) & b2 < bRange(2) );
Pba = length(ba_event) / length(b) ;

% calculate P(B|A)
Pb_a = Pba/Pa;

%now do the joint histogram (pdf)
Nbins = 20;
jh = jhist(a,b,Nbins);

if doPlots
    imagesc(jh);
    %surf(jhist)
    xlabel('B')
    ylabel('A')
    amin = min([a b])
    amax = max([a b])
    a_delta = (amax - amin) / Nbins;

    mytixlabel = round([amin:a_delta*5:amax]*10)/10;
    mytix = 1:5:Nbins;
    set(gca,'XTick',mytix)
    set(gca,'YTick',mytix)
    set(gca,'XTickLabels',mytixlabel)
    set(gca,'YTickLabels',mytixlabel)
    hand=line([0 Nbins],[0 Nbins])
    set(hand,'LineWidth',4,'Color','white')
    colorbar
end
return
