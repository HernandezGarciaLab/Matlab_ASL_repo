% read avi. videos

addpath(genpath(pwd));
v = VideoReader('fc2_save_2018-03-27-153236-0000.avi');

FrameRate = round(v.FrameRate);
Duration = floor(v.Duration);
FrameNum = FrameRate * Duration;

FrameSum = zeros(FrameNum,1);
for i=1:FrameNum
    video = readFrame(v);
    FrameSum(i)=sum(sum(sum(video)));
end
figure()
plot(FrameSum)

%current stimulus is 1HZ
TimeAvg_FrameSum = sum(reshape(FrameSum,FrameRate,Duration),2);
figure()
plot(TimeAvg_FrameSum)




%%
%read bmp images

addpath(genpath(pwd));

FrameSum = [];
for num=0:148
    num_str = num2str(num,'%04d');
    filename = ['./tmp/fc2_save_2018-03-23-155655-',num_str,'.bmp'];
	A = imread(filename);
    FrameSum(num+1)=sum(sum(A));
end
figure()
plot(FrameSum)





