function [z,Mzs,t]=IRsatfit(x,T1,TotTime,T1alt)
% Usage ... z=IRsatfit(x,T1,TotTime,nMax)
%
% T1alt - species that does not see sat 90 and needs to be maximized

% Based on the paper by Mani, et al., MRM 37:898 1997
% The times are referenced with respect to the readout (TotTime)!!!!

if nargin<4, T1alt=1000e-3; end;

ntau=length(x);
nspecies=length(T1);

for m=1:nspecies,
  Mz(m) = 1 + ((-1)^(ntau+1))*exp(-TotTime/T1(m));
  for n=1:ntau,
    Mz(m) = Mz(m) + 2*((-1)^n)*exp(-x(n)/T1(m));
  end;
end;

Mzalt=1;
for n=1:ntau,
  Mzalt = Mzalt + 2*((-1)^n)*exp(-x(n)/T1alt);
end;

z=sum(Mz);
%z=sum(Mz)+1/Mzalt;

if sum(x<=0), z=inf; end;

if ((nargout>1)|(nargout==0)),
  dt=1e-3;
  t=[0:dt:TotTime]';
  tlen=length(t);
  blnk=zeros(size(t));

  gamma=26752;            % rad / G s
  G2T=1e-4; s2ms=1000;    % conversions
  B1=pi/(gamma*dt);       % one sample 180-degree pulse

  B1t=blnk;
  for m=1:ntau, B1t(tlen-floor(x(m)/dt))=B1; end;

  M0=[0 0 1];
  
  T2alt=T1alt;
  MMtalt=blochsim2(M0,[B1t blnk blnk]*G2T,T1alt*s2ms,T2alt*s2ms,dt*s2ms,length(t));

  B1t(1)=B1/2;
  for m=1:nspecies,
    T2(m)=T1(m);
    MMt(:,:,m)=blochsim2(M0,[B1t blnk blnk]*G2T,T1(m)*s2ms,T2(m)*s2ms,dt*s2ms,length(t));
  end;

  z=sum(MMt(end,3,:));
  %z=sum(MMt(end,3,:))+1/MMtalt(end,3);

  Mzs=[squeeze(MMt(:,3,:)) MMtalt(:,3)];

  if (nargout==0),
    subplot(211)
    plot(t,B1t)
    ylabel('RF')
    subplot(212)
    plot(t,Mzs)
    xlabel('Time'), ylabel('Mz'), grid,
    Mzs(end,:),
  end;

end;

