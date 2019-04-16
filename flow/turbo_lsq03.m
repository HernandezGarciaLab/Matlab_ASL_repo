function result=turbo_lsq03( est , tr_vec, consts, data )
% function result=turbo_lsq03( est , tr_vec, consts, data )
%
% this version uses a gamma function uses Greg's analytical solution...
%
%
Ttrans=est(1);
f=est(2) ;

R1art=consts(1);
R1t=consts(2);
alpha = consts(3);
del = consts(4);
M0 = consts(5);


T1a = 1/R1art;  %T1 of arterialscale blood in s
T1b = 1/R1t;  %T1 of brain in s

rho=1;    %water extraction fraction (a number between 0 and 1)
lamda = 0.9;  %blood brain partition coefficient
T1eff = 1/(f/lamda+1/T1b);

slicetime = 0.046;
tag_durations = tr_vec-0.220;  %slicetime*nslices;

for (index=1:length(tag_durations)),

    tag_duration=tag_durations(index);
    %Scan parameters

    TR =  tr_vec(index)+0.001;  %repetition time in s

    Tsamp=tag_duration+del;
    Tsamp1=TR-Tsamp;
    % [TR tag_duration del Tsamp Tsamp1]


    const1=2*M0*f*T1eff*alpha*exp(-Ttrans./T1a);  %This same constant is present in all cases below
    myratio=(Ttrans+Tsamp1)/TR;
    temptime=(myratio-floor(myratio))*TR-Tsamp1-1e-4;     %time from the beginning of the TR until the tag starts to arrive   %need -1e-4 to make the sampling always fall on the proper side of the boundary
    analytic3=zeros(1,2);

    for q=1:2  %The same for every pair of tr_vec.  So just do it for the first 2 tr_vec when the tag arrives
        vec(q)=(tag_duration+del+(floor(myratio)+q-1)*TR);

        if((temptime+tag_duration)<TR-Tsamp1)             %Case when all the tag arrival falls within a single TR
            %               str=sprintf('case31'); display(str);
            analytic3(q)=analytic3(q)+...
                (vec(q)>=Ttrans).*(vec(q)<=Ttrans+tag_duration).*(const1.*(1-exp(-(vec(q)-Ttrans)./T1eff)))...
                +(vec(q)>Ttrans+tag_duration).*(vec(q)<(floor(myratio)*TR+tag_duration+del+0.001)).*(const1.*exp(-(vec(q)-Ttrans-tag_duration)./T1eff).*(1-exp(-(tag_duration./T1eff))));
            %OLD LINE       +(vec(q)>Ttrans+tag_duration).*(vec(q)<(ceil(myratio)*TR)).*(const1.*exp(-(vec(q)-Ttrans-tag_duration)./T1eff).*(1-exp(-(tag_duration./T1eff))));
        elseif((Ttrans+tag_duration)>=TR-Tsamp1)    %Case when the tag arrival is spread over 2 tr_vec
            %              str=sprintf('case32'); display(str);
            analytic3(q)=analytic3(q)+...
                (vec(q)>=Ttrans).*(vec(q)<=Ttrans-temptime+TR-Tsamp1).*(const1.*(1-exp(-(vec(q)-Ttrans)./T1eff)))...
                +(vec(q)>Ttrans-temptime+TR-Tsamp1).*(vec(q)<=Ttrans+tag_duration).*(const1.*(1-exp(-(vec(q)-Ttrans+temptime-TR+Tsamp1)/T1eff)))...
                +(vec(q)>Ttrans+tag_duration).*(const1.*exp(-vec(q)./T1eff).*(exp((Ttrans+tag_duration)/T1eff)-exp((Ttrans-temptime+TR-Tsamp1)./T1eff)));
        end
    end

    if(mod(floor(myratio),2))  %Make sure to keep the sign of the subtraction correct
        signal(index)=diff(analytic3);
    else
        signal(index)=-diff(analytic3);
    end

end
curve = zeros(size(tr_vec));


if nargin==3
    result = signal;
else
    result = data - signal;
end

return

