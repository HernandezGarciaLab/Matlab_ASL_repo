% all times in ms
fid = fopen('b1.txt');
times = fscanf(fid,'%g',[8 100]);
t = [0:2000:(6*60*1000)];
parms = [1 2500 1250];
for lp = 1:8
  etimes = times(lp,:);
  tvects(lp,:) = mkgam(etimes, t, parms);
end
subplot(211);
plot(t/1000,tvects(1,:))
title('left target')
subplot(212);
plot(t/1000,tvects(2,:))
title('right target')

pause

subplot(211);
plot(t/1000, tvects(6,:)+ tvects(8,:))
title('counter switch')
subplot(212);
plot(t/1000, tvects(5,:)+ tvects(7,:))
title('no counter switch')

pause

subplot(211);
plot(t/1000, tvects(7,:)+ tvects(8,:))
title('operation switch')
subplot(212);
plot(t/1000, tvects(5,:)+ tvects(6,:))
title('no operation switch')

pause

subplot(411);
plot(t/1000,tvects(6,:))
title('counter (only) switch')
subplot(412);
plot(t/1000,tvects(7,:))
title('operation (only) switch')
subplot(413);
plot(t/1000,tvects(8,:))
title('dual switch')
subplot(414);
plot(t/1000,tvects(5,:))
title('no switch')

pause

subplot(211);
plot(t/1000, tvects(6,:)+ tvects(7,:)+ tvects(8,:))
title('any switch')
subplot(212);
plot(t/1000,tvects(5,:))
title('no switch')


