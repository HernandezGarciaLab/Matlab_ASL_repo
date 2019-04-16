function [indices,s] = despiker(pfilename , spike_threshold, fastrecflag, showData ,year)
% Usage ... indices = despiker(pfile, spike_threshold, fastrecflag, showData [,year])
%
% search for spikes in the kspace data and replace them by the mean of
% that point in kspace over the time series.
%
% a spike is defined as a point that has a value spike_threshold*stdDev greater than the
% mean of that spike location.
%
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
%  For sf3d - slc is the phase encode of interest and frm
%  would be the spiral shot of interest (0 is the baseline).
%
%  nslices=info1(3);
%  nechoes=info1(4);
%  nexcitations=info1(5);
%  nframes=info1(6);
%  framesize=info1(9);
%  psize=info1(10);

% $Id: despiker.m 1544 2014-10-02 19:38:53Z klitinas $
% $HeadURL: svn+ssh://klitinas@anger.engin.umich.edu/svn/matlab/img/trunk/despiker.m $

% Check if scanner software version specified
% fid = fopen(pfilename,'r','l');
s_hdr = ge_pfilehdr(pfilename);

% fid = fopen(pfilename,'r');
% s_hdr = read_gehdr(fid);
rev = s_hdr.rdb.rdbm_rev;  % < 20 is super old
if rev < 20
        % default if year is not specified....
        RAWHEADERSIZE=61464;
        endian = 'ieee-be';
        if nargin==5
            switch year
                case 2003
                    RAWHEADERSIZE=40080;
                case 2004
                    RAWHEADERSIZE=60464;
                case 2005
                    RAWHEADERSIZE=61464;
                    endian = 'ieee-le';
                    
            end
            if (year>=2005)
                RAWHEADERSIZE=61464;
                endian = 'ieee-le';
            end
        end
else
        % RAWHEADERSIZE = 149788;
        RAWHEADERSIZE = s_hdr.rdb.off_data;
        endian = 'ieee-le'; 
   
end
HEADERSIZE = RAWHEADERSIZE;

if ischar(pfilename),
    fid=fopen(pfilename,'r', endian);
    if (fid<3), disp(['Could not open file! ...']); end;
else
    fid=pfilename;
end;

RDBRAWHEADEROFFSET=30;  % For version 4 use 30.
LOC1 = RDBRAWHEADEROFFSET + 34;
LOC2 = RDBRAWHEADEROFFSET + 70;
LOC3 = RDBRAWHEADEROFFSET + 186;

% Get header information
hdr=fread(fid, HEADERSIZE, 'uint8');
if rev < 20
           
        status = fseek(fid,LOC1,'bof');
        if (status), disp(['Could not seek to file location 1! ...']); end;
        info1 = fread(fid,10,'short');
        
        status = fseek(fid,LOC2,'bof');
        if (status), disp(['Could not seek to file location 2! ...']); end;
        info2 = fread(fid,6,'short');
        
        status = fseek(fid,LOC3,'bof');
        if (status), disp(['Could not seek to file location 3! ...']); end;
        info3 = fread(fid,50,'float');
        
        nShots = info3(5);
        rev_for =info3(12)
        
        nslices = info1(3);
        nechoes = info1(4);
        nexcitations = info1(5);
        nframes = info1(6);
        framesize = info1(9);
        psize = info1(10);
    
        % Get number of coils (should be 1)
         [args,info] = rec_setup1(pfilename,'m','l','fy','n',64);
         ncoils = info.ncoils;
else         
        rev_for = s_hdr.rdb.user11; % [in v9 is info.s1.user11]
        nslices = s_hdr.rdb.nslices;
        nechoes = s_hdr.rdb.nechoes; % s_hdr.image.numecho;
        nframesActual = s_hdr.rdb.user1;
        nframes = s_hdr.rdb.nframes;
        framesize = s_hdr.rdb.frame_size;
        psize = s_hdr.rdb.point_size;
        
        % Account for number of coils
        % info = useoriginalfieldnames(s_hdr);
        % ncoils = info.s1.dab(2)-info.s1.dab(1)+1;
        ncoils = s_hdr.rdb.dab(2)-s_hdr.rdb.dab(1)+1;
        rev_for = s_hdr.rdb.user21;
end

nfidsperslice = nechoes * (nframes+1)-1;
baselinesize = framesize;

% Spiral in/out
if rev_for == 2 && round(rev) >= 20
    slRep = 2;
    nframesKeep = nframes;
    %indices = [0:nframes-1; zeros(1,nframes); zeros(1,nframes)];
else
    slRep = 1;
    nframesKeep = nfidsperslice;
    %indices=[0:nfidsperslice-1; zeros(1,nfidsperslice)];
end

% For an even number of time points, have to account for extra (bogus) frame stored
% in pfile
if mod(nframesActual,2)
    %indices=indices(:,1:end-1);
    nframesKeep = nframesKeep-1;
end

% Seek to end of header in file
status=fseek(fid,RAWHEADERSIZE ,'bof');
if (status),error(['Could not seek to file fid location! ...']); end;

% data type here
if (psize==4),
    fmt='long';
else
    fmt='short';
end

indices=[];

% open the output file and stick the header and baseline in it
ofp=fopen(sprintf('f_%s', pfilename) ,'wb', endian);
fwrite(ofp, hdr, 'uint8');

% Do one coil at a time (for multichannel stuff)
for c = 1:ncoils

    % do one slice at a time
    for sl=1:nslices * slRep
        
        % read the complex data in
        if mod(nframesActual,2) && sl~=1    
            baseline=fread(fid, 4*baselinesize, fmt);
        else
            baseline=fread(fid, 2*baselinesize, fmt); 
        end
        
        raw = fread(fid, [2*framesize nframesKeep], fmt);
        raw = raw';
        re_raw = raw(:, 1:2:2*framesize);
        im_raw = raw(:, 2:2:2*framesize);
        raw = complex(re_raw, im_raw);

        %figure; plot(1:size(raw,2),abs(raw));
        if nargin<2, fastrecflag=1; end;
        if nargin<3, showData=0; end;
        
        if (fastrecflag),
            %demodulation?
            th = 2*pi*[1:framesize]'/4;
            th = kron(th , ones(1,size(raw,1)));
            draw = raw.*exp(-i*th');
        else
            draw =raw;
        end;
        
        
        out = zeros(size(draw));
        out=draw;
        %     % detrend the data
        %     t=[1:size(draw,1)]';
        %
        %     for col=1:size(out,2)
        %         [coeffs, error] = polyfit(t,draw(:,col),2) ;
        %         out(:,col) = raw(:,col) ...
        %             - coeffs(2)*t ...
        %             - coeffs(1)*t.^2 ;...
        %             %- coeffs(1)*t.^3 ;
        %         % leave the mean in there
        %     end
        %
        % now do the filter (very crude stuff)
        
        means = mean(out,1);
        stds2 = std(out,0,1);
        
        strCoil = sprintf('c%d',c);
        strSlice = sprintf('s%d',sl);
        s.(strCoil).(strSlice).badrows = zeros(1,size(out,1));
        
        % filter 1: amplitudes
        for col=1:size(out,2)
            
            badrows = find(abs(out(:,col)) > ...
                (abs(means(col)) + spike_threshold*abs(stds2(col))) );
            %fprintf('\rProcessing point %d of %d slice %d',col,size(out,2),sl);
            for r=1:length(badrows)
                row=badrows(r);
                out(row,col) = means(col);
                s.(strCoil).(strSlice).badrows(row) =s.(strCoil).(strSlice).badrows(row)+1;
                % mCount(row,col,sl) = 1;
            end
        end
        
        
        
        if (showData==1),
            %if (nargout==0),
            if (nargin==1),
                info1
                info2
                info3
            else,
                subplot(221)
                imagesc(abs(raw));
                title('input')
                colorbar
                subplot(222)
                imagesc(abs(out));
                title('output')
                colorbar
                subplot(223)
                imagesc(abs(draw - out));
                title('abs(input - output)')
                colorbar
                for ct=2:size(raw,1)
                    subplot(224)
                    %plot(out2(ct,1:2:end));
                    %title(sprintf('output FID number: %d',ct));
                    %hold on
                    %plot(out2(ct,2:2:end),'r');
                    %hold off
                    plot(abs(draw(ct-1,:) - draw(ct,:)));
                    hold on
                    plot(abs(out(ct-1,:) - out(ct,:)),'r');
                    hold off
                    title('(thisFID - lastFID)');
                    legend('in', 'out')
                    %axis([0 4000 0 100])
                    
                    %pause
                    subplot(223)
                    plot(abs(draw(ct,:)));
                    hold on
                    plot(abs(out(ct,:)),'r');
                    hold off
                    title(sprintf('slice: %d , FID # %d',sl, ct));
                    legend('in', 'out')
                    %axis([0 4000 0 100])
                    drawnow
                end;
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
        out2=zeros(nframesKeep , framesize*2);
        for count=1:framesize
            out2(:,2*count-1) = re_out(:,count);
            out2(:,2*count) = im_out(:,count);
        end
        
        fwrite(ofp, baseline, fmt);
        for ct=1:size(out2,1)
            %fprintf('\rWriting point %d of %d ..slice %d',ct,size(out2,2),sl);
            
            fwrite(ofp, out2(ct,:), fmt);
        end
        
        % For runs w/ even number of volumes, for last slice put in the
        % last extra frame data
        if mod(nframesActual,2) && sl==nslices * slRep % && c==ncoils
            % tmp = fread(fid,inf,fmt);
            tmp = fread(fid,2*framesize,fmt);
            re_t = tmp(1:2:end); im_t = tmp(2:2:end); c_t = complex(re_t,im_t);
            %figure; plot(1:length(c_t),abs(c_t),'g')
            fwrite(ofp,tmp,fmt);            
        end
    end
    
end

if isstr(pfilename),
    fclose(fid);
end;
fclose(ofp);


