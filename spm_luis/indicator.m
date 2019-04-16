function [events] = indicator (signal, threshold, binsize)
%
% function [events] = indicator (signal, threshold, binsize)
%
% (c) 2005 Luis Hernandez-Garcia 
% University of Michigan
% report bugs to:  hernan@umich.edu
%
% this function checks to see where the signal is 
% 1) above threshold* STD(signal)    _AND_
% 2) there is a local maximum (small derivative). 
%    we call a derivative small if it's below 0.5 STD of the
%    derivatives.
%
% it returns a binary signal indicating when events occurred.
%

signal= reshape(signal,length(signal),1);
threshold = threshold * std(signal);

% check to see if the bins are above threshold:
events = zeros(length(signal), 1);
events(find(signal>=threshold)) = 1;
events(find(signal<threshold)) = 0;

% check to see if the bins are above threshold:

% check to see if this could be a max
%first derivative mustbe near zero:
derivs = zeros(size(events));
derivs(2:end-1)= (signal(3:end) - signal(1:end-2))/2;
maxmin = find(abs(derivs) <  0.5*std(derivs));
ders = zeros(size(events));
ders(maxmin) = 1;
% second derivative is negative:
derivs2 = zeros(size(events));
derivs2(2:end-1)= (derivs(3:end) - derivs(1:end-2))/2;
ders2 = zeros(size(events));
ders2(derivs2 <  -0.5*std(derivs2))=1;
% combine both conditions:
events = events & ders & ders2;
if 0
	subplot(411), stem(events)
	subplot(412), stem( ders)
	subplot(413), stem(ders2)
	subplot(414),plot(signal) 
	pause
end
% re-bin the data.  This could be a bad idea 
nghb = floor(binsize/2);
events = events';
tmp = [zeros(1,nghb) events  zeros(1,nghb)] | ...
      [zeros(1,nghb)  zeros(1,nghb) events] | ...
      [events zeros(1,nghb)  zeros(1,nghb)];
tmp = tmp(nghb+1:end-nghb);
tmp =tmp(1:binsize:end);
events = tmp;
return
