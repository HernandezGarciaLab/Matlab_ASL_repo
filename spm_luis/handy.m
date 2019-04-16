names = dir('avol*.img');
h = read_hdr('avol0002.hdr');

avg1 = 0;
% active scans
for count=8:39
    names(count).name
    d=read_img_data(h, names(count).name);
    avg1=avg1+d;
end

avg1 = avg1/31;


avg2=0;
for count=2:7
    names(count).name
    d=read_img_data(h, names(count).name);
    avg2=avg2+d;
end
for count=40:46
    names(count,:)
    d=read_img_data(h, names(count).name);
    avg2=avg2+d;
end

avg2 = avg2/11;

activ = avg1-avg2;

write_hdr('activ.hdr',h);
write_img_data('activ.img',activ,h);