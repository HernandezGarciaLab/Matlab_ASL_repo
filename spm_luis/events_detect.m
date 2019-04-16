%$Id: events_detect.m,v 1.1 2007/07/09 19:15:56 huizhang Exp $
function events = events_detect(X, hrfn)
% events_detect: detecting the events in the time courses
% X:     a time course
% hrfn:  hrf function which used for generating the time courses
% 
% eventsIndex: record the index of the events in the time courses
% numEvents : number of events within clusters
%       
% Function called
% ________________________________________________
% spm_smooth

co       = 0.95; %- constant for the 95% unit to count the number of events
%- smooth the time course
% sX       = zeros(length(X),1);
% spm_smooth(X,sX, FWHM); 
% 
% %- smooth the hrf funtion
% smoothrf = zeros(length(hrfn),1);
% spm_smooth(hrfn,smoothrf,FWHM); 

sX = X;
smoothrf = hrfn;

%- set a unit to detect number of events within a cluster
rules = sum(smoothrf.*(smoothrf>=mean(smoothrf)));
%- set those values under threshold to be 0
sXbool = sX >= mean(smoothrf);
sX     = sX.*sXbool;

listArea    = [];
eventsIndex = [];
numEvents   = [];
for (i = 1:length(sX)-1)
    if (sX(i) == 0 & sX(i+1) ~= 0)
        tmpArea = 0;
        flagmax = 0; %- number of local maximum counter
        j = i+1;     %- start counting
        
        while(sX(j) ~= 0)
            if (sX(j-1) <= sX(j) & sX(j) >= sX(j+1))
                %- add the index of local maximum in the events list
                eventsIndex = [eventsIndex j];
                flagmax    = flagmax + 1;
            end 
            
            %- calculate Area
            tmpArea = tmpArea + sX(j);
            if (j == length(sX))
                sX(j) = 0; %- attain the last element
            else
                j = j+1;
            end
        end 
        
        listArea  = [listArea tmpArea];
         %- count number of events in a cluster
        tmpevenum = round(tmpArea/(co*rules)); 
        %- record number of events within a time course
        numEvents = [numEvents tmpevenum];     
        
        if tmpevenum > 1, %- more events involved in a cluster
            [locmax indevents] = max(sX(i+1:j-1)); % find the index for local maximum 
            for ind = 1:tmpevenum-flagmax,
                eventsIndex = [eventsIndex indevents+i];
            end
        elseif tmpevenum == 0,
            %- count the maximum because of bias
            eventsIndex = eventsIndex(1:end-1);
        end 
        
        i = j;
    end 
end
eventsIndex = eventsIndex';
events = zeros(length(X),1);
events(eventsIndex) = 1;
