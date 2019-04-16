function despiker_castdoubleall(pfilename,nTRs,npairs)
% Usage ... despiker_castdoubleall(pfilename,nTRs,npairs)
%
% looks for spikes in the kspace data and replaces them by the 
% average of neighboring timepoints in an adjacent TRs
%
%  Intended for use with data from cast_doubleall3.e where multiple
%  different TRs are stored in a single Pfile
%
% pfilename = 'PXXXXX.7'   etc
% nTRs = number of different TRs in the CASL experiment
% npairs = number of control/tag pairs at each TR
%
%  
RAWHEADERSIZE=61464;

% P file is organized as follows:
%  coil 1:
%  slice 1: baseline interleaves time1, interleaves time 2, etc...
%  slice 2: baseline interleaves time1, interleaves time 2, etc...
%  etc...
%  coil 2: same as above but some random skip between them
%  if #leaves and #points is odd then there is an extra baseline at end
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
% old P files :% RAWHEADERSIZE=40080;
HEADERSIZE=61464;
% odl Pfiles:  HEADERSIZE=40080;

RDBRAWHEADEROFFSET=30;  % For version 4 use 30.
LOC1 = RDBRAWHEADEROFFSET + 34;
LOC2 = RDBRAWHEADEROFFSET + 70;
LOC3 = RDBRAWHEADEROFFSET + 186;

if isstr(pfilename),
    fid=fopen(pfilename,'r','l');
    if (fid<3), disp(['Could not open file! ...']); end;
else
    fid=pfilename;
end;

hdr=fread(fid, HEADERSIZE, 'uchar');

status = fseek(fid,LOC1,'bof');
if (status), disp(['Could not seek to file location 1! ...']); end;
info1 = fread(fid,10,'short');

status = fseek(fid,LOC2,'bof');
if (status), disp(['Could not seek to file location 2! ...']); end;
info2 = fread(fid,6,'short');

status = fseek(fid,LOC3,'bof');
if (status), disp(['Could not seek to file location 3! ...']); end;
info3 = fread(fid,50,'float');


status=fseek(fid,RAWHEADERSIZE ,'bof');
if (status),error(['Could not seek to file fid location! ...']); end;
nslices = info1(3);
nechoes = info1(4);
nexcitations = info1(5);
nframes = info1(6);
framesize = info1(9);
psize = info1(10);    

if nargin<2, 
    nTRs=1; 
    nfidsperslice = nechoes * (nframes+1)-1;
else
    nfidsperslice=2*npairs;  %the number of FIDs at each TR in cast_doubleall
end


% data type here
if (psize==4), 
    fmt=['long']; 
else, 
    fmt=['short']; 
end;

indices=[];

% open the output file and stick the header and baseline in it
ofp=fopen(sprintf('f_%s', pfilename) ,'wb', 'ieee-le');
fwrite(ofp, hdr, 'uchar');

spike_counter=0;

% do one slice at a time
for sl=1:nslices
      baseline=fread(fid, 2*framesize, fmt);  %there is one baseline frame per slice
      fwrite(ofp, baseline, fmt);
  for TRindx=1:nTRs  
    % read the complex data in  
  
    raw = fread(fid, [2*framesize nfidsperslice], fmt);
    raw = raw';
    re_raw = raw(:, 1:2:2*framesize);
    im_raw = raw(:, 2:2:2*framesize);
    raw = complex(re_raw, im_raw);
    araw=abs(raw);
    mean_araw_mtx=((mean(araw,1).')*ones(1,2*npairs)).';   %Inefficient and waste of memory, but it works...
 %   std_araw_mtx=((std(araw).')*ones(1,2*npairs)).';
    %   diffmtx=abs(araw-mean_araw_mtx)./abs(std_araw_mtx);   %dividing by
    %   mean turned out to work better than using the std
    diffmtx=abs(araw-mean_araw_mtx)./abs(mean_araw_mtx);   %Inefficient and waste of memory, but it works...
    diff_thresh=3;  %Lowering this will result in a larger number of points being filtered.
    wp_locs=find(diffmtx>diff_thresh);  %used 4 for white pixel threshold.  
    spike_counter=spike_counter+length(wp_locs);
    out=raw;
    mean_raw_mtx=((mean(raw,1).')*ones(1,2*npairs)).';     %Inefficient and waste of memory, but it works...
    out(wp_locs)=mean_raw_mtx(wp_locs);
    
     plotdiff=0;  %set to 1 for debugging purposes
     if(length(wp_locs)>1)
         if(plotdiff==1)
         keyboard
            figure,plot(diffmtx.');
%            figure,plot(abs(raw.')-abs(out.'))
             hold on
             plot([0 framesize],[diff_thresh,diff_thresh],'k--')
         end
     end
    
    re_out = real(out);
    im_out = imag(out);
    
    % put the data in the right format for writing
    out2=zeros(nfidsperslice , framesize*2);
    for count=1:framesize
        out2(:,2*count-1) = re_out(:,count);
        out2(:,2*count) = im_out(:,count);
    end
       
    for ct=1:size(out2,1)
        fwrite(ofp, out2(ct,:), fmt);
    end
        
  end

end

if isstr(pfilename),
    fclose(fid);
end;
fclose(ofp);

sprintf('Number of Spikes Removed = %d points out of %d datapoints',spike_counter,framesize*npairs*2*nTRs)
