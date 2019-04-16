% this is a batch to call disc_kinetics3 as a fuction of Ttag
clear; close  all

% tagging times
tags = [1 1.2 1.4 3.5]
% post inversion delay
delays = [0.05 0.1 0.15];

ASLbuffer = [];
ASLbase=[];
time = 1:50;
legstr = cell(size(tags));

for count=1:max(size(tags))

   Ttag = tags(count)
%   del = delays(count);

    disc_kinetics3
    % ASLbuffer = [ASLbuffer ASL(4)];
    tmp = interp1(tASL, ASL, time, 'linear');
    ASLbase = [ASLbase ; tmp(9)];
    ASLbuffer = [ ASLbuffer ; tmp(9:end) / tmp(9) ];
    legstr{count} = num2str(Ttag);
    
end

subplot(121)
plot(time(9:end), (ASLbuffer)) , grid on, axis tight
hold on, plot(tvec, f/f(9),'--k')
legend ( legstr ,0)
legend boxoff
title ('Normalized activation')

%plot(tags, ASLbuffer)
subplot(122)
plot(tags,ASLbase,'-*') , grid on, axis tight
title('baseline SNR')
