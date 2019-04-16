function [raw, header, ec] = read_MR_rawdata(in_name, save_baseline, phaselist, echolist, slicelist, rcvrlist)
%read_MR_rawdata - Read MR rawdata files (P-files)
%
% The tool suppports rawdata files with multiple temporal phases, echos,
% slices, and receivers.
%
%   [A, HEADER] = read_MR_rawdata(FILENAME);    returns the 
%   MR rawdata in FILENAME into A, and returns the headers 
%   into HEADER. Array A may be up to 6-D, with dimensions of 
%   (ky, kx, phase, echo, slice, rcvr).
%
%   A = read_MR_rawdata(FILENAME);    returns the rawdata into A;
%   since the headers are not returned, execution is much faster.
%
%   A = read_MR_rawdata(FILENAME, BASELINE_FLAG, PHASE, ECHO, SLICE, RCVR);
%   returns the rawdata into A, using the chosen echo, slice and rcvr.
%   PHASE, ECHO, SLICE, and RCVR can be a single value or a range of values.
%   The BASELINE_FLAG must be either 'sb' for "save baseline" or 'db' for
%   "discard baseline".
%
% If the rawfile contains only one image worth of rawdata, or if only one
% phase, echo, slice, and receiver is requested, the returned matrix A will be 2-D.
% The index order of the returned matrix will be:
% [YRES XRES PHASES ECHOES SLICES RECEIVERS]
%

% Copyright (c) 2012 by General Electric Company. All rights reserved.

% Modification History
% Rev 2.3  2003-MAY-29  Matthew Eash. "Initial version"
% Rev 2.4  2003-DEC-17  Steve Huff. "Added Multi Temporal Phase Capablity."
% Rev 2.5  2004-FEB-25  Steve Huff. "Numerous updates for specifying ranges."
% Rev 2.6  2004-MAR=01  Steve Huff. "Added non-standard P file reading and
%                                    spead up stripping of extra views for fMRI".
%-------------------------------------------------------------------------
  showstatus = 0;
  ec=0;
  non_standard_pfile=0;
  % Determine if the input parameter IN_NAME points to a directory of a file
  fprintf('\nREAD_MR_RAWDATA:\n')
  switch exist(in_name)
    case 7        % it's a DIRECTORY -- open gui to get filename
      [ filename, dirname ] = uigetfile( fullfile(in_name, '*.7'), 'Select a P-file to open' );  
      if isequal(filename,0)|isequal(dirname,0)
        errordlg('No file selected. No data returned.','ERROR!','modal');
        raw = [];
        ec=1;
        return;
      end
    case 2        % it's a FILE 
      [ dirname, filename, fileext] = fileparts(in_name);
      filename = [filename fileext];
      [rows num_char]=size(filename);
      P_check=strmatch('P',filename);
      ext_check=strmatch('.7',fileext,'exact');
      if(num_char ~= 8 | P_check ~= 1 | ext_check ~= 1)
          non_standard_pfile=1;
      end
    otherwise
      errordlg('Parameter is not a file or directory. No data returned.','ERROR!','modal');
      raw = [];
      ec=1;
      return;
  end
  
  fullfilename = fullfile( dirname, filename);
  
  % If headers will be returned, read ALL the headers.  If headers will not
  % be returned, read only the headers needed for reading the rawdata
%   switch nargout
%     case 2   
      header = read_MR_headers( fullfilename, 'all' );
%     case 1
%       header = read_MR_headers( fullfilename, 'qraw' );
%   end

  % Get endian from header structure
  endianID = header.endian;  
  % Pull useful info from rdb_hdr
  nfphases   = header.image.fphase;
  psdname    = deblank(header.image.psd_iname);
  npasses    = header.rdb_hdr.npasses;
  da_xres    = header.rdb_hdr.da_xres;
  da_yres    = header.rdb_hdr.da_yres;
  nslices    = header.rdb_hdr.nslices;
  nechoes    = header.rdb_hdr.nechoes;
  point_size = header.rdb_hdr.point_size;
  receivers = (header.rdb_hdr.dab(2)-header.rdb_hdr.dab(1))+1;
  nslices_per_pass = header.rdb_hdr.raw_pass_size / (receivers * nechoes * da_yres * da_xres * point_size * 2);

  switch point_size
    case 2
      raw_data_type = 'int16';       % 16 bit data
    case 4
      raw_data_type = 'int32';       % 32 bit (EDR)
  end  
  
 fprintf('nfphases = %d psdname = %s npasses = %d da_xres = %d da_yres = %d nslices = %d nechoes = %d point_size = %d receivers= %d nslices_per_pass = %d\n', nfphases, psdname, npasses, da_xres, da_yres, nslices, nechoes, point_size, receivers, nslices_per_pass);

  is_grafimage_psd = 0;
% if (strcmp(psdname, 'GRAFIMAGE') || strcmp(psdname, '2DFAST')) % grafimage psd used to have name 2dfast
  if (strcmp(psdname, 'GRAFIMAGE'))
      is_grafimage_psd = 1;
  end

  if (non_standard_pfile == 1 & npasses ~= 1 & is_grafimage_psd == 0)
      errordlg('A non-standard P file name must contain only 1 pass.','ERROR!','modal');
      raw = [];
      ec=2;
      return;
  end
  
  if(nfphases == 0)
      nphases = 1;
  else
      nphases = nfphases;
  end
  
  % Unless passed at least 6 input parameters, read ALL the data in the rawfile
  if (nargin == 1)
    phaselist = 1:nphases;
    echolist  = 1:nechoes;
    slicelist = 1:nslices;
    rcvrlist  = 1:receivers;
    save_baseline = 'db';
  elseif (nargin == 2)
    phaselist = 1:nphases;
    echolist  = 1:nechoes;
    slicelist = 1:nslices;
    rcvrlist  = 1:receivers;
  elseif (nargin ~= 6)
    errordlg('You must call read_MR_radata with either 1 or 6 arguments.','ERROR!','modal');
    raw = [];
    ec=2;
    return;
  end
    
    % Compute (byte) size of frames, echoes and slices
    elements  = da_xres*2;
    frame_sz  = 2 * da_xres * point_size;     % Size of one frame of rawdata (one Kx line)
    echo_sz   = frame_sz * da_yres;           % Size of one image (one Kx * Ky matrix)
    slice_sz  = echo_sz  * nechoes;           % Size of nechoes images (one raw matrix * number of echoes)
    mslice_sz = slice_sz * receivers;	      % (one slice * number of receivers)
    
    fprintf('length slicelist = %d nphases = %d nslices_per_pass = %d npasses = %d \n', length(slicelist), nphases, nslices_per_pass, npasses);
    % Determine which of the 3 types of temporal phase raw data it is
    temporal_type='na';
    if(nphases > 1)                         % It's a multi temporal phase scan
        if (nslices_per_pass == nphases)    % It's a "Sequential Multi-Phase acq. Each raw file contains 1 slice all phases.
            temporal_type='seq';
            if(nargin == 1)
                slicelist=1:npasses;
            end
        elseif (npasses == nphases)         % It's an "Interleaved Multi-Phase acq. Each raw file contains all slices at one temporal phase.
            temporal_type='int';
            if(nargin == 1)
                slicelist=1:nslices_per_pass;
            end
        elseif strcmp(psdname,'EPI')      % It's a fMRI scan. Only one raw file.
            temporal_type='fMRI';
        end
        
        if(nechoes > 1)
            errordlg('read_MR_rawdata will not support multi-echo multi-phase data.','ERROR!','modal');
            raw=[];
            ec=3;
            return;
        end
    end

    if (is_grafimage_psd == 1)
        temporal_type = 'grafimage';
    end

    fprintf('length slicelist = %d nphases = %d nslices_per_pass = %d npasses = %d temporal_type = %s\n', length(slicelist), nphases, nslices_per_pass, npasses, temporal_type);

        
    % Compute offset in bytes to start of raw_data, and the act_yres to use.
    if(strcmp(save_baseline,'sb'))
        baseline_offset=0;
        act_yres=da_yres;
    elseif(strcmp(save_baseline,'db'))
        baseline_offset   = da_xres * 2 * point_size;
        act_yres=da_yres-1;
    else
        errordlg('You must specify sb or db for baseline argument.','ERROR!','modal');
        raw=[];
        ec=4;
        return;
    end
    
    data_elements = 2 * da_xres * act_yres;
    if(nphases > 1)
        if strcmp(temporal_type,'seq')
            total_bytes = header.total_length + echo_sz * nphases * receivers;
            raw_file_skip=nphases;
        elseif strcmp(temporal_type,'int')
            total_bytes = header.total_length + echo_sz * nslices_per_pass * receivers;
            raw_file_skip=nslices_per_pass;
        elseif strcmp(temporal_type,'fMRI')
            total_bytes = header.total_length + echo_sz * nphases * nslices_per_pass * receivers;
            raw_file_skip=1;
        else
            errordlg('The raw data set is multiphase but is not a recognized temporal type.','ERROR!','modal');
            raw=[];
            ec=5;
            return;
        end
    else
        total_bytes = header.total_length + nslices_per_pass * mslice_sz;
        raw_file_skip=1;
    end

    if (strcmp(temporal_type, 'grafimage'))
        total_bytes = header.total_length + npasses * nslices_per_pass * mslice_sz;
        fprintf('total_length = %d npasses = %d nslices_per_pass = %d mslice_sz = %d\n', header.total_length, npasses, nslices_per_pass, mslice_sz);
        npasses = 1;  % all P files are concatenated into one in grafimage data
        raw_file_skip=1;
    end

    % Check for complete raw data set: all files present and of the expected length
    fprintf('\nRawfile Dataset information:\n');
    fprintf('  File format:            %10s\n', header.format );    
    fprintf('  Endian ID:              %10s\n', header.endian );    
    fprintf('  Header size, bytes:     %10d\n', header.total_length );    
    fprintf('  Slice size, bytes:      %10d\n', mslice_sz );
    fprintf('  Number of Time Phases:  %10d\n', nphases);
    fprintf('  Expected Pfile, bytes:  %10d\n', total_bytes );
    fprintf('Check rawfiles Status:\n');
    file_inc=raw_file_skip;
    for filei = 1:npasses
      filename = sprintf('P%05d.7', header.rdb_hdr.run_int+file_inc-raw_file_skip);
      file_inc=file_inc+raw_file_skip;
      fidi = fopen( fullfile( dirname, filename), 'r', endianID );
      if fidi < 3
        status_str = 'Could not be opened\n';
      else
        fseek( fidi, 0, 'eof' );
        filesize = ftell( fidi );
        fclose( fidi );
        if filesize~=total_bytes
          status_str = sprintf('Wrong rawfile size: %d bytes (actual) \n', filesize);
        else
          status_str = 'OK';
        end
      end
      fprintf( '  Pass %2d rawfile:%12s   %s\n', filei, filename, status_str);
    end
    
if strcmp(temporal_type,'na')     
    fprintf('  Echo Slice Rcvr Pass Filename     Offset   Status\n');
    fprintf('  -------------------------------------------------\n');
    raw = zeros( act_yres, da_xres, max(phaselist),max(echolist), max(slicelist), max(rcvrlist) );
    for echonum = min(echolist):max(echolist)
      echo = echolist(echonum - min(echolist) + 1);
      echo_offset = echo_sz * (echo-1);
      for slicenum = min(slicelist):max(slicelist)
        slice_requested = slicelist(slicenum - min(slicelist) + 1);
        pass  = header.data_acq_tab.pass_number(slice_requested);
        slice_offset = slice_sz * (header.data_acq_tab.slice_in_pass(slice_requested)-1);
        for rcvrnum = min(rcvrlist):max(rcvrlist)
          rcvr = rcvrlist(rcvrnum - min(rcvrlist) + 1);
          receiver_offset  = nslices_per_pass * slice_sz * (rcvr-1);

          % fprintf('%10d %10d %10d %10d %10d\n', header.total_length, receiver_offset, slice_offset, echo_offset, baseline_offset);
          file_offset       = header.total_length + receiver_offset + slice_offset + echo_offset + baseline_offset;
          if(non_standard_pfile == 0)
            filename = sprintf('P%05d.7', header.rdb_hdr.run_int+header.data_acq_tab.pass_number(slice_requested));
            fid = fopen( fullfile( dirname, filename), 'r', endianID);
          else
            fid = fopen( fullfilename, 'r', endianID);
          end
          if fid<3
            status_str = 'File not found';
          else
            status = fseek(fid, file_offset, 'bof');
            if status==-1
              status_str = 'Offset outside of file';
            else
              [raw_data, count] = fread( fid, 2 * da_xres * act_yres, raw_data_type);
              if count~=(2*da_xres*act_yres)
                status_str = 'Could not read sufficient data';
              else
                status_str = 'OK';
                raw_data = complex( raw_data(1:2:count), raw_data(2:2:count) );
                raw_data = reshape( raw_data, da_xres, act_yres );
                raw(:,:,1,echonum, slicenum, rcvrnum) = transpose( raw_data ); 
              end
            end
            fclose(fid);
          end
%           fprintf(' %4d %4d %4d %4d %10s %10d   %s\n', ...
%             echo, slice_requested, rcvr, pass, filename, file_offset, status_str); 
        end
      end
    end
    
elseif strcmp(temporal_type,'grafimage')
    if (showstatus == 1)
        fprintf('  Echo Slice Rcvr Pass Filename     Offset   Status\n');
        fprintf('  -------------------------------------------------\n');
    end
    fprintf('act_yres = %d da_xres = %d phaselist = %d echolist = %d slicelist = %d rcvrlist = %d\n', act_yres, da_xres, length(phaselist),length(echolist), length(slicelist), length(rcvrlist) );

    raw = zeros( act_yres, da_xres, length(phaselist),length(echolist), length(slicelist), length(rcvrlist) );
    for echonum = 1:length(echolist)
        echo = echolist(echonum);
        echo_offset = echo_sz * (echo-1);
        for slicenum = 1:length(slicelist)
            slice_requested = slicelist(slicenum);
            pass = 0;
            slice_offset = slice_sz * (header.data_acq_tab.slice_in_pass(slice_requested)-1+floor((slice_requested-1)/nslices_per_pass)*nslices_per_pass);

            for rcvrnum = 1:length(rcvrlist)
                rcvr = rcvrlist(rcvrnum);
                receiver_offset = nslices_per_pass * slice_sz * (rcvr-1);
                file_offset = header.total_length + receiver_offset + slice_offset + echo_offset + baseline_offset;
                if(non_standard_pfile == 0)
                    filename = sprintf('P%05d.7', header.rdb_hdr.run_int);
                    fid = fopen( fullfile(dirname, filename), 'r', endianID);
                else
                    fid = fopen( fullfilename, 'r', endianID);
                end
                if fid < 3
                    status_str = 'File not found';
                else
                    status = fseek(fid, file_offset, 'bof');
                    if status==-1
                        status_str = 'Offset outside of file';
                    else
                        [raw_data, count] = fread(fid, 2 * da_xres * act_yres, raw_data_type);
                        if count~=(2*da_xres*act_yres)
                            status_str = 'Could not read sufficient data';
                        else
                            status_str = 'OK';
                            raw_data = complex( raw_data(1:2:count), raw_data(2:2:count) );
                            raw_data = reshape( raw_data, da_xres, act_yres );
                            raw(:,:,1,echonum, slicenum, rcvrnum) = transpose( raw_data );
                        end
                    end
                    fclose(fid);
                end
                if (showstatus == 1)
                    fprintf(' %4d %4d %4d %4d %10s %10.0f   %s\n', ...
                        echo, slice_requested, rcvr, pass+1, filename, file_offset, status_str);
                end
            end
        end
    end

elseif strcmp(temporal_type,'seq')
    fprintf('  Slice Phase Rcvr Filename     Offset   Status\n');
    fprintf('  -----------------------------------------------------------\n');
    raw = zeros( act_yres, da_xres, max(phaselist), max(echolist), max(slicelist), max(rcvrlist) );
    rcvr=min(rcvrlist);
    for slicenum = min(slicelist):max(slicelist)
        slice_requested = slicelist(slicenum - min(slicelist) + 1);
        for phasenum = min(phaselist):max(phaselist)
            phase_requested = phaselist(phasenum - min(phaselist) + 1);
            phase_offset = echo_sz * rcvr * (phasenum -1);
            for rcvrnum = min(rcvrlist):max(rcvrlist)
                rcvr = rcvrlist(rcvrnum - min(rcvrlist) + 1);
                receiver_offset = echo_sz * (rcvr-1);
                filename = sprintf('P%05d.7', header.rdb_hdr.run_int + ((slicenum-1) * nslices_per_pass));
                %filename = sprintf('P%05d.7', header.rdb_hdr.run_int+header.data_acq_tab.pass_number(slice_requested));
                file_offset = header.total_length + phase_offset + receiver_offset + baseline_offset;
                fid = fopen( fullfile( dirname, filename), 'r', endianID);
                if fid<3
                    status_str = 'File not found';
                else
                    status = fseek(fid, file_offset, 'bof');
                    if status==-1
                        status_str = 'Offset outside of file';
                    else
                        [raw_data, count] = fread( fid, 2 * da_xres * act_yres, raw_data_type);
                        if count~=(2*da_xres*act_yres)
                            status_str = 'Could not read sufficient data';
                        else
                            status_str = 'OK';
                            raw_data = complex( raw_data(1:2:count), raw_data(2:2:count) );
                            raw_data = reshape( raw_data, da_xres, act_yres );
                            raw(:,:,phasenum,1,slicenum,rcvrnum) = transpose( raw_data ); 
                        end
                    end
                end
            fprintf(' %4d %4d %4d %10s %10d   %s\n', ...
            slice_requested, phase_requested, rcvr, filename, file_offset, status_str); 
            end
                fclose(fid);
        end
    end
    
elseif strcmp(temporal_type,'int')
    fprintf('  Slice Phase Rcvr Filename     Offset   Status\n');
    fprintf('  -----------------------------------------------------------\n');
    raw = zeros( act_yres, da_xres, max(phaselist), max(echolist), max(slicelist), max(rcvrlist) );
    for phasenum = min(phaselist):max(phaselist)
        phase_requested = phaselist(phasenum - min(phaselist) + 1);
        for rcvrnum = min(rcvrlist):max(rcvrlist)
            rcvr = rcvrlist(rcvrnum - min(rcvrlist) + 1);
            receiver_offset = echo_sz * (rcvr-1) * nslices_per_pass;
            for slicenum = min(slicelist):max(slicelist)
                slice_requested = slicelist(slicenum - min(slicelist) + 1);
                slice_offset = echo_sz * (header.data_acq_tab.slice_in_pass(slice_requested)-1);
                %filename = sprintf('P%05d.7', header.rdb_hdr.run_int + (nslices_per_pass * (phasenum-1)));
                filename = sprintf('P%05d.7', header.rdb_hdr.run_int+header.data_acq_tab.pass_number(slice_requested));
                file_offset = header.total_length + slice_offset + receiver_offset + baseline_offset;
                fid = fopen( fullfile( dirname, filename), 'r', endianID);
                if fid<3
                    status_str = 'File not found';
                else
                    status = fseek(fid, file_offset, 'bof');
                    if status==-1
                        status_str = 'Offset outside of file';
                    else
                        [raw_data, count] = fread( fid, 2 * da_xres * act_yres, raw_data_type);
                        if count~=(2*da_xres*act_yres)
                            status_str = 'Could not read sufficient data';
                        else
                            status_str = 'OK';
                            raw_data = complex( raw_data(1:2:count), raw_data(2:2:count) );
                            raw_data = reshape( raw_data, da_xres, act_yres );
                            raw(:,:,phasenum,1,slicenum,rcvrnum) = transpose( raw_data ); 
                        end
                    end
                end
            fprintf(' %4d %4d %4d %10s %10d   %s\n', ...
            slice_requested, phase_requested, rcvr, filename, file_offset, status_str); 
            end
                fclose(fid);
        end
    end
        
elseif strcmp(temporal_type,'fMRI')
    fprintf('  Slice Phase Rcvr Filename     Offset   Status\n');
    fprintf('  -----------------------------------------------------------\n');
    raw = zeros( act_yres, da_xres, max(phaselist), max(echolist), max(slicelist), max(rcvrlist) );
    for phasenum = min(phaselist):max(phaselist)
        phase_requested = phaselist(phasenum - min(phaselist) + 1);
        phase_offset = (phase_requested - 1) * nslices * max(rcvrlist) * echo_sz;
        for rcvrnum = min(rcvrlist):max(rcvrlist)
            rcvr = rcvrlist(rcvrnum - min(rcvrlist) + 1);
            receiver_offset = echo_sz * (rcvr-1) * nslices_per_pass;
            for slicenum = min(slicelist):max(slicelist)
                slice_requested = slicelist(slicenum - min(slicelist) + 1);
                slice_offset = echo_sz * (header.data_acq_tab.slice_in_pass(slice_requested) - 1);
                filename = sprintf('P%05d.7', header.rdb_hdr.run_int);
                file_offset = header.total_length + phase_offset + slice_offset + receiver_offset + baseline_offset;
                fid = fopen( fullfile( dirname, filename), 'r', endianID);
                if fid<3
                    status_str = 'File not found';
                else
                    status = fseek(fid, file_offset, 'bof');
                    if status==-1
                        status_str = 'Offset outside of file';
                    else
                        [raw_data, count] = fread( fid, 2 * da_xres * act_yres, raw_data_type);
                        if count~=(2*da_xres*act_yres)
                            status_str = 'Could not read sufficient data';
                        else
                            status_str = 'OK';
                            raw_data = complex( raw_data(1:2:count), raw_data(2:2:count) );
                            raw_data = reshape( raw_data, da_xres, act_yres );
                            raw(:,:,phasenum,1,slicenum,rcvrnum) = transpose( raw_data ); 
                        end
                    end
                end
            fprintf(' %4d %4d %4d %10s %10d   %s\n', ...
            slice_requested, phase_requested, rcvr, filename, file_offset, status_str); 
            end
                fclose(fid);
        end
    end
    
    if(header.rdb_hdr.ref == 3) %New fMRI with extra ref views per raw data set
        if strcmp(save_baseline,'db')
            if(header.rdb_hdr.extra_frames_top ~= 0)
                last_extra_view=header.rdb_hdr.extra_frames_top;
                raw(1:last_extra_view,:,:,:,:,:)=[];
            elseif(header.rdb_hdr.extra_frames_bot ~= 0)
                last_extra_view=act_yres-header.rdb_hdr.extra_frames_bot+1;
                raw(last_extra_view:act_yres,:,:,:,:,:)=[];
            end
        end
    end
end
return
