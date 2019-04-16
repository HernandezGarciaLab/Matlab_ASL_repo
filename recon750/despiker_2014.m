function [indices,s,m,mCount]=despiker_2014(pfilename , spike_threshold, fastrecflag, showData ,year)
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

% $HeadURL: svn+ssh://klitinas@anger.engin.umich.edu/svn/matlab/img/trunk/despiker_2014.m $
% $Id: despiker_2014.m 1525 2014-09-22 14:53:41Z klitinas $

% Check if scanner software version specified
% fid = fopen(pfilename,'r','l');
fid = fopen(pfilename,'r');
s_hdr = read_gehdr(fid);
rev = s_hdr.rdb.rdbm_rev;  % old = 9, new = 20?

% Get the year, if not defined.
if ~exist('year','var')
    strDate = deblank(s_hdr.rdb.scan_date);
    year = 2000 + str2double(strDate(end-1:end));
end

if round(rev) < 20
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
        endian = 'ieee-le'; 
        RAWHEADERSIZE = s_hdr.rdb.off_data;

end
HEADERSIZE = RAWHEADERSIZE;

% Open file for reading.
if ischar(pfilename),
    fid=fopen(pfilename,'r', endian);
    if (fid<3), disp('Could not open file! ...'); end;
else
    fid=pfilename;
end;

% Get header information
hdr=fread(fid, HEADERSIZE, 'uint8');
if round(rev) < 20

        [info1,fid] = locgetinfo(fid,1);
        [info2,fid] = locgetinfo(fid,2);
        [info3,fid] = locgetinfo(fid,3);
        
        rev_for =info3(12); 
        nslices = info1(3);
        nechoes = info1(4);
        nframes = info1(6);
        framesize = info1(9);
        psize = info1(10);
        
        % Get number of coils (should be 1)
        [ignore,info] = rec_setup1(pfilename,'m','l','fy','n',64);
        ncoils = info.ncoils;
else        

        nslices = s_hdr.rdb.nslices;
        nechoes = s_hdr.rdb.nechoes; % s_hdr.image.numecho;
        nframesActual = s_hdr.rdb.user1;
        nframes = s_hdr.rdb.nframes;
        framesize = s_hdr.rdb.frame_size;
        psize = s_hdr.rdb.point_size;
        
        % Account for number of coils
        info = useoriginalfieldnames(s_hdr);
        ncoils = info.s1.dab(2)-info.s1.dab(1)+1;
        rev_for = info.s1.user21;
        [~,scaninfo] = rec_setup1(pfilename,'V');
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
if psize == 4
    fmt='long';
else
    fmt='short';
end

indices=[];

% open the output file and stick the header and baseline in it
ofp=fopen(sprintf('f_%s', pfilename) ,'wb', endian);
fwrite(ofp, hdr, 'uint8');

% matrix of counts of spikes
%m = zeros(nframesKeep,nslices,ncoils);
m = [];
% mCount = zeros([nframesKeep 8092 nslices * slRep]);
mCount = zeros([nframesKeep framesize nslices * slRep]);

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
        
        % Fieldmap
        if isfieldmap(fid,scaninfo);
            fm = fread(fid, 2*framesize, fmt);
            raw = fread(fid, [2*framesize nframesKeep-1], fmt);
        else
            fm = [];
            raw = fread(fid, [2*framesize nframesKeep], fmt);
        end
            
        %%figure; plot(abs(fm)); pause(1); close(gcf);
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
        
        out=draw;
        
        % now do the filter (very crude stuff)
%         means = mean(out,1);
%         stds2 = std(out,0,1);
        means = mean(out(4:end-3,:),1);
        stds2 = std(out(4:end-3,:),0,1);     
        
        % filter 1: amplitudes
        strCoil = sprintf('c%d',c);
        strSlice = sprintf('s%d',sl);
        s.(strCoil).(strSlice).badrows = zeros(1,size(out,1));
        
       
        for col=1:size(out,2)
            
            thisColOut = out(:,col);
            % thisColMean = means(col);  % old this gave the mean of the complex data
            % thisColStd = stds2(col);
 			% For detecting spikes don't include end points
            % thisColOutTrimmed = thisColOut(4:end-3);

			thisColOutMag = abs(thisColOut);

            % For detecting spikes don't include beginning or end points
            thisColOutMagTrimmed = thisColOutMag(4:end-3);

			badRowsOne = find(thisColOutMag > mean(thisColOutMagTrimmed) + spike_threshold * std(thisColOutMagTrimmed));
			badRowsTwo = find(thisColOutMag < mean(thisColOutMagTrimmed) - spike_threshold * std(thisColOutMagTrimmed));

            % [old way]
            % badRowsOne = find(abs(thisColOut) > abs(thisColMean) + spike_threshold*abs(thisColStd));
            % badRowsTwo = find(abs(thisColOut) < abs(thisColMean) - spike_threshold*abs(thisColStd));
            badRows = [badRowsOne; badRowsTwo];
            
            % Get rows that were not corrupted
            iCount = 1:numel(thisColOut);
            iGoodRows = setdiff(iCount,badRows);
            
            % Loop through each bad element and replace with mean of nearest
            % non-spiked neighbors
            for r=1:length(badRows)
                thisBadRow=badRows(r);
                
                % Find mean of "nearest non-spiked neighbor" before and after the spike.  If there
                % are none in a given direction (before or after), just take the value before or after 
                iBefore = locgetnearestneighbor(thisBadRow,iGoodRows,'before');
                iAfter = locgetnearestneighbor(thisBadRow,iGoodRows,'after');
                
                spikeReplacer = mean([thisColOut(iBefore) thisColOut(iAfter)]);
                out(thisBadRow,col) = spikeReplacer;
                s.(strCoil).(strSlice).badrows(thisBadRow) =s.(strCoil).(strSlice).badrows(thisBadRow)+1;
                mCount(thisBadRow,col,sl) = 1;
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
        
        s.(strCoil).(strSlice).out = out;
        s.(strCoil).(strSlice).raw = draw;
        
        % put the data in the right format for writing
        %out2=zeros(nframesKeep , framesize*2);
        out2=zeros(nframesKeep-1 , framesize*2);
        for count=1:framesize
            out2(:,2*count-1) = re_out(:,count);
            out2(:,2*count) = im_out(:,count);
        end
        
        fwrite(ofp, baseline, fmt);
        fwrite(ofp,fm,fmt);
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
        
    m(:,sl,c) = s.(strCoil).(strSlice).badrows;
    
        
    end
    
end

% Close file
if ischar(pfilename),
    fclose(fid);
end;
fclose(ofp);

[~,strName] = fileparts(pfilename);
strFileMat = sprintf('despiker_%s.mat',strName);
save(strFileMat,'s','mCount')

% -----------------------------------------
function [info,fid] = locgetinfo(fid,numLoc)
RDBRAWHEADEROFFSET=30;  % For version 4 use 30.
switch numLoc
    case 1
        loc = RDBRAWHEADEROFFSET + 34;
        sz = 10;
        strPrecision = 'short';
    case 2
        loc = RDBRAWHEADEROFFSET + 70;
        sz = 6;
        strPrecision = 'short';
    case 3
        loc = RDBRAWHEADEROFFSET + 186;
        sz = 50;
        strPrecision = 'float';
    otherwise
        error('fmrilab:despike:invalidinput','Invalid location %d to read from',numLoc);
end

status = fseek(fid,loc,'bof');
if status
    fprintf('Could not seek to file location %d! ...',numLoc);
end
info = fread(fid,sz,strPrecision);

% ----------------------------------------------------------------------------
function iNeighbor = locgetnearestneighbor(iBadRow,iGoodRows,strBeforeOrAfter)
switch lower(strBeforeOrAfter)
    case 'before'
        iDirection = iGoodRows < iBadRow;
    case 'after'
        iDirection = iGoodRows > iBadRow;
end

dirGoodRows = iGoodRows(iDirection);

% Returns last index (for before case) or first index (for after case) or
% empty if there are no good data points in the give direction
if ~isempty(dirGoodRows)
    if strcmpi(strBeforeOrAfter, 'before')
        iNeighbor = dirGoodRows(end);
    else
        iNeighbor = dirGoodRows(1);
    end
else
    iNeighbor = [];
end