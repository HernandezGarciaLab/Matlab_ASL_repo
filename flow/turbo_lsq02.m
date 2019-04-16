function result=turbo_lsq02( est , tr_vec, consts, data )
% function result=turbo_lsq02( est , tr_vec, consts, data )
%
% this version uses a gamma function to characterize dispersion
%
% R1art=consts(1);
% R1t=consts(2);
% alpha = consts(3);
% del = consts(4);

PPC = 100; % Points / Cycle % each cycle = 2 TR ;

%PPS = 1;

showUptake=0;

Ttrans=est(1);
f=est(2) ;
Beta = est(3);

R1art=consts(1);
R1t=consts(2);
alpha = consts(3);
del = consts(4);
M0 = consts(5);
Taq = consts(6);  % time to acquire all slices
%

curve = zeros(size(tr_vec));
%global myerr
for count=1:length(tr_vec)
    TR = tr_vec(count);
    Ttag = TR-Taq; % 0.4 = difference between TR and T_tag
    % make the RF input function
    PPS = PPC/(2*TR);  % Points / second -- added by Hesam 
    RF=zeros(1,round(2*TR*PPS));
    RF(1:round(Ttag*PPS))=1;
    RF = [RF RF];
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
    resp = exp(-f*t/0.9) .* exp(-t*R1t);
    %resp = (1/PPS)*resp/sum(resp);
    resp = resp/sum(resp);
    RESP = fftshift(fft(resp));

    % make the gamma dispersion kernel
    gamma = t .* exp(-t./Beta);
    %gamma = (1/PPS)*gamma / sum(gamma);
    gamma = gamma / sum(gamma);
    GAMMA = fftshift(fft(gamma));

    % carry out the convolution by multiplying in frq. domain
    M = INP2 .* RESP .* GAMMA;
    m = real(ifft(ifftshift(M)));

    % sample the magnetization and subtract
    tag=round((3*TR - Taq + del)*PPS);
    ctl=round((2*TR - Taq + del)*PPS);
    ASL = m(tag) - m(ctl);
    curve(count)=real(ASL);
    %keyboard
    if showUptake==1
        inp2 = fftshift(ifft(INP2.*GAMMA));
        plot(t, abs(inp2),'g')
        hold on
        inp2 = fftshift(ifft(INP2));
        plot(t, abs(inp2),'c')
        plot(t, real(resp),'r')
        plot(t, RF)
        plot(t, real(m),'k')
        plot(ctl/PPS, real(m(ctl)),'bo' )
        plot(tag/PPS, real(m(tag)),'ro' )
        title(sprintf('TT = %f TR= %f Beta=%f',Ttrans,TR, Beta))
        %axis([0 16 0 10])
        drawnow
        pause
        hold off
    end

end

if nargin<4
    result=curve;
    return
else   % this means the function is called by lsqnonlin....
    result = ((curve-data));
    %weights=ones(size(result));
    %weights(end)=3;
    %weights(1)=3;
    %result=result.*weights;
    if 0
        plot(tr_vec,curve)
        hold on
        plot(tr_vec,data,'r')
        plot(tr_vec,(curve-data),'g')
        rss=sum(result.^2) / (length(result)*(max(data)-min(data)));
        title(sprintf('f=%f  TT=%f Beta=%f  RSS=%f',f, Ttrans,Beta, rss));
        hold off
        drawnow
        fprintf('\n %f',sum(result))
        %       myerr=[myerr;  rss est];
    end
end

return

