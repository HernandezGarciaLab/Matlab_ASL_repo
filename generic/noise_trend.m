clear all; close all

% standard deviation of the gaussian noise
base_price = 100;
sd = 0.01* base_price;
Nticks = 5000;
Nchoices = 50;
transprice =9;

rho1 = 0.6;
rho2 = 0.2;
rho3 = 0.2;

gains = zeros(1000,1);

 for m = 1:1000;
    Ntrans = 0;
    Gnoise = sd*randn(Nticks,1);
    Anoise =  Gnoise;
    % stocks and cash:
    nstock = 100 * ones(size(Gnoise));
    cash = zeros(size(nstock));
    
    for n=4 : length(Anoise)
        Anoise(n) = rho3*Anoise(n-3) + rho2*Anoise(n-2) + rho1 * Anoise(n-1) + Anoise(n);
    end
    
    price =  abs(base_price + Anoise + linspace(0,-10,Nticks)');
    
    % thresholds for sale and buy , relative to std. dev.
    ts = (.5 * sd);
    tb = (.5 * sd);
    
    buyprice = price(1);
    sellprice = price(1);
    
    for n = round(linspace(2,Nticks, Nchoices))
        
        if (price(n) > buyprice + ts) && nstock(n)>0
            %convert stock to cash
            cash(n+1:end) = nstock(n) .* price(n)-transprice;
            nstock(n+1:end) = 0;
            %disp(['sell for ' num2str(price(n))]);
            sellprice = price(n);
            Ntrans = Ntrans +1;
        end
        
        if (price(n) < sellprice - tb) && cash(n)>0
            % convert cash to stock
            nstock(n+1:end) = (cash(n)-transprice)/price(n);
            cash(n+1:end) = 0;
            %disp(['buy for ' num2str(price(n))]);
            buyprice = price(n);
            Ntrans = Ntrans +1;
        end
        
    end
    
    sv = nstock .* price;
    
    %{
    
    subplot(211)
    plot(price)
    
    subplot(212)
    plot(sv)
    hold on
    plot(cash,'g')
    plot(nstock.*price,'k')
    axis([0 Nticks 0 2e4])
    hold off
    drawnow
    %}

    
    gains(m) = sv(n) + cash(n) - sv(1) - Ntrans * transprice ;
end

hist(gains,50)
