
% This script uses 3 inversions for multi-species
% signal nulling

clear all

%time locations of the different pulses
sat90=20e-3;
IR1=500e-3;
TE=700e-3;
nulltime=IR1+TE;

T1csf=2500e-3;	
T1blood=1500e-3;	% beware this T1 value is not accurate!
T1white=1100e-3;
T1gray=1400e-3;

T2csf=1500e-3;
T2blood=160e-3;		% oxy blood ~ 160ms, deoxy blood ~ 50ms (rat data)
T2white=90e-3;
T2gray=110e-3;

ts=1e-3;
TR=2000e-3;
nTRs=3;
nsam=TR/ts;
t=[1:nsam*nTRs]*ts;
t=t(:);

gamma=26752;		% rad / G s
G2T=1e-4; s2ms=1000;	% conversions
B1=pi/(26752*ts);	% one sample 180-degree pulse

loc180s=[IR1/ts];
loc90s=[IR1/ts+TE/ts];
blnk=zeros(size(t));

B1s=zeros([1 nsam]);
B1s(loc180s)=1*B1;
B1s(loc90s)=1*0.5*B1;


B1bloods=zeros([1 nsam]);
B1bloods(1)=1*B1;
B1bloods(loc90s)=0.5*B1;

B1cbloods=zeros([1 nsam]);
B1cbloods(loc90s)=0.5*B1;


B1t=B1s;
B1blood=B1bloods;
B1cblood=B1cbloods;

for m=2:nTRs, B1t=[B1t B1s]; B1blood=[B1blood B1bloods]; B1cblood=[B1cblood B1cbloods];end;
B1t=B1t(:);
B1cblood=B1cblood(:);
B1blood=B1blood(:);

M0=[0 0 1];
Mtcsf=blochsim2(M0,[B1t blnk blnk]*G2T,T1csf*s2ms,T2csf*s2ms,ts*s2ms,length(t));
Mtblood=blochsim2(M0,[B1blood blnk blnk]*G2T,T1blood*s2ms,T2blood*s2ms,ts*s2ms,(length(t)/nTRs));
Mtcblood=blochsim2(M0,[B1cblood blnk blnk]*G2T,T1blood*s2ms,T2blood*s2ms,ts*s2ms,(length(t)/nTRs));
Mtwhite=blochsim2(M0,[B1t blnk blnk]*G2T,T1white*s2ms,T2white*s2ms,ts*s2ms,length(t));
Mtgray=blochsim2(M0,[B1t blnk blnk]*G2T,T1gray*s2ms,T2gray*s2ms,ts*s2ms,length(t));

Mblood=[Mtblood; Mtcblood; Mtblood];
size(Mtblood)
size(Mblood)

%ii=find(abs(Mtcsf(:,3))<2e-3);
%%ii=[151 351 551 751 951 1151 1351 1551 1751 1951]-10;
%ii=loc90s;
%[t(ii) Mtcsf(ii,3) Mtblood(ii,3) Mtwhite(ii,3) Mtgray(ii,4)],
%%if length(ii)==length(loc180s),
%%  %tnull=t(ii)-[0:2:19]',
%%  %tnull=t(ii)-[0:1.5:19]',
%%  tnull=t(ii)-[0:1:19]',
%%end;

%subplot(411)
%plot(t,Mtcsf)
%ylabel('CSF Mag')
%subplot(412)
%plot(t,Mtblood)
%ylabel('Blood Mag')
%subplot(413)
%plot(t,Mtwhite)
%ylabel('White Matter Mag')
%subplot(414)
%plot(t,Mtgray)
%ylabel('Gray Matter Mag')

t=t-(nTRs-1)*TR;
plot(t,Mtcsf(:,3),t,Mblood(:,3),t,Mtwhite(:,3),t,Mtgray(:,3))
legend('CSF','Blood (tag)','White Matter','Gray Matter')

