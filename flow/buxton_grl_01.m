
%This simulation is set up to loop through different choices of TR/tag duration for a fixed transit time
%It also has an option to loop through this process for multiple transit times
%The temporal dynamics of the perfusion response to labeling are goverened by the modified Buxton model;

%note: signal of the static tissue is not plotted.  Only the signal of the difference image. the static tissue component's magnitude will depend mainly on the TR and flip angle used for the imaging pulses

clear c c2 answer1 answer2 vec signal

model=1;   %ASL input function to use  (1=boxcar, 2=boxcar*exp, 3=boxcar*gaussian)


%Constants for the Buxton Model
Mob=3000;      %initial magnetization of the brain
f = 0.015; % 0.01s-1 corresponds to 60ml/100g/min 
alpha = 0.9;  %degree of inversion (rages from 0 to 1)
T1a = 1.2;  %T1 of arterial blood in s
T1b = 1.6;  %T1 of brain in s
rho=1;    %water extraction fraction (a number between 0 and 1)
lamda = 0.9;  %blood brain partition coefficient
T1eff = 1/(f/lamda+1/T1b);

maxindex=57;   %number of iterations
increment=0.1; %increment to TR & t_tag on each iteration

%maxindex2=8;
%for (index2=1:maxindex2),


tag_durations=[0.02:0.02:1 1.05:0.05:3 3.2:0.2:5];
%tag_durations=0.1:0.1:4;



TE=0.012;   %TE in ms
nslices=1;  %# of slices


imaging_time=nslices*0.05  %Time required for image acquisition (ms)


tts=[1.5];  %Vector of transit times

for ttindex=1:length(tts)   %Loop through different Transit Times

    for index=1:length(tag_durations)   %Loop through different tag durations

        clear vec

        transit_time = tts(ttindex);          %transit time in s
        tag_duration = tag_durations(index);  %duration of tag in s

        %Scan parameters 

        t_delay=0.004;  %delay after tagging before Image acquisition in s
        TR = tag_duration+t_delay+imaging_time;  %repetition time in s

        const1=2*Mob*f*T1eff*alpha*exp(-transit_time./T1a);  %This same constant is present in all cases below

        %simulate an appropriate number of TRs to reach steady-state
        if(TR<=0.5)
            nTR=20;
        elseif(TR<=1.5)
            nTR=12;
        elseif(TR<=2.5)
            nTR=8;
        elseif(TR<=3.5)
            nTR=6;
        else
            nTR=4;
        end

        dt = 1e-3;      %time step size of simulation in s
        %        time=[0:dt:TR];
        total_time=[0:dt:TR*nTR];  %overall time vector for the experiment


        %Make the labeling function for plotting purposes  (Not used in the
        %computation)
        label=zeros(size(total_time));  
        for q=1:nTR
            if(mod(q,2))
                label=label+(total_time>(q-1)*TR).*(total_time<=(q-1)*TR+tag_duration);
            else
                label=label;
            end
        end

        %The analytical solution
        myratio=transit_time/TR;  
        temptime=(myratio-floor(myratio))*TR;     %time from the beginning of the TR until the tag starts to arrive
        analytic_time=0:dt:TR*(ceil(myratio)+1);  %Simulate up through the last TR where new tag arrives.
        analytic=zeros(size(analytic_time));     

        %These are the two cases of the analytic solution
        if((temptime+tag_duration)<TR)             %Case when all the tag arrival falls within a single TR
            %   str=sprintf('case31'); display(str);
            analytic=analytic+...
                (analytic_time>=transit_time).*(analytic_time<=transit_time+tag_duration).*(const1.*(1-exp(-(analytic_time-transit_time)./T1eff)))...
                +(analytic_time>transit_time+tag_duration).*(analytic_time<(ceil(myratio)*TR)).*(const1.*exp(-(analytic_time-transit_time-tag_duration)./T1eff).*(1-exp(-(tag_duration./T1eff))));
        elseif((transit_time+tag_duration)>=TR)    %Case when the tag arrival is spread over 2 TRs
            %   str=sprintf('case32'); display(str);
            analytic=analytic+...
                (analytic_time>=transit_time).*(analytic_time<=transit_time-temptime+TR).*(const1.*(1-exp(-(analytic_time-transit_time)./T1eff)))...
                +(analytic_time>transit_time-temptime+TR).*(analytic_time<=transit_time+tag_duration).*(const1.*(1-exp(-(analytic_time-transit_time+temptime-TR)/T1eff)))...
                +(analytic_time>transit_time+tag_duration).*(const1.*exp(-analytic_time./T1eff).*(exp((transit_time+tag_duration)/T1eff)-exp((transit_time-temptime+TR)./T1eff)));
        end  

        %The analytical solution is identical for each pair of TRs when 100% saturation of the tag due to
        %image acquisition is assumed

        %Therefore the next few lines just replicate this analytical
        %solution for the desired number of TRs for plotting
        %purposes...
        analytic2=analytic(end-(round(2*TR/dt)):end); 
        for tmpj=1:((nTR+1-(ceil(myratio)+1))/2)      %I put an extra +1 in here to avoid an error that occasionally occured
            analytic2=[analytic2 analytic2];
        end
        analytic2=[analytic(1:end-(round(2*TR/dt)+1)) analytic2];

        answer=analytic2;

        %Compute the timepoints where each images are acquired       
        for slice=1:nslices
            for q=1:nTR
                vec(slice,q)=(tag_duration+t_delay+TE+(slice-1)*0.045+(q-1)*TR)/dt;
            end
        end

        %The commented lines below will plot the label, and signal verses
        %time for a given TR/tag duration choice.
%         
%                 plot(total_time, answer(1:length(total_time)),total_time, label*max(answer)/1.5,'.-')
%                 hold on
%                 p=plot(vec*dt,answer(round(vec)),'rx'), axis tight;
%                 set(p,'MarkerSize',10,'LineWidth',2);
%                 hold off
%                 drawnow
%         

        a_tmp=0;
        %This loop averages the signal over the slices  
        for nindex=1:nslices 
            a_tmp=a_tmp+diff(answer(round(vec(nindex,:))));  %Diff to subtract tag/control
        end
        signal(ttindex,index)=a_tmp(end-1)/nslices;  %Just use the value at the final TR pair since this is the steady state result
        %signal(index)=tmp([end-1]);

    end

end

%Normalize by the amplitude of the first slice
%signal=signal./max(abs((signal(1,:)')));

figure
plot((tag_durations+t_delay+imaging_time),(signal.'),'LineWidth',2),grid on,
%   plot((tag_durations+t_delay+imaging_time),(signal.')/max(abs(signal)),Ttagvals+imaging_time, -meanASL_art./max(abs(meanASL)),Ttagvals+imaging_time, -meanASL_tis./max(abs(meanASL)),Ttagvals+imaging_time, -meanASL./max(abs(meanASL)),'LineWidth',2),grid on,
%   legend('Buxton', 'Luis Arterial', 'Luis Tissue', 'Luis Total')
xlabel('TR','FontSize',15,'FontWeight','bold')
ylabel('Perfusion Signal (a.u.)','FontSize',15,'FontWeight','bold')
title('Perfusion Signal vs TR','FontSize',14,'FontWeight','bold')

%axis([0 5 -20*1.5 75])
axis tight
TR = (tag_durations+t_delay+imaging_time);
hold on
plot((tag_durations+t_delay+imaging_time), signal./sqrt(TR),'g','LineWidth',2),grid on,

legend('signal','SNR after averaging');

%f1=gca;
%set(f1,'FontSize',14,'FontWeight','bold')

%save trends2.mat signal tag_durations imaging_time t_delay

