function [g,k,t,s]=spiralgradlx3(opfov,opxres,gts,gslew,gamp,nl);

%/*   multi- shot spiral design 
%*    uses Duyn's approximate slewrate limited design 
%*    augmented with archimedian gmax limit 
%*    inputs (args) 
%*        opfov = FOV, cm 
%*        opxres = matrix size 
%*	 Tmax = longest acquisition allowed, s 
%*	 dts = output sample spacing, s 
%*        gtype = trajectory type 
%*    inputs (CVs) 
%*        nl = number of interleaves 
%*        gamp = design grad max, G/cm 
%*        gslew = design slew rate, mT/m/ms 
%*	 nramp = number of rampdown points 
%*    outputs 
%*        Gx, Gy 
%*        grev 
%*    time is in sec 
%* 
%*		rev 0 12/26/98	original 
%*		rev 1 4/15/99	little better calc of ts 
%*/ 

MAX_PG_WAMP = 32766;
GRESMAX = 21000;

%opxres = 64;  % design x res
%nl = 1;        % number interleaves
%gts = 4e-6;   % sec (grad sample spacing)
%gamp = 3.5;   % peak (g/cm)
%opfov = 24;   % cm
%gslew = 200;  % peak slew (mT/m/s)
Tmax = GRESMAX*gts;
gamma = 2*pi*4.257e3; % rad/s/gauss
gambar = 4.257e3;     % Hz/gauss
 
q = 5;		% nice number
S0 = gslew*100; 
dt = gts*.5; 
 
%/*  slew limited approximation  */ 

  Ts = .666667/nl*sqrt(((pi*opxres)^3)/(gamma*opfov*S0));
  if Ts > Tmax 
    sprintf('slew limited readout too long')
    return;
  end; 
  a2 = opxres*pi/(nl*(Ts^0.666667)); 
  a1 = 1.5*S0/a2; 
  beta = S0*gamma*opfov/nl; 
  Gmax = a1*(Ts^0.333333); 
  gmax = 0; 
  t = [0:dt:Ts];
  x = (t.^1.333333); 
  theta = (t.^2).*(0.5.*beta./(q + 0.5.*beta./a2.*x)); 
  y = q+0.5.*beta./a2.*x; 
  dthdt = t.*(beta.*(q+.166667.*beta./a2.*x)./(y.*y)); 
  c = cos(theta); 
  s = sin(theta); 
  gx = (nl/(opfov*gamma)).*dthdt.*(c - theta.*s); 
  gy = (nl/(opfov*gamma)).*dthdt.*(s + theta.*c); 
  gabs = abs(gx + i.*gy);
% cut short if over peak
  gmax = abs(gamp./(theta+eps) + i.*gamp); 
  l1 = length(t) - sum(gabs>gmax);
  ts = t(l1);
  thetas = theta(l1);

 
%/*  gmax limited approximation  */ 
 
l3 = 0;
T=ts;
if Gmax > gamp 
  T=((pi*opxres/nl)*(pi*opxres/nl) - thetas*thetas)/(2*gamma*gamp*opfov/nl)+ts; 
  if T > Tmax 
      sprintf('gmax limited readout too long')
      return;
  end;
  t = [ts+dt:dt:T];
  theta = sqrt(thetas*thetas + (2*gamma*gamp*opfov).*(t-ts)./nl); 
  c = cos(theta); 
  s = sin(theta); 
  ind2 = l1+[1:length(t)];
  gx(ind2) = gamp.*(c./theta - s);
  gy(ind2) = gamp.*(s./theta + c);
  l3 = length(t);
end; 
 
l2 = l1 + l3;
Gx = gx(1:2:l2);   % or gx(1:2:l2)*MAX_PG_WAMP/gamp
Gy = gy(1:2:l2);   % or gy(1:2:l2)*MAX_PG_WAMP/gamp
g = Gx + i.*Gy;   % grad vector gauss/cm
s = diff(g)./(gts*1000);  %slew rate vector
%Kx = cumsum([0 Gx])*gts*gambar; %1/cm
%Ky = cumsum([0 Gy])*gts*gambar; %1/cm
Kx = cumsum([0 Gx])*gts*gambar; %1/cm
Ky = cumsum([0 Gy])*gts*gambar; %1/cm
k = Kx + i.*Ky;  %kspace vector
t = [0:gts:T]; % time vector

k = k*opfov;
