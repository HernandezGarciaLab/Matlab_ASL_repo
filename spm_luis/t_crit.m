% find critical score for this significance level(alpha)
   x_mean =0;
   x_sigma = 1;
   
    for index=1:100
        t = 0;
        p=100;  %(some initial value)
	alpha = index*0.001;   
    	while (p >= alpha),
  		p=(1-normcdf(t,x_mean,x_sigma));
  		t = t + x_sigma/10;
    	end
    	critical(index,:) = [alpha t];
    end
    
    disp (critical)
