
%DYNAMIC BUXTON MODEL SIMULATION

%%version 5a added the capability to simulate the effect of saturation due to imaging the slices not being complete 
%%version 5b fixed bug in decay function
%%version w/ ms has multislice capability

%note: signal of the static tissue is not plotted.  Only the signal of the difference image. the static tissue component's magnitude will depend mainly on the TR and flip angle used for the imaging pulses

clear all;  close all;

%Constants for the Buxton Model
Mob=3000;      %initial magnetization of the brain
f = 0.01; % 0.01s-1 corresponds to 60ml/100g/min 
alpha = 0.9;  %degree of inversion (rages from 0 to 1)
T1a = 1.5;  %T1 of arterial blood in s
T1b = 1.6;  %T1 of brain in s
rho=1;    %water extraction fraction (a number between 0 and 1)
lamda = 0.9;  %blood brain partition coefficient
model=1;

T1eff = 1/(f/lamda+1/T1b);      


showold=0;  %Also show the old version of the model without saturation of the tag due to imaging and with no flow or TT changes


maxindex=5;
for index=1:maxindex   %This loops through different choices of TR

    clear vec answer* analytic* flow_rates newc* transit_times newtimes label c

    %%SET UP THE DYNAMICALLY CHANGING FLOW AND TT PARAMETERS %%%

    baseflow=f;
    percentFlowincrease=0.5;  %1 = 100%
    percentTTdecrease=0.1;

    flowinc=percentFlowincrease*f;
    %flowinc=0;
    baseTT=1.6;
    TTdecrease=percentTTdecrease*baseTT+0.001;  %Make it be the desired value plus some small offset 0.0001 etc to avoid an error with interp1
    %TTdecrease=0;

    if(index==1)  TR=baseTT+TTdecrease;    mystyle='b'; end;   %This is a very poor choice if TT decreases
    if(index==2)  TR=baseTT+TTdecrease/2;  mystyle='g'; end;
    if(index==3)  TR=baseTT;               mystyle='r'; end;   %This is the normal choice
    if(index==4)  TR=baseTT-TTdecrease/2;  mystyle='c'; end;
    if(index==5)  TR=baseTT-TTdecrease;    mystyle='m'; end;   %This is a decent choice when TT decreases

    %Sequence parameters        
    nslices=3;
    slicetime=0.05;  %Time to acquire a slice (ms)
    imaging_time=slicetime*nslices;
    TE=0.012;

    t_delay=0.004;  %delay after tagging before Image acquisition in s
    TE=0.012;

    sim_duration = 80;  %Desired duration of the simulation (s)

    %set the appropriate number of TRs to simulate the first time through
    %the loop
    if(index==1)
    nTR=2*round(round(sim_duration/(TR-2*TTdecrease))/2);  %number of repetitions  (choose the multiple of 2*TR closest to sim_duration
    end

    tag_duration = TR-imaging_time-t_delay;  %duration of tag in s
    dt=1e-2;  %time step size for simulation


    %       time=[0:dt:TR];
    total_time=[0:dt:TR*nTR];    %Time vector for the simulation


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %The following 4 forms of the flow and transit times are available
    %(only choose 1 at a time)

    block=1;         %Use this for a step change in flow/TT

    sinefunc=0;  %Use this for a sinusoidal change in flow/TT
    sineper=10;  %period of the sine wave reference function in seconds...

    linear_ramp=0;  %This is for a linear ramp in flow/TT    
    sf=1;  %steepness of ramp

    gammafun_ref=0;  %Use a gamma function shaped change in flow/TT
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    %This If statement implements the chosen flow/TT change paradigm...
    if(block)
        ontime=16;  offtime=50;
        flow_rates=baseflow*ones(1,length(total_time))+flowinc*(total_time>ontime).*(total_time<offtime).*ones(1,length(total_time));
        transit_times=baseTT*ones(1,length(total_time))-TTdecrease*(total_time>ontime).*(total_time<offtime).*ones(1,length(total_time));    
    elseif(sinefunc)
        ontime=sineper;  offtime=80;
        flow_rates=baseflow*ones(1,length(total_time))+flowinc*(total_time>ontime).*(total_time<offtime).*sin(total_time*pi/(sineper/2));
        transit_times=baseTT*ones(1,length(total_time))-TTdecrease*(total_time>ontime).*(total_time<offtime).*sin(total_time*pi/(sineper/2));    
    elseif(linear_ramp)
        ontime=8;  offtime=80;
        flow_rates=baseflow*ones(1,length(total_time))+flowinc*(total_time>ontime).*linspace(-0.5,2*sf,length(total_time));
        transit_times=baseTT*ones(1,length(total_time))-TTdecrease*(total_time>ontime).*linspace(-0.5,2*sf,length(total_time));
    elseif(gammafun_ref)
        ontime=10;  gammafun_width=0.8;
        flow_rates=baseflow*ones(1,length(total_time))+flowinc*gammafun(total_time,ontime,gammafun_width)';
        transit_times=baseTT*ones(1,length(total_time))-TTdecrease*gammafun(total_time,ontime,gammafun_width)';            
    end

    %This can be used for plotting purposes.  Not used in the computation
    label=zeros(size(total_time));
    for q=1:nTR
        if(mod(q,2))
            label=label+(total_time>(q-1)*TR).*(total_time<=(q-1)*TR+tag_duration); %when the RF is turned on
        else
            label=label;
        end
    end


    %This is the standard Buxton model square wave c(t)
    c=zeros(size(total_time));
    for q=1:nTR
        if(mod(q,2))
            c=c+(total_time>=baseTT+(q-1)*TR).*(total_time<=tag_duration+baseTT+(q-1)*TR);
        else
            c=c;
        end
    end

    newc2=c.*flow_rates/baseflow;  %Weight c(t) by the flow rate...

    %The next two lines use interpolation to try and implement a
    %transit time shift
    newtimes=total_time-transit_times+baseTT;
    newc=interp1(total_time,c,newtimes,'linear').*flow_rates/baseflow;  


    %SUMMARY:  
    % c = standard Buxton c(t)   (not used in this simulation)
    % newc2 = c(t) that has dynamic flow changes, but no TT change
    % newc = c(t) with both dynamic flow and TT changes


    %Choose the amount of saturation due to image acquisition
    satfactor=0;  %0 = full saturation.  1 = no saturation
    %Changing the satfactor will mainly just change the amplitude of the resulting signal


    answer=zeros(1,length(total_time));   %Flow and Transit Time change answer
    answer2=zeros(1,length(total_time));  %Flow change only answer


    %Implement the convolution piecewise for each TR and then add
    %together
    for q=1:nTR
        clear r m decay

        low=floor((q-1)*TR/dt)+1;  %Time point for the beginning of the TR
        high=floor((q)*TR/dt)+1;   %Time point for the end of the TR

        r=exp(-flow_rates(low:end).*(total_time(low:end)-total_time(low))/lamda);  %residue function of Buxton model
        m=rho*exp(-(total_time(low:end)-total_time(low))/T1b);   %T1 decay function of Buxton model

        r((high-low):end)=satfactor*r((high-low):end);  %Implement the saturation due to imaging at the TR

        decay=r.*m;              %combined T1 and outflow decay function

        %Implement the decay during transit to the slice
        newc_piece=newc(low:high).*alpha.*exp(-transit_times(low:high)./T1a);  %TT and flow change case
        newc2_piece=newc2(low:high).*alpha.*exp(-baseTT/T1a);  %case with flow change but no TT change

        %Implement the convolution
        answer_piece=2.*Mob.*flow_rates(1).*dt.*conv(newc_piece,decay);
        answer2_piece=2.*Mob.*flow_rates(1).*dt.*conv(newc2_piece,decay);

        %Add the piece to the total solution
        answer(low:end)=answer(low:end)+answer_piece(1:(1+(length(total_time)-low)));      %TT and flow change case
        answer2(low:end)=answer2(low:end)+answer2_piece(1:(1+(length(total_time)-low)));   %case with flow change but no TT change

        %Used for testing purposes
        %             figure(2),
        %             subplot(131),plot(total_time(low:end),r)
        %             subplot(132),plot(total_time(low:end),m)
        %             subplot(133),plot(total_time(low:end),decay)
        %             figure(3),plot(total_time(low:end),answer_piece(1:(1+length(total_time)-low)))
        %             figure(4),plot(total_time(low:high),newc_piece)
        %             drawnow
        %             pause
        %             
    end

    if(showold)        
        %This is the old version of the model without any transit time or
        %flow change and no saturation due to imaging...
        %        if(model==1)
        clear r m decay r2 decay2
        %I don't go out to the full length of time here to save computation to w/
        %negligable error...
        r2=exp(-flow_rates(1).*total_time(1:round(4*T1b/dt))/lamda);
        m=rho*exp(-(total_time(1:round(4*T1b/dt))/T1b));
        c=c.*alpha.*exp(-baseTT/T1a);
        decay2=r2.*m;
        answer3=2.*flow_rates(1).*Mob.*conv(c,decay2).*dt;
    end

    %Make the vector of timepoints at which image acquisition occurs    
    for slice=1:nslices
        for q=1:nTR
            vec(slice,q)=(tag_duration+t_delay+(slice-1)*slicetime+TE+(q-1)*TR)/dt;
        end
    end


    %Plot the signal verses time
    if(index==3)
        figure(1)
        if(showold)
            plot(total_time,answer(1:length(total_time)),total_time,answer2(1:length(total_time)),total_time,answer3(1:length(total_time)))
        else
            plot(total_time,answer(1:length(total_time)),total_time,answer2(1:length(total_time)))
        end
        %plot(total_time, answer(1:length(total_time)),total_time, label*max(answer)/1.5,'.-')
        hold on
        p=plot(round(vec(1,:))*dt,answer(round(vec(1,:))),'bx'); axis tight;
        set(p,'MarkerSize',10,'LineWidth',2);
        p=plot(round(vec(1,:))*dt,answer2(round(vec(1,:))),'gx'); axis tight;
        set(p,'MarkerSize',10,'LineWidth',2);
        stem(total_time(floor([0:TR:(TR*nTR)]/dt)+1),(round([0:TR:(TR*nTR)]/dt)>0.001)*20,'k:')
        title('Temporal Dynamics of the Signal','FontSize',14,'FontWeight','bold')
        xlabel('time(s)')
        hold off
        axis tight
        drawnow
    end

    %Create vectors to store the averaged difference signal in...
    adiff1=zeros(length(vec),maxindex); 
    adiff2=zeros(length(vec),maxindex); 
    if(showold)
        adiff3=zeros(length(vec),maxindex);
    end

    slicestoavg=[1:nslices];  %Choose which slices to average for the resulting signal plot

    for slice=[slicestoavg]
        tmp1c(:,index)=(answer(round(vec(slice,1:2:end))))';  %The control time points  (flow and TT change)
        tmp1t(:,index)=(answer(round(vec(slice,2:2:end))))';  %The tag time points

        tmp2c(:,index)=(answer2(round(vec(slice,1:2:end))))'; %The control time points  (flow change only)
        tmp2t(:,index)=(answer2(round(vec(slice,2:2:end))))'; %The tag time points

        %interpolate the control and tig timeseries before subtraction
        tmp11c(:,index)=interp1(vec(slice,1:2:end),tmp1c(:,index)',vec(slice,:),'cubic')';  
        tmp22c(:,index)=interp1(vec(slice,1:2:end),tmp2c(:,index)',vec(slice,:),'cubic')';

        tmp11t(:,index)=interp1(vec(slice,2:2:end),tmp1t(:,index)',vec(slice,:),'cubic')';
        tmp22t(:,index)=interp1(vec(slice,2:2:end),tmp2t(:,index)',vec(slice,:),'cubic')';

        if(showold)  
            tmp3c(:,index)=(answer3(round(vec(slice,1:2:end))))';    
            tmp3t(:,index)=(answer3(round(vec(slice,2:2:end))))';    

            tmp33c(:,index)=interp1(vec(slice,1:2:end),tmp3c(:,index)',vec(slice,:),'cubic')';
            tmp33t(:,index)=interp1(vec(slice,2:2:end),tmp3t(:,index)',vec(slice,:),'cubic')';

            adiff3(:,index)=adiff3(:,index)+tmp33t(:,index)-tmp33c(:,index);
            diff3(:,index)=tmp33t(:,index)-tmp33c(:,index);
        end


        %This is the control/tag pair subtraction for an individual slice
        diff1(:,index)=tmp11t(:,index)-tmp11c(:,index);
        diff2(:,index)=tmp22t(:,index)-tmp22c(:,index);

        %These two lines compute the average signal over the chosen slices
        adiff1(:,index)=adiff1(:,index)+diff1(:,index);
        adiff2(:,index)=adiff2(:,index)+diff2(:,index);


        %Plot results for each individual slice and each individual TR 
        figure(2)
        subplot(maxindex,nslices,slice+nslices*(index-1))
        eval(sprintf('str=''Slice%d'';',slice));
        eval(sprintf('str2=''TR=%03g'';',TR));

        plot(total_time(round(vec)),diff1(:,index),'b')
        if(index==1)
            title(str,'FontSize',14,'FontWeight','bold')
        end
        if(slice==1)
            ylabel(str2,'FontWeight','bold')
        end

        hold on
        plot(total_time(round(vec)),diff2(:,index),'g')
        if(showold)    
            plot(total_time(round(vec)),diff3(:,index),'r')
        end

        %plot(total_time(round(vec)),flow_rates(round(vec))*1400,'k','LineWidth',2),axis tight
        plot(total_time,flow_rates.*(diff2(5,index)./flow_rates(5)),'k','LineWidth',2),axis tight
        hold off

    end


    adiff1=adiff1./length(slicestoavg);      
    adiff2=adiff2./length(slicestoavg);       
    if(showold)
        adiff3=adiff3./length(slicestoavg);
    end

         %Plot the average signal over the slices for the different TRs
         figure(3)
         subplot(maxindex,1,index)
         plot(total_time(round(vec(round(nslices/2),:))),adiff1(:,index),total_time(round(vec(round(nslices/2),:))),adiff2(:,index))
         hold on
         if(showold)
            plot(total_time(round(vec(round(nslices/2),:))),adiff3(:,index),'r')
         end
         if(index==1)
            title('Average Signal Over All Slices','FontSize',16,'FontWeight','bold')
            myl=legend('Flow and TT Change (blue)','Flow Change Only (green)')
            set(myl,'FontSize',10,'FontWeight','bold')
         end
         eval(sprintf('str2=''TR=%03g'';',TR));
         ylabel(str2,'FontWeight','bold')
         plot(total_time,flow_rates.*(diff2(5,index)./flow_rates(7)),'k','LineWidth',2),axis tight
         hold off

end

    %Visualize the modified and unmodified labeling functions
    figure(5),plot(total_time,newc,'b',total_time,newc2,'g',total_time,transit_times,'m');
    title('c(t) with and without TT changes')
    xlabel('time (s)')
    ylabel('c(t) (for the final iteration)')
    legend('flow and TT change c(t)','flow change only c(t)','TT change waveform')
