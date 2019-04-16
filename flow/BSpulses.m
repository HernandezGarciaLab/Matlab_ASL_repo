clear
R1a = 1/1.6;
R1g=1/1.4;
R1w=1/0.9;
R1csf = 1/2.4;


do7t = 0;
if do7t
    R1a = 1/2.3;
    R1=1/2;
    R1csf = 1/4.3;
    
end



tag_length = 1.8;  % 1.6 duration of labeling train
tag_delay = 1.8;
% define transit time as the time elapsed between tagging and acquisition
% t_transit = [0.1:0.1:1.6];
% time at which spins actually get tagged (depends on their transit time)
tag_time = [0:0.1:1.6];
tag_time = tag_length;



if do7t
    tag_delay = 0.3;
    tag_length = 2.5;
    interval = [0.005:0.02:tag_delay];
    interval = 0.3
    tag_time = 1;
end

interval1=[0:0.1:tag_delay];
interval2=[0:0.1:tag_delay];


% % TR = 3000 (tag_duration = 0.7)
%  interval1 = 1.
%  interval2 = 0.5
% % TR = 4000 (tag_duration = 1.7)
%  interval1 = 1.1
%  interval2 = 0.4

AQtime = 1e3*(tag_length + tag_delay);
asl=ones(length(interval1), length(interval1));
bkgnd1=asl;
bkgnd2=asl;
bkgnd3=asl;
%for nt = 1:length(tag_time)
for n1 = 1:length(interval1)
     

    for n2=1:length(interval2)
        
        a = tag_length;
        b = a + interval1(n1);
        c = b + interval2(n2);
        
        %%
        % Shin's schemes
        %       a = 3.2 - 1.58;
        %       b = 3.2 - 0.13;
        
        %         a = 3.2 - 0.98;
        %         b = 3.2 - 0.127
        %          a = inf;
        %          b = inf;
        %%
        % This scheme seems to be very robust over many T1 values
        %         a = 3.2 - 1.1;
        %         b = 3.2 - 0.1;
        %%
        
        dt=1e-3;
        mcsf(1) = 0;
        mg(1) = 0;
        mw(1) = 0;
        
        ma(1)= 1;
        mat(1)= -1;
        
        for n=2:AQtime
            dmg =  (1 - mg(n-1))*R1g;
            mg(n) = mg(n-1) + dmg*dt;
            
            dmw =  (1 - mw(n-1))*R1w;
            mw(n) = mw(n-1) + dmw*dt;
            
            dmcsf =  (1 - mcsf(n-1))*R1csf;
            mcsf(n) = mcsf(n-1) + dmcsf*dt;
            
            dma =  (1 - ma(n-1))*R1a;
            ma(n) = ma(n-1) + dma*dt;
            
            dmat =  (1 - mat(n-1))*R1a;
            mat(n) = mat(n-1) + dmat*dt;
            
            % at the end of the tagging we make sure the arterial spins are inverted
            if abs(n*dt)< tag_time
                ma(n) = 1;
                mat(n) = -1;
            end
            
            % inversion pulse applied to the whole brain and the artery
%             if abs(n*dt -a)< (dt/2)
%                 mcsf(n) = -mcsf(n);
%                 mg(n) = -mg(n);
%                 mw(n) = -mw(n);
%                 ma(n) = -ma(n);
%                 mat(n) = -mat(n);
%             end
            
            % inversion pulse applied to the whole brain and the artery
            if abs(n*dt - b)< (dt/2)
                mcsf(n) = -mcsf(n);
                mw(n) = -mw(n);
                mg(n) = -mg(n);
                
                ma(n) = -ma(n);
                mat(n) = -mat(n);
            end
            if 1
                % inversion pulse applied to the whole brain and the artery
                if abs(n*dt - c)< (dt/2)
                    mcsf(n) = -mcsf(n);
                    mw(n) = -mw(n);
                    mg(n) = -mg(n);
                    ma(n) = -ma(n);
                    mat(n) = -mat(n);
                end
            end
        end
        %{
        figure(1)
        plot(mg,'k'); grid on
        hold on;
        plot(mw,'y'); 
        plot(mcsf,'g');
        plot(ma,'b')
        plot(mat,'r')
        plot(mat-ma,'c')
        
        legend('Gray','White','CSF','blood','tagged blood','difference','Location','NorthWest')
        rectangle('Position', [0 -0.3 tag_length/dt  0.6],'FaceColor',[0.5 0.5 0.5] )
        %}
        
        asl(n1,n2) =  mat(end-2)-ma(end-2);
        bkgnd1(n1,n2) =  mg(end-2);
        bkgnd2(n1,n2) =  mw(end-2);
        bkgnd3(n1,n2) =  mcsf(end-2);
        drawnow; pause(0.2);
        hold off
    end
    figure (2)
    plot(abs(asl(n1,:))); hold on; 
    plot(abs(bkgnd1(n1,:)),'k');
    plot(abs(bkgnd2(n1,:)),'y');
    plot(abs(bkgnd3(n1,:)),'g');hold off
end

tb = abs(bkgnd1) + abs(bkgnd2) + abs(bkgnd3);
[best bestind] = min(tb(:))
[bn1, bn2] = ind2sub( size(bkgnd1), bestind)
fprintf('\nBS1 time:  %f, \nBS2 time: %f', interval1(bn1), interval2(bn2) );

figure(3)
imagesc(tb); colormap gray


