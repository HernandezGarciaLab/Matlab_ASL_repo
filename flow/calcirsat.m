function tau=calcIRsat(tau0,T1,TotTime,T1alt,optvar)
% Usage ... tau=calcIRsat(tau0,T1,TotTime,T1alt,optvar)

if nargin<5,
  %optvar=foptions;
  optvar=optimset('fminsearch');
  optvar.TolFun=1e-10;
  optvar.TolX=1e-10;
  optvar.MaxIter=300*length(tau0);
  optvar.MaxFunEvals=300*length(tau0);
  %optvar.Display='iter';
end;
if nargin<4, T1alt=1500e-3; end;

tau=fminsearch('IRsatfit',tau0,optvar,T1,TotTime,T1alt),
[zz,Mzs,tt]=IRsatfit(tau,T1,TotTime,T1alt);

if nargout==0,
  plot(tt,Mzs)
  xlabel('Time')
  ylabel('Mz')
end

