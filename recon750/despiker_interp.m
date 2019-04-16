function indices=despiker_interp(pfilename , spike_threshold, fastrecflag, year, skip_frame)
% Usage ... indices = despiker(pfile, spike_threshold, fastrecflag, [,year] [,skip_frame])
% 
%  modified by W. Yau 6/27/2008 
%   in
%       start_frame     # of frames to skip from front (defaults to 0, i.e. no frames skipped)
%
% search for spikes in the kspace data and replace them by the mean of
% that point in kspace over the time series.
%
% a spike is defined as a point that has a value spike_threshold*stdDev greater than the
% mean of that spike location.
%
% P file is organized as follows (8/26/13: updated for mr_750 scanner):
%  coil 1:
%       slice 1: a) baseline followed by spiral in data (fieldmap, spInTime1, spInTime2,.. spInTimeN etc...
%                b) spiral in data: 
%                   i) fieldmap
%                   ii) spInTime1, spInTime2,...spInTimeN.  If N is even, extra
%                       volume after.
%                c) [if applicable] spiral out data:
%                   i) fieldmap
%                   ii) spOutTime1, spOutTime2,...spOutTimeN.  If N is even, extra
%                       volume after.
%       slice 2: same format as slice 1,
%       etc...
%  coil 2: same as above 
% 
% $Id: despiker_interp.m 1728 2015-08-14 16:40:22Z klitinas $
% $HeadURL: svn+ssh://klitinas@anger.engin.umich.edu/svn/matlab/img/trunk/despiker_interp.m $

% Check if scanner software version specified
% fid = fopen(pfilename,'r');
% s_hdr = read_gehdr(fid);

s_hdr = ge_pfilehdr(pfilename);
rev = s_hdr.rdb.rdbm_rev; 

if rev < 20
        % default if year is not specified....
        RAWHEADERSIZE=61464;
        endian = 'ieee-le';
        if nargin>4
            switch year
                case 2003
                    RAWHEADERSIZE=39984;
                    endian = 'ieee-be';
                case 2004
                    RAWHEADERSIZE=60464;
                    endian = 'ieee-be';
                case 2005
                    RAWHEADERSIZE=61464;
                    
            end
            if (year>=2005)
                RAWHEADERSIZE=61464;
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
        nslices = s_hdr.rdb.nslices;
        nechoes = s_hdr.rdb.nechoes; 
        nframes = s_hdr.rdb.nframes;
        
        % This is the number of time points + 1 (extra is for fieldmap)
        nframesActual = s_hdr.rdb.user1;  
        framesize = s_hdr.rdb.frame_size;
        psize = s_hdr.rdb.point_size;
        
        % Account for number of coils
        % info = useoriginalfieldnames(s_hdr);
        % ncoils = info.s1.dab(2)-info.s1.dab(1)+1;
        
        % 8/20/13:  Changed to point to rev_flg in header (2 = in/out)
        % rev_for = info.s1.user21;
        ncoils = s_hdr.rdb.dab(2)-s_hdr.rdb.dab(1)+1;
        rev_for = s_hdr.rdb.user21;
end

baselinesize = framesize;
nfidsperslice = nechoes * (nframes+1)-1;

if rev_for == 2 && round(rev) >= 20 % Spiral in/out
    slRep = 2;  % For spiral in/out, iterate (2*nslices) times - for each slice, will do spiral in, spiral out separately.
    nframesKeep = nframes;
    indices = [0:nframes-1; zeros(1,nframes); zeros(1,nframes)];  % 2nd row is spiral in, 3rd spiral out (will sum at end)
else  % Not spiral in/out
    slRep = 1;  % One direction only, iterate nslices times.
    nframesKeep = nfidsperslice;
    indices=[0:nfidsperslice-1; zeros(1,nfidsperslice)];
end

% For an even number of time points, have to account for extra vol stored in pfile
if mod(nframesActual,2)
    indices=indices(:,1:end-1);
    nframesKeep = nframesKeep-1;
end

% Seek to end of header in file
status=fseek(fid,RAWHEADERSIZE ,'bof');
if (status),error(['Could not seek to file fid location! ...']); end;

% data type here
if psize==4
    fmt='long';
else
    fmt='short';
end

% open the output file and stick the header and baseline in it
ofp=fopen(sprintf('f_%s', pfilename) ,'wb', endian);
fwrite(ofp, hdr, 'uint8');

% Do one coil at a time
for c = 1:ncoils
    
    % do one slice at a time
    for sl=1:nslices * slRep
        
        % Read baseline
        % For even number of timepoints, consider extra vol as part of the baseline.
        if mod(nframesActual,2) && sl~=1    
            baseline=fread(fid, 4*baselinesize, fmt);
        else
            baseline=fread(fid, 2*baselinesize, fmt); 
        end
        
        % Read raw data (fieldmap + actual vols), complexify it.
        raw = fread(fid,[2*framesize nframesKeep],fmt);

        raw = raw';
        re_raw = raw(:, 1:2:2*framesize);
        im_raw = raw(:, 2:2:2*framesize);
        raw = complex(re_raw, im_raw);
        
        % figure;plot(1:size(raw,2),abs(raw));
        if (fastrecflag),
            %demodulation?
            th = 2*pi*[1:framesize]'/4;
            th = kron(th , ones(1,size(raw,1)));
            draw = raw.*exp(-i*th');
        else
            draw =raw;
        end
        
        out = zeros(size(draw));
        
        if skip_frame > 0
            out = draw((1+skip_frame):end,:);
        else
            out = draw;
        end
        
        hbadrows = zeros(1, size(out,1));
        
        % now do the filter (very crude stuff)
        
        % filter 1: amplitudes (valur version)
        aout = abs(out);
        meansa = mean(aout,1);
        stds2 = std(out,0,1);
        
        for col=1:size(out,2)
            badrows = find(aout(:,col) > ...
                (meansa(col) + spike_threshold*stds2(col)) );
            
            goodrows = find(aout(:,col) <= ...
                (meansa(col) + spike_threshold*stds2(col)) );
            
            
            lastrow = length(badrows);
            if (badrows) > 0
                if badrows(1) == 1
                    out(1,col) =  interp1(goodrows, out(goodrows,col), 1, 'nearest', 'extrap');
                end
                
                if badrows(lastrow) == size(out,1)
                    out(size(out,1),col) =  interp1(goodrows, out(goodrows,col), size(out,1), 'nearest', 'extrap');
                end
                
                out(:,col) = interp1(goodrows, out(goodrows,col), 1:size(out,1), 'linear', 'extrap');
                hbadrows = hbadrows + hist(badrows, 1:size(out,1));
                
                if badrows(1) == 1
                    out(1,col) =  interp1(goodrows, out(goodrows,col), 1, 'nearest', 'extrap');
                end
                
                if badrows(lastrow) == size(out,1)
                    out(size(out,1),col) =  interp1(goodrows, out(goodrows,col), size(out,1), 'nearest', 'extrap');
                end
            end
            
        end
        
        if skip_frame > 0
            if sl > nslices
                indices(3,:) = indices(3,:) + [zeros(1,skip_frame) hbadrows];
            else
                indices(2,:) = indices(2,:) + [zeros(1,skip_frame) hbadrows];
            end
                        
            out = [draw(1:skip_frame,:); out];  % add back the zeroth frame of this slice
        else
            if sl > nslices
                indices(3,:) = indices(3,:) + hbadrows;
            else
                indices(2,:) = indices(2,:) + hbadrows;
            end
        end
        
        if (fastrecflag),
            % modulation?
            out = out.*exp(i*th');
        end;
        
        re_out = real(out);
        im_out = imag(out);
        
        % put the data in the right format for writing
        out2 = zeros(nframesKeep, framesize*2);
            
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
        if mod(nframesActual,2) && sl==nslices * slRep
            % tmp = fread(fid,inf,fmt);
            tmp = fread(fid,2*framesize,fmt);

            fwrite(ofp,tmp,fmt);            
        end
    end
    
end

% If spiral in/out, sum the spiral in (2nd row) and spiral out (3rd row) of
% indices matrix to get total number of spikes for that time point.
if rev_for == 2
    indices = [indices(1,:); sum(indices(2:3,:))];
end
    
if ischar(pfilename),
    fclose(fid);
end
fclose(ofp);


