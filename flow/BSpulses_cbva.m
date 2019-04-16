clear
R1a = 1/1.6;
R1=1/1.2;
R1csf = 1/2.4;


interval = [0.02:0.02:0.3];
%interval = 0.5;
tag_length = 1.4;  % duration of labeling train
tag_delay = 1.2;
% define transit time as the time elapsed between tagging and acquisition
% t_transit = [0.1:0.1:1.6];
% time at which spins actually get tagged (depends on their transit time)
tag_time = [0:0.1:1.6];
tag_time = 1.2;

asl=zeros(length(tag_time), length(interval));
bkgnd=asl;


for nt = 1:length(tag_time)
    
    for ni=1:length(interval);
        
        a = 1.420;
		%a = tag_length +0.1;
        b = a + interval(ni);
        c = b + interval(ni);
        d = c + interval(ni);
        
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
        mcsf(1) = -1;
        m(1) = -1;
        ma(1)= -1;
        mat(1)= 1;
        
        for n=2:1600
            dm =  (1 - m(n-1))*R1;
            m(n) = m(n-1) + dm*dt;
            
			dmcsf =  (1 - mcsf(n-1))*R1csf;
            mcsf(n) = mcsf(n-1) + dmcsf*dt;
            
            dma =  (1 - ma(n-1))*R1a;
            ma(n) = ma(n-1) + dma*dt;
            
            dmat =  (1 - mat(n-1))*R1a;
            mat(n) = mat(n-1) + dmat*dt;
            
            % at the end of the tagging we make sure the arterial spins are inverted
            if abs(n*dt)< tag_time(nt)
                ma(n) = 1;
                mat(n) = -1;
            end
            
            % inversion pulse applied to the whole brain and the artery
            if abs(n*dt -a)< (dt/2)
                mcsf(n) = -mcsf(n);
                m(n) = -m(n);
                ma(n) = -ma(n);
                mat(n) = -mat(n);
            end
           
            % inversion pulse applied to the whole brain and the artery
            if abs(n*dt - b)< (dt/2)
                mcsf(n) = -mcsf(n);
				m(n) = -m(n);
                ma(n) = -ma(n);
                mat(n) = -mat(n);
            end
     if 0       
            % inversion pulse applied to the whole brain and the artery
            if abs(n*dt - c)< (dt/2)
                mcsf(n) = -mcsf(n);
                m(n) = -m(n);
                ma(n) = -ma(n);
                mat(n) = -mat(n);
            end
     end   
        end
        figure(1)
        plot(m,'k'); grid on
        hold on;
		plot(mcsf,'g');
		plot(ma,'b')
        plot(mat,'r')
        plot(mat-ma,'c')
        
        legend('tissue','CSF','blood','tagged blood','difference','Location','NorthWest')
        rectangle('Position', [0 -0.3 tag_length/dt  0.6],'FaceColor',[0.5 0.5 0.5] )
        
        asl(nt,ni) =  mat(end-2)-ma(end-2);
        bkgnd(nt,ni) =  m(end-2);
		bkgnd2(nt,ni) =  mcsf(end-2);
        drawnow; pause(0.2);
        hold off
    end
    figure (2)
    plot(abs(asl(nt,:))); hold on; plot(abs(bkgnd(nt,:)),'k');plot(abs(bkgnd2(nt,:)),'g');hold off
end



% 
% figure
% subplot(211)
% imagesc(asl); title('ASL signal'); colorbar
% ylabel('Transit Time')
% xlabel('interpulse interval')
% 
% subplot(212)
% imagesc(abs(bkgnd)); title('Bcknd Signal'); colorbar
% ylabel('Transit Time')
% xlabel('interpulse interval')
% legend('ASL signal','tissue')
