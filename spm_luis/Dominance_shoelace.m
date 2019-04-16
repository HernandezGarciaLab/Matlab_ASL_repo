function [p, D, allD]= Dominance_shoelace(a_events, b_events)
% function [p , D, allD]= Dominance_shoelace(a_events, b_events)
%
%   (c) Luis Hernandez-Garcia @ UM
%   11.29.2006
%   report bugs to: hernan@umich.edu
%
% This function takes two binary time courses and computes Dominance
% It then calculates the significance by randomly permuting the
% events at every time point and thus obtaining a null distribution.
% inference is done by comparing the calculated Dominance to the
% Null ditribution
%

NITER = 500;
DEBUG=0;

% compute the Dominance value:
[D thetas]= Dominance(a_events, b_events);
dependence = thetas(1) - thetas(2)*thetas(3);

allD = zeros(NITER,1);
tmp = zeros(size(b_events));

% Shuffle the pairs of samples one at a time and recompute DOminance
doFlip = zeros(1,length(a_events));
doFlip(1:end/2) = 1;

for iter=1 : NITER
    % decide at which time samples we swap the events between the channels
    randInds = randperm(length(a_events));
    doFlip(randInds) = doFlip;
    % DO the swapping:
    tmp = a_events;
    a_events(find(doFlip)) = b_events(find(doFlip));
    b_events(find(doFlip)) = tmp(find(doFlip));

    allD(iter) = Dominance(a_events,b_events);
    
    if DEBUG
        stem(a_events); hold on; stem(b_events,'--r'); 
        axis([-1 length(a_events)+1 -1 2]);
        drawnow; hold off
        title(sprintf('Dominance: %0.2f ',allD(iter)));
        pause
    end
end

% Null Distribution of Dominances
[h hd]= hist(allD,50);
binsize = hd(2)-hd(1);
% integral of the PDF
H = cumsum(h);
% normalize the Probability
H = H/H(end);

% look for the position of the computed Dominance relative to
% Null distribution.  Note that this is a two-tailed distribution,
% so we check to see if Dominance is very negative.
inds = find(hd >= D - binsize);

% p value: probability of getting Dominance to be equal or greater
% given the null distribution of Dominances
if isempty(inds)
    p=eps;
elseif D > 0
    p = 1 - H(inds(1)) + eps;
elseif D < 0
    p = H(inds(1)) + eps;
end

if DEBUG
    hist(allD,100);
    title(sprintf('D= %f, p = %f', D, p))
end

return
