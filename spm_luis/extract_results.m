cd ('/net/stanley/data/keithn/020205kd/020205kd/func/pain/RESULTS/cl_delay0.00')

h=read_hdr('spmT_0002.hdr');n=1;
disp('constant delays = 10 seconds');
disp('delay   L insula       ACC        R temporal lobe');
for k = -0.4:0.2:1.0
    str=sprintf('a = read_img2(h,''../cl_delay%3.2f/spmT_0002.img'');',k);
    eval(str);
    tscore(n,:) = [k a(23,32,7)  a(35,38,16)  a(47,38,9)];
    n=n+1;
end

tscore



h=read_hdr('spmT_0002.hdr');
n=1;
disp('variable delays from COVAS temp. data')
disp('delay   L insula       ACC        R temporal lobe');
for k = -0.4:0.2:1.0
    str=sprintf('a = read_img2(h,''../delay%3.2f/spmT_0002.img'');',k);
    eval(str);
    tscore(n,:) = [k a(23,32,7)  a(35,38,16)  a(47,38,9)];
    n=n+1;
end
tscore

clear
cd ('/net/stanley/data/keithn/020205lc/020205lc/func/pain/RESULTS/cl_delay0.00')

h=read_hdr('spmT_0002.hdr');n=1;
disp('constant delays = 10 seconds');
disp('delay  L insula       ACC        R temporal    L parietal');
for k = -0.4:0.2:1.0
    str=sprintf('a = read_img2(h,''../cl_delay%3.2f/spmT_0002.img'');',k);
    eval(str);
    tscore(n,:) = [k a(20,33,11)  a(33,38,14)  a(48, 38, 11) a(27,19,11)];
    n=n+1;
end
tscore

clear

h=read_hdr('spmT_0002.hdr');n=1;
disp('variable delays as recorded by COVAS');
disp('delay   L insula       ACC        R temporal    L parietal');
for k = -0.4:0.2:1.0
    str=sprintf('a = read_img2(h,''../delay%3.2f/spmT_0002.img'');',k);
    eval(str);
    tscore(n,:) = [k a(20,33,11)  a(33,38,14)  a(48, 38, 11) a(27,19,11)];
    n=n+1;
end

tscore


