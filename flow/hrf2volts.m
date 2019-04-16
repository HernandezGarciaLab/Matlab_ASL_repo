duration = 600
Vart_change =0.3;
SECONDS = 10;
     paradigm = ones(1, duration*SECONDS);

% =======  set of gamma variate HRF's
        for delay=25:80:duration
            h = make_hrf(delay*SECONDS,3*SECONDS,duration*SECONDS) * Vart_change ;
            paradigm  = paradigm + h;
        end
       plot(paradigm)

fp = fopen('gamma80.bin','wb')
fwrite(fp,paradigm,'float');
fclose(fp) 
