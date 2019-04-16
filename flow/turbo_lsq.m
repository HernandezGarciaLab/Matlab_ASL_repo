function result=turbo_lsq( est , tr_vec, consts, data )
% function result=turbo_lsq( est , tr_vec, consts, data )
%
% R1art=consts(1);
% R1t=consts(2);
% alpha = consts(3);
% del = consts(4);

PPS = 5;  % Points / second

showUptake=0;

Ttrans=est(1);
f=est(2) ;

R1art=consts(1);
R1t=consts(2);
alpha = consts(3);
del = consts(4);
M0 = consts(5);


curve = zeros(size(tr_vec));
global myerr
for count=1:length(tr_vec)
     TR = tr_vec(count);
     Ttag = TR-0.25;
     % make the RF input function
     RF=zeros(1,round(2*TR*PPS));
     RF(1:round(Ttag*PPS))=1;
     RF = [RF RF RF];
     % make the Tag input function (adjust for t1 decay, f, efficiency, M0...
     inp = 2*M0*0.7*alpha*f*RF*exp(-Ttrans*R1art);

     % shift the function by the transit time in Frq Domain
     INP = fftshift(fft(inp));
     phase = [-length(INP)/2:length(INP)/2-1]*2*pi/length(INP); 
     phase = Ttrans*PPS* phase; 
     phase = exp(-i.*phase );
     INP2 = INP .* phase;

     % make the tissue residual and decay response
     t = [1:length(inp)]/(PPS);
     resp = (1/PPS) *exp(-f*t/0.9) .* exp(-t*R1t);
     RESP = fftshift(fft(resp));

     % carry out the convolution by multiplying in frq. domain
     M = INP2 .* RESP;
     m = ifft(ifftshift(M));

     % sample the magnetization and subtract
     tag=round((3*TR-0.25+del)*PPS);
     ctl=round((4*TR-0.25+del)*PPS);
     ASL = m(tag) - m(ctl);
     curve(count)=real(ASL);
%keyboard
     if showUptake==1
          hold on
          plot(t, real(inp),'g')
          plot(t, real(resp),'r')
          plot(t, RF)
          plot(t, real(m),'k')
          plot(ctl/PPS, real(m(ctl)),'bo' )
          plot(tag/PPS, real(m(tag)),'ro' )
          title(sprintf('TT = %f TR= %f',Ttrans,TR))
          axis([0 6 0 80])
          drawnow
          pause
          hold off
     end

end

if nargin<4
     result=curve;
     return
else   % this means the function is called by lsqnonlin....
     result = curve-data;
     weights=ones(size(result));
     %weights(end)=3;
     %weights(1)=3;
     result=result.*weights;
     rss=sum(result.^2) / (length(result)*(max(data)-min(data)));
     myerr=[myerr;  rss est];
     if 0
        plot(tr_vec,curve)
        hold on
        plot(tr_vec,data,'r')
        plot(tr_vec,(curve-data),'g')
        title(sprintf('f=%f  TT=%f   RSS=%f',f, Ttrans, rss));
        hold off
        drawnow
     end
end

return 

