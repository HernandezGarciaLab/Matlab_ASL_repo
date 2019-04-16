%% Build the Design Matrix
%% experiment date:  10.26.09
TR = 1;
exp_duration = 320;

NITER=100;

ITI = 10:1:30;
t = zeros(length(ITI), NITER);
c=1;



for iti = ITI

    onsets{1} = [20: iti :320];
    durations{1} = 5*ones(size(onsets{1}));

    X = buildDesMat(TR, 320, onsets, durations, 0);
    %
    % X = differencer(ref,3);
    %
    % X = X(:, 1:2);
    % X(:,1) = 1;
    % % Build a Design Matrix with the specified onset times and durations

    c = [0 1];
    xtxinv = pinv(X);

    betas = [100, 20]';

  
    for n=1:NITER 
        
        y = X*betas ;

        nvec = randn(exp_duration/TR,1);
        y = y + 1*nvec;
        N = length(y);
        p = size(X,2);

%plot(y); drawnow;

        bh = xtxinv*y;
        Res = y - X*bh;
        var_est = Res'*Res / (N-p)^2;
        var_con = xtxinv*var_est*xtxinv';

        % update T score map
        t(c,n) = c*bh ./ srt(var_con);
      
        
    end
    c = c+1;
end

meant = mean(t,2);
plot(ITI,meant)