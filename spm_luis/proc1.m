for sub=3:3,
  if sub == 1 
    subtxt = 'jk';
  elseif sub == 2
    subtxt = 'cg';
  elseif sub == 3
    subtxt = 'dy';
  else
    subtxt = 'pt';
  end;
for run=1:1,
  tt = sprintf('%sblock%d-r.txt',subtxt,run);
  of1 = sprintf('%sblock%d-i1.txt',subtxt,run);
  fid = fopen(tt,'r');
  times = fscanf(fid,'%d',[14 127]);
% In times array rows 1-14 are as follows:
% Onset Leftarrows	Offset Leftarrows	 
% Onset RightArrows	 Offset RightArrows	
% Onset NoSwitch	Offset NoSwitch	
% Onset CountSwitchONLY	Offset CountSwitchONLY	
% Onset OperSwitchONLY	Offset OperSwitchONLY	
% Onset DualSwitch	Offset DualSwitch	
% Onset Baseline	Offset Baseline
%
% e.g. times(5,:) gives all of the onset times to a no switch trial
%
% all times are in ms
t = [0:2000:(6*60*1000)];
parms = [1.8473 2500 1250];
for lp = 1:7
  ii = lp*2-1;
  etimes = times(ii,find(times(ii,:)>1));
  tvects(lp,:) = mkgam(etimes, t, parms);
end

etstep = 25;
et = [0:etstep:(6*60*1000)];
for lp = 1:7
  ii = lp*2;
  i2 = lp*2-1;
  etimes1 = times(ii,find(times(ii,:)>1));
  etimes2 = times(i2,find(times(i2,:)>1));
  resp = etimes1-etimes2;
  mean(resp);
  std(resp);
  etimes = et(evind(et,etimes1,etimes2));
  tvectconv(lp,:) = mkgam(etimes, t, parms);
end


end;
end;
