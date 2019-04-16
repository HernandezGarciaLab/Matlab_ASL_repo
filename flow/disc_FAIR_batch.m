%%%%%%%%%%%  FAIR batch
clear; close  all
delays = [0.05 0.8 0.9 1.0 1.1 1.2 1.5 1.8   ];
ASLbuffer = [];
time = 1:40;
leg = cell(size(delays));
duration = 20;
for count=1:max(size(delays))

   Ttag = delays(count);

    disc_kinetics_FAIR
    % ASLbuffer = [ASLbuffer ASL(4)];
    tmp = interp1(tASL, ASL, time, 'nearest');
    ASLbuffer = [ ASLbuffer ; tmp(6:end) ]
    leg{count} = num2str(del2);
    

end

subplot(121)
plot(time(6:end), (ASLbuffer))
%hold on, plot(tvec, f/f(6),'--k')
legend ( leg )

%plot(tags, ASLbuffer)
subplot(122)
plot(delays,ASLbuffer(:,1))
