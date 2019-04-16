


load A;  % 25 random onsets, from 0 to 100


Te = 60;
dt = 1/4;
T = 0:dt:Te;
X = T*0;
X(round(A(A<Te))/dt) = 1;

Ir = X;


Ib = [zeros(5,1);ones(10,1);zeros(10,1);ones(10,1);zeros(5,1)];
Is = [zeros(5,1);zeros(5,1);ones(20,1);zeros(5,1);zeros(5,1)];
Ih = [zeros(0,1);repmat([1 0]',20,1);zeros(0,1)];

Ibc = WKfun('HRFconv',Ib);
Isc = WKfun('HRFconv',Is);
Ihc = WKfun('HRFconv',Ih);

n=length(Ib);

V = spm_Q(0.7,n);
V = diag(1./sqrt(diag(V)))*V;
W = WKfun('mkW',[],V);

[WKfun('stdev',Ib),WKfun('stdev',Is),WKfun('stdev',Ih)]
[WKfun('stdev',Ib,V),WKfun('stdev',Is,V),WKfun('stdev',Ih,V)]
[WKfun('stdev',Ib,V,W),WKfun('stdev',Is,V,W),WKfun('stdev',Ih,V,W)]

% iid   /OLS    0.3162    0.3162    0.3162

% AR(.7)/OLS    0.5038    0.6103    0.1392
% AR(.7)/GLS    0.3666    0.4600    0.1354

% AR(.5)/OLS    0.4591    0.4993    0.1862
% AR(.5)/GLS    0.4025    0.4546    0.1845

% AR(.2)/OLS    0.3687    0.3770    0.2596
% AR(.2)/GLS    0.3631    0.3735    0.2593


[WKfun('stdev',Ibc),WKfun('stdev',Isc),WKfun('stdev',Ihc)]
[WKfun('stdev',Ibc,V),WKfun('stdev',Isc,V),WKfun('stdev',Ihc,V)]
[WKfun('stdev',Ibc,V,W),WKfun('stdev',Isc,V,W),WKfun('stdev',Ihc,V,W)]

% iid   /OLS    0.3130    0.3103    1.4602
		
% AR(.7)/OLS    0.5423    0.6158    1.8661
% AR(.7)/GLS    0.4993    0.5742    1.4598
		
% AR(.5)/OLS    0.4815    0.5014    1.8035
% AR(.5)/GLS    0.4684    0.4927    1.6095
		
% AR(.2)/OLS    0.3736    0.3742    1.6120
% AR(.2)/GLS    0.3726    0.3737    1.5847

    
    
WKfun('plot',Ib,[],[],'Pred_Blk')
WKfun('plot',Is,[],[],'Pred_Slw')
WKfun('plot',Ih,[],[],'Pred_Hfq')

WKfun('plot',Ibc,[],[],'Pred_BlkCon')
WKfun('plot',Isc,[],[],'Pred_SlwCon')
WKfun('plot',Ihc,[],[],'Pred_HfqCon')


bar(T,X)
hold on;
  h=plot(xX.X(:,1),'g');
  set(h,'linewidth',3)
hold off
set(gca,'xlim',[0 100])
set(gca,'fontsize',14)

