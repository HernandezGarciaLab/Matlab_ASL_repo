function [out,re_out,im_out,info1,info2,info3,ind]=filterraw(pfilename, bad_range ,fastrecflag, showData)
% Usage ... [out,re_out,im_out,info1,info2,info3,ind]=filterraw(pfilename, bad_range ,fastrecflag, showData)
%
% this file zeroes the frequencies indicated in the range (a vector of
% numbers)
% in all the frames of the indicated Pfile.
%
% pfilename = name of pass file from the GE scanner
% bad_range = vector of points to filer out 
%             e.g. [178:182] would remove 5 points from the frequency spectrum
% fastrecflag = 0 (obsolete:  A holdover from the pre-Excite hardware)
% showData - (No=0, Yes=1).  Display individual frames before and after filterring.  used
% for debug.  will run much slower with this flag turned on


% P file is organized as follows:
%  coil 1:
%  slice 1: baseline interleaves time1, interleaves time 2, etc...
%  slice 2: baseline interleaves time1, interleaves time 2, etc...
%  etc...
%  coil 2: same as above but some random skip between them
%  if #leaves and #points is odd then there is an extra baseline at end
%
%
%  Slice 1 Frame 0 is baseline (example, expect more)
%  Note: there is frame 0 but not slice 0!
%
%  nslices=info1(3);
%  nechoes=info1(4);
%  nexcitations=info1(5);
%  nframes=info1(6);
%  framesize=info1(9);
%  psize=info1(10);

if(nargin<2)    %look at the FFT for the first 4 subtractions and try to find the spike
        tmp= abs(fft(fftshift(readrawex(pfilename,1)-readrawex(pfilename,2))))+...
        abs(fft(fftshift(readrawex(pfilename,3)-readrawex(pfilename,4))))+...
        abs(fft(fftshift(readrawex(pfilename,5)-readrawex(pfilename,6))))+...
        abs(fft(fftshift(readrawex(pfilename,7)-readrawex(pfilename,8))));
    figure,plot(tmp);
    maxpoint=find(tmp==max(tmp(50:end-50)))
    bad_range=[maxpoint-2:maxpoint+2]
    drawnow, pause
    %keyboard
end

if(0)  %used for testing purposes.  loops through tons of FIDs to look for the spike
 for n=1:2:600
        tmp=abs(fft(fftshift(readrawex(pfilename,n)-readrawex(pfilename,n+1))));
    figure,plot(tmp);
    maxpoint=find(tmp==max(tmp(50:end-50)))
    bad_range=[maxpoint-2:maxpoint+2]
    drawnow, pause
    end
end


RAWHEADERSIZE=61464;
% old P files :% RAWHEADERSIZE=40080;
%RAWHEADERSIZE=60464;

HEADERSIZE=61464;
%HEADERSIZE=60464;
% old Pfiles:  HEADERSIZE=40080;

RDBRAWHEADEROFFSET=30;  % For version 4 use 30.
LOC1 = RDBRAWHEADEROFFSET + 34;
LOC2 = RDBRAWHEADEROFFSET + 70;
LOC3 = RDBRAWHEADEROFFSET + 186;
%OPXRESLOC = 74;
%OPYRESLOC = 76;
%NFRAMESLOC = 46;
%NSLICES =
%FRAMESIZELOC = 52;
%POINTSIZELOC = 54;

if isstr(pfilename),
   
    fid=fopen(pfilename,'r','l');
    [filename, mode, machinefmt]=fopen(fid);
  
   
    if (fid<3), disp(['Could not open file! ...']); end;
else
    fid=pfilename;
end;

hdr=fread(fid, HEADERSIZE, 'uchar');

status=fseek(fid,LOC1,'bof');
if (status), disp(['Could not seek to file location 1! ...']); end;
info1=fread(fid,10,'short');

status=fseek(fid,LOC2,'bof');
if (status), disp(['Could not seek to file location 2! ...']); end;
info2=fread(fid,6,'short');

status=fseek(fid,LOC3,'bof');
if (status), disp(['Could not seek to file location 3! ...']); end;
info3=fread(fid,50,'float');

% if (nargin==1),
%
%     if (nargout==1), f=[info1;info2;info3]; else, f=info1; end;
%     qm=info2;
%     im=info3;
%     if (nargout==0), [info1;info2;info3], clear, end;
%     return
%
%else,

nslices=info1(3);
nechoes=info1(4);
nexcitations=info1(5);
nframes=info1(6);
framesize=info1(9);
psize=info1(10);

nfids = nslices * nechoes * (nframes+1)-1;

%    status=fseek(fid,-nfids*framesize*2*psize - 2*psize*48 ,'eof');
%    status=fseek(fid,-nfids*framesize*2*psize ,'eof');
%    status=fseek(fid,RAWHEADERSIZE + 2*framesize*psize,'bof');
status=fseek(fid,RAWHEADERSIZE ,'bof');
if (status),error(['Could not seek to file fid location! ...']); end;

% data type here
if (psize==4),
    fmt=['long'];
else,
    fmt=['short'];
end;


% read the complex data in
baseline=fread(fid, 2*framesize, fmt);
%baseline=fread(fid, 2*framesize, fmt);
%ind=ftell(fid)
figure
for fidindx=1:nfids
    raw = fread(fid, 2*framesize, fmt);
    raw = raw';
    re_raw = raw(:, 1:2:2*framesize);
    im_raw = raw(:, 2:2:2*framesize);
    raw = complex(re_raw, im_raw);


    if nargin<3, fastrecflag=0; end;
    if nargin<4, showData=0; end;

    if (fastrecflag),
        %demodulation?
        th = 2*pi*[1:framesize]'/4;
        th = kron(th , ones(1,size(raw,1)));
        draw = raw.*exp(-i*th');
    else
        draw =raw;
    end;

    % now do the filter (very crude stuff)
    fdraw = fft(draw,[],2);
    fout = fdraw;
    fout(:,bad_range)= 0;

    out = ifft(fout,[],2);


    if (showData==1),
        %if (nargout==0),
        if (nargin==1),
            info1
            info2
            info3
        else,
            subplot(221)
            plot(abs(fdraw))
            title('FFT along k axis of input')
            subplot(222)
            plot(abs(fout))
            title('FFT along k axis of output')
            subplot(223)
            plot(abs(fdraw-fout))
            title('Difference in FFTs')
            subplot(224)
            plot(abs(raw - out)); xlabel('time')
            title('abs(input - output) (time domain)')
          drawnow;
        end
    end

    if (fastrecflag),
        % modulation?
        out = out.*exp(i*th');
    end;
    %%%%%%%%%%
    %out=raw;
    %%%%%%%%%%

    re_out = real(out);
    im_out = imag(out);

    % put the data in the right format for writing
    out2=zeros(1 , framesize*2);
    for count=1:framesize
        out2(1,2*count-1) = re_out(1,count);
        out2(1,2*count) = im_out(1,count);
    end
    % Write the output P file
    if(fidindx==1)
        fp=fopen(sprintf('f_%s', pfilename) ,'wb', 'ieee-le');
        fwrite(fp, hdr, 'uchar');

        fwrite(fp, baseline, fmt);
    end
    fwrite(fp, out2(1,:), fmt);
end

fclose(fp);

if isstr(pfilename),
    fclose(fid);
end;

