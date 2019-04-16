function [indices,s] = despiker_rds(strFile , spike_threshold, fastrecflag, showData)
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

% $Id: despiker_rds.m 1699 2015-04-13 15:00:05Z klitinas $
% $HeadURL$

% Check if scanner software version specified
% fid = fopen(pfilename,'r','l');

% fid = fopen(pfilename,'r');
% s_hdr = read_gehdr(fid);

[strPath,strName] = fileparts(strFile);
strFileDat = fullfile(strPath,[strName '.data']);
strFilePrep = fullfile(strPath,[strName '.prep']);

if ischar(strFileDat),
    fid=fopen(strFileDat,'r');
    if (fid<3), disp(['Could not open file! ...']); end;
else
    fid=strFileDat;
end;

% Get header information
hdr.rdb = ge_readhdr_streaming_prepfile(strFilePrep);
[~,scaninfo] = rec_setup1_streaming_dv24(strFilePrep,'V');

nslices = hdr.rdb.nslices;
nechoes = hdr.rdb.nechoes; % s_hdr.image.numecho;
nframesActual = hdr.rdb.user1;
nframes = hdr.rdb.nframes;
framesize = hdr.rdb.frame_size;
psize = hdr.rdb.point_size;

% Account for number of coils
% info = useoriginalfieldnames(s_hdr);
% ncoils = info.s1.dab(2)-info.s1.dab(1)+1;
ncoils = hdr.rdb.dab(2)-hdr.rdb.dab(1)+1;
rev_for = hdr.rdb.user21;


nfidsperslice = nechoes * (nframes+1)-1;
% baselinesize = framesize;
baselinesize = 0;
nframesKeep = nfidsperslice;

% Spiral in/out
slRep = 1;
% if rev_for == 2 && round(rev) >= 20
%     slRep = 2;
%     nframesKeep = nframes;
%     %indices = [0:nframes-1; zeros(1,nframes); zeros(1,nframes)];
% else
%     slRep = 1;
%     nframesKeep = nfidsperslice;
%     %indices=[0:nfidsperslice-1; zeros(1,nfidsperslice)];
% end

% For an even number of time points, have to account for extra (bogus) frame stored
% in pfile
if mod(nframesActual,2)
    %indices=indices(:,1:end-1);
    nframesKeep = nframesKeep-1;
end

% data type here
if (psize==4),
    fmt='long';
else
    fmt='short';
end

indices=[];

% open the output file and stick the header and baseline in it
% ofp=fopen(sprintf('f_%s', strFileDat) ,'wb', endian);
% % ofp=fopen(sprintf('f_%s', strFileDat) ,'wb', 'l');
% % fwrite(ofp, hdr, 'uint8');

% for c = 1:ncoils
%     for sl = 1:nslices
for sl = 1:nslices
    ofp=fopen(sprintf('f_sl%02d_%s', sl,strFileDat) ,'wb', 'l');
    for c = 1:ncoils
       thisDat = loaddat_rds_coil(c-1,sl-1,scaninfo,fid);
       raw = thisDat.';
%        draw = raw;
%     end   
% end



% % Do one coil at a time (for multichannel stuff)
% for c = 1:ncoils
% 
%     % do one slice at a time
%     for sl=1:nslices * slRep
%         
%         % read the complex data in
        if mod(nframesActual,2) && sl~=1    
            baseline=fread(fid, 4*baselinesize, fmt);
        else
            baseline=fread(fid, 2*baselinesize, fmt); 
        end
%         
%         raw = fread(fid, [2*framesize nframesKeep], fmt);
%         raw = raw';
%         re_raw = raw(:, 1:2:2*framesize);
%         im_raw = raw(:, 2:2:2*framesize);
%         raw = complex(re_raw, im_raw);

        %plot(abs(raw'));pause(1);
        
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
% %         if mod(nframesActual,2) && sl==nslices * slRep % && c==ncoils
% %             % tmp = fread(fid,inf,fmt);
% %             tmp = fread(fid,2*framesize,fmt);
% %             re_t = tmp(1:2:end); im_t = tmp(2:2:end); c_t = complex(re_t,im_t);
% %             %figure; plot(1:length(c_t),abs(c_t),'g')
% %             fwrite(ofp,tmp,fmt);            
% %         end
    end
fclose(ofp);    
end

if ischar(strFileDat),
    fclose(fid);
end;
% fclose(ofp);