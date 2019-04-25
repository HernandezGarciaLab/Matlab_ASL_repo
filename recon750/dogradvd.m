function [g,k,t,s,vd]=dogradvd(opfov,opxres,gts,gslew,fsgcm,nl,densamp);

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
% 
% $HeadURL: svn+ssh://klitinas@woo.engin.umich.edu/work/repos/matlab/recon/branches/phase_zero/dogradvd.m $
% $Id: dogradvd.m 1266 2014-03-20 18:12:40Z klitinas $

MAX_PG_WAMP = 32766;
GRESMAX = 21000;

%opxres = 64;  % design x res
%nl = 1;        % number interleaves
%gts = 4e-6;   % sec (grad sample spacing)
%gamp = 3.5;   % peak (g/cm)
%opfov = 24;   % cm
%gslew = 200;  % peak slew (mT/m/s)
Tmax = GRESMAX*gts;

ts = gts;               % temporary - needs to be fixed some time...
dts = gts;               % temporary - needs to be fixed some time...
dentrans = densamp/2;	% duration of transition from higher to lower
npts = 16384;           % max number of points
fractrans = 1;

A = MAX_PG_WAMP;
risetime = fsgcm/gslew*10000;
S = (dts/1e-6)*A/risetime;

targetk = opxres/2;

MAXDECRATIO = 32;
GAM = 4257.0;
S = (gts/1e-6)*A/risetime;
dr = ts/gts;
OMF = 2.0*pi * opfov/(1/(GAM*fsgcm*gts));
OM = 2.0*pi/nl * opfov/(1/(GAM*fsgcm*gts));
distance = 1.0 / (opfov*GAM*fsgcm*gts/A);
i = sqrt(-1);

ac = A;
loop = 1;
decratio = 1;
kx = [];
ky = [];
ggx = [];
ggy = [];
vdfact = [];

while loop > 0,		% start over
	loop = 0;
	dnpts = dr*npts*decratio; 
	om = OM/decratio; 
	omf = OMF/decratio; 
	s = S/decratio;
	g0 = 0; 
	gx = g0; 
	gy = 0; 
	absg = abs(g0);
	oldkx = 0; 
	oldky = 0; 
	tkx = gx; 
	tky = gy; 
	kxt = tkx; 
	kyt = tky;
	thetan_1 = 0; 
	taun = 0; 
	n = 0;
	den1 = 0;
        arraysize = (2*nl*om*taun/(2*pi));
	while (arraysize < opxres),
%	while n < (dnpts-1),
	    realn = n/decratio;
%	    if rem(realn,500) == 1
%	      realn 
%	      [realn arraysize]
%	    end
	    taun_1 = taun; 
	    taun = abs(tkx + i*tky)/A; 
	    tauhat = taun;
	    if realn > densamp
	      if den1 == 0 
		kdenrad = abs(tkx + i*tky)/distance/decratio;
		den1 = 1;
	      end
	      if realn > densamp+dentrans
		scoffset = scthat;
		denoffset = taun_1;
	        scthat = scoffset + om*(tauhat - denoffset);
		fractrans = 1;
	      else
		scoffset = scthat;
		denoffset = taun_1;
		fractrans = (realn - densamp)/dentrans;
		fractrans = 1 - ( (fractrans-1)*(fractrans-1));
	        scthat = scoffset + (omf + (om-omf)*fractrans)*(tauhat - denoffset);
	      end
	    else
	      fractrans = 0;
	      scthat = omf*tauhat;
	    end % if realn > densamp
	    theta = atan2(scthat,1.0)+scthat;
	    if absg < ac
		deltheta = theta-thetan_1;
		B = 1.0/(1.0+tan(deltheta)*tan(deltheta));
		gtilde = absg;
		t1 = s*s;
		t2 = gtilde*gtilde*(1-B);
		if t2 > t1
		    decratio = decratio * 2.0;
		    if decratio > MAXDECRATIO
			printf('k-space calculation failed.\n');
			return;
		    end
		    loop = 1;
		    break;
		end
		t3 = sqrt(t1-t2);
		absg = sqrt(B)*gtilde+t3;
		if (absg > ac)
		    absg = ac;
	        end
	    end % if absg < ac
	    tgx = absg*cos(theta);
	    tgy = absg*sin(theta);
	    tkx = tkx + tgx;
	    tky = tky + tgy;
	    thetan_1=theta;
	    if rem(n,decratio) == 0
		m = round(n/decratio);
		gx = round(((tkx-oldkx))/decratio);
		gx = gx - rem(gx,2);
		gy = round(((tky-oldky))/decratio);
		gy = gy - rem(gy,2);
		ggx(m+1) = gx;
		ggy(m+1) = gy;
		kxt = kxt + gx;
		kyt = kyt + gy;
		oldkx = tkx;
		oldky = tky;
	    	if rem(m,dr) == 0
		    m  = m / dr;
%		    if ((m+1)>(npts-1))
%			break;
%		    end
		    kx(m+1) = kxt/distance;
		    ky(m+1) = kyt/distance;
		    vdfact(m+1) = om/(omf + (om-omf)*fractrans);
		end
	    end % if rem(n,decratio) == 0
	    n = n+1;
            arraysize = (2*nl*om*taun/(2*pi));
	end % while arraysize < opxres
end % while loop > 0,		% start over
arraysize = ceil(2*nl*om*taun/(2*pi));
res = opfov/arraysize*10;
g = (ggx + i.*ggy)./A.*fsgcm;
g = [0 g];
npts = length(g);
s = diff(g)/gts/1000;
k = kx + i*ky;
k = [0 0 k];  % not sure if this padding is necessary...
t = [0:length(k)-1]*dts;
vd = [vdfact(1) vdfact(1) vdfact];

return
% calculate true k locations - 3 term integrations - simpson's rule
%   (simpson's rule 1/6 4/6 1/6 weighting)
dt = gts*1000;
delk = 1/4.258/opfov; 	% (g ms)/cm
k(1) = 0;
k(2) = (gvec(2) + 4*gvec(1) )*dt/6;
for i=1:npts-2,
  k(i+2) = k(i+1) + (gvec(i+2) + 4*gvec(i+1) + gvec(i))*dt/6;
end % for i=1:npts-1
k = k(1:npts) ./delk;
