function [info]=headread(pfilename,var_group)
% Usage info.s1.. [info]=headread(pfilename,level)
% var_group :   'full' or [ 1 1 1 1 1 1 1 1 1 1] - every structure
%               'default' or ommitted - [1 0 0 0 0 0 0 1 1 1]              
% each element of var_group corresponds to the following header
% sub-structures
%               1 - RDB_HEADER_REC
%               2 - RDB_PER_PASS_TAB
%               3 - RDB_PER_PASS_TAB
%               4 - REB_DATA_ACQ_TAB 
%               5 - RDB_NEX_TYPE
%               6 - RDB_NEX_TYPE
%               7 - TOOLSDATA
%               8 - EXAMDATATYPE
%               9 - SERIESDATATYPE
%               10- MRIMAGEDATATYPE
%
% for example, if we want to extract info from RDB_HEADER_REC and
% EXAMDATATYPE, use [info]=headread('Pxxxxx,7',[1 0 0 0 0 0 0 1 0 0]);

% structure of header:  (%% : implemented partly or fully)
%% RDB_HEADER_REC 2048 bytes        -- info.s1 (rhuser0~20, number of
%%                                      slices, rotation)
%  RDB_PER_PASS_TAB 4096 Bytes      -- info.s2
%  RDB_PER_PASS_TAB 4096 Bytes      -- info.s3
%  RDB_DATA_ACQ_TAB 20480 Bytes     -- info.s4
%  RDB_NEX_TYPE     2052 Bytes      -- info.s5
%  RDB_NEX_TYPE     2052 Bytes      -- info.s6
%  TOOLSDATA        2048 Bytes      -- info.s7
%% EXAMDATATYPE     1040 Bytes      -- info.s8
%% SERIESDATATYPE   1028 Bytes      -- info.s9
%% MRIMAGEDATATYPE  1044 Bytes      -- info.s10
%
% for E2, the RDB_DATA_ACQ_TAB has doubled to 40960
% SERIESDATATYPE and MRIMAGEDATATYPE are now 1536

% for details, please see page 3-4 ~ 3-12, 5-6 ~ 5-13 of EPIC manual
%  Sangwoo Lee, University of Michigan, Jul 1, 2003

HEADERSIZE=61464;
info.headersize = HEADERSIZE;
if exist('pfilename')&isstr(pfilename),
    fid=fopen(pfilename,'r','l');
    if (fid<3), disp(['Could not open file! ..']); end;
else
    fid=pfilename;
end;

if ~exist('var_group') | strcmp(var_group,'default') 
    var_group=[1 0 0 0 0 0 0 1 1 1];
elseif strcmp(var_group,'full')
    var_group=[1 1 1 1 1 1 1 1 1 1];
elseif min(var_group)<0 | max(var_group)>3 | length(var_group)~=10
    error('wrong argument type');help headread;
end;

%%%
%%%
%%% RDB_HEADER_REC 
%%%
if var_group(1) > 1
    info.s1.rdbm_rev=fread(fid,1,'float32');
    info.s1.run_int=fread(fid,1,'int32');
    info.s1.scan_seq=fread(fid,1,'int16');
    info.s1.run_char=fread(fid,6,'uint8=>char')';
    info.s1.scan_date=fread(fid,10,'uint8=>char')';
    scan_time=fread(fid,8,'uint8=>char')';
    info.s1.scan_time=scan_time;
    info.s1.logo=fread(fid,10,'uint8=>char')';     % 44 bytes

    info.s1.file_contents=fread(fid,1,'int16');
    info.s1.lock_mode=fread(fid,1,'int16');
    info.s1.dacq_ctrl=fread(fid,1,'int16');
    info.s1.recon_ctrl=fread(fid,1,'int16');
    info.s1.exec_ctrl=fread(fid,1,'int16');
    info.s1.scan_type=fread(fid,1,'int16');
    info.s1.data_collect_type=fread(fid,1,'int16');
    info.s1.data_format=fread(fid,1,'int16');
    info.s1.recon=fread(fid,1,'int16');
    info.s1.datacq=fread(fid,1,'int16');      %20 bytes

    info.s1.npasses=fread(fid,1,'int16');
    info.s1.npomp=fread(fid,1,'int16');
    info.s1.nslices=fread(fid,1,'int16');
    info.s1.nechoes=fread(fid,1,'int16');
    info.s1.navs=fread(fid,1,'int16');
    info.s1.nframes=fread(fid,1,'int16');
    info.s1.baseline_views=fread(fid,1,'int16');
    info.s1.hnover=fread(fid,1,'int16');
    info.s1.frame_size=fread(fid,1,'int16');
    info.s1.point_size=fread(fid,1,'int16');   % 20 bytes

    info.s1.hdr_vquant=fread(fid,1,'int16');

    info.s1.cheart=fread(fid,1,'int16');
    info.s1.ctr=fread(fid,1,'float32');
    info.s1.ctrr=fread(fid,1,'float32');

    info.s1.initpass=fread(fid,1,'int16');
    info.s1.incrpass=fread(fid,1,'int16');   % 16 bytes

    info.s1.method_ctrl=fread(fid,1,'int16');
    info.s1.da_xres=fread(fid,1,'int16');
    info.s1.da_yres=fread(fid,1,'int16');
    info.s1.rc_xres=fread(fid,1,'int16');
    info.s1.rc_yres=fread(fid,1,'int16');
    info.s1.im_size=fread(fid,1,'int16');
    info.s1.rc_zres=fread(fid,1,'int32');     %  16 bytes

    info.s1.raw_pass_size=fread(fid,1,'int32');
    info.s1.sspsave=fread(fid,1,'int32');
    info.s1.udasave=fread(fid,1,'int32');          %12 bytes
    info.s1.fermi_radius=fread(fid,1,'float32');
    info.s1.fermi_width=fread(fid,1,'float32');
    info.s1.fermi_ecc=fread(fid,1,'float32');
    info.s1.clip_min=fread(fid,1,'float32');
    info.s1.clip_max=fread(fid,1,'float32');
    info.s1.default_offset=fread(fid,1,'float32');
    info.s1.xoff=fread(fid,1,'float32');
    info.s1.yoff=fread(fid,1,'float32');
    info.s1.nwin=fread(fid,1,'float32');
    info.s1.ntran=fread(fid,1,'float32');
    info.s1.scalei=fread(fid,1,'float32');
    info.s1.scaleq=fread(fid,1,'float32');
    info.s1.rotation=fread(fid,1,'int16');
    info.s1.transpose=fread(fid,1,'int16');
    info.s1.kissoff_views=fread(fid,1,'int16');
    info.s1.slblank=fread(fid,1,'int16');
    info.s1.gradcoil=fread(fid,1,'int16');
    info.s1.ddaover=fread(fid,1,'int16');                      %60 bytes

    info.s1.sarr=fread(fid,1,'int16');
    info.s1.fd_tr=fread(fid,1,'int16');
    info.s1.fd_te=fread(fid,1,'int16');
    info.s1.fd_ctrl=fread(fid,1,'int16');
    info.s1.algor_num=fread(fid,1,'int16');
    info.s1.fd_df_dec=fread(fid,1,'int16');       % 12 bytes

    info.s1.dab=fread(fid,[8],'int16');
else
    fseek(fid,216,'cof');
end;

if var_group(1)> 0
    info.s1.user0=fread(fid,1,'float32');
    info.s1.user1=fread(fid,1,'float32');
    info.s1.user2=fread(fid,1,'float32');
    info.s1.user3=fread(fid,1,'float32');
    info.s1.user4=fread(fid,1,'float32');
    info.s1.user5=fread(fid,1,'float32');
    info.s1.user6=fread(fid,1,'float32');
    info.s1.user7=fread(fid,1,'float32');
    info.s1.user8=fread(fid,1,'float32');
    info.s1.user9=fread(fid,1,'float32');
    info.s1.user10=fread(fid,1,'float32');
    info.s1.user11=fread(fid,1,'float32');
    info.s1.user12=fread(fid,1,'float32');
    info.s1.user13=fread(fid,1,'float32');
    info.s1.user14=fread(fid,1,'float32');
    info.s1.user15=fread(fid,1,'float32');
    info.s1.user16=fread(fid,1,'float32');
    info.s1.user17=fread(fid,1,'float32');
    info.s1.user18=fread(fid,1,'float32');
    info.s1.user19=fread(fid,1,'float32');
else
    fseek(fid,80,'cof');
end;

if var_group(1)>2
    info.s1.v_type=fread(fid,1,'int32');
    info.s1.v_coefxa=fread(fid,1,'float32');
    info.s1.v_coefxb=fread(fid,1,'float32');
    info.s1.v_coefxc=fread(fid,1,'float32');
    info.s1.v_coefxd=fread(fid,1,'float32');
    info.s1.v_coefya=fread(fid,1,'float32');
    info.s1.v_coefyb=fread(fid,1,'float32');
    info.s1.v_coefyc=fread(fid,1,'float32');
    info.s1.v_coefyd=fread(fid,1,'float32');
    info.s1.v_coefza=fread(fid,1,'float32');
    info.s1.v_coefzb=fread(fid,1,'float32');
    info.s1.v_coefzc=fread(fid,1,'float32');
    info.s1.v_coefzd=fread(fid,1,'float32');
    info.s1.vm_coef1=fread(fid,1,'float32');
    info.s1.vm_coef2=fread(fid,1,'float32');
    info.s1.vm_coef3=fread(fid,1,'float32');
    info.s1.vm_coef4=fread(fid,1,'float32');
    info.s1.v_venc=fread(fid,1,'float32');

    info.s1.spectral_width=fread(fid,1,'float32');
    info.s1.csi_dims=fread(fid,1,'int16');
    info.s1.xcsi=fread(fid,1,'int16');
    info.s1.ycsi=fread(fid,1,'int16');
    info.s1.zcsi=fread(fid,1,'int16');
    info.s1.roilenx=fread(fid,1,'float32');
    info.s1.roileny=fread(fid,1,'float32');
    info.s1.roilenz=fread(fid,1,'float32');
    info.s1.roilocx=fread(fid,1,'float32');
    info.s1.roilocy=fread(fid,1,'float32');
    info.s1.roilocz=fread(fid,1,'float32');
    info.s1.vumdwell=fread(fid,1,'float32');

    info.s1.ps_command=fread(fid,1,'int32');
    info.s1.ps_mps_r1=fread(fid,1,'int32');
    info.s1.ps_mps_r2=fread(fid,1,'int32');
    info.s1.ps_mps_tg=fread(fid,1,'int32');
    info.s1.ps_mps_freq=fread(fid,1,'int32');
    info.s1.ps_aps_r1=fread(fid,1,'int32');
    info.s1.ps_aps_r2=fread(fid,1,'int32');
    info.s1.ps_aps_tg=fread(fid,1,'int32');
    info.s1.ps_aps_freq=fread(fid,1,'int32');
    info.s1.ps_scalei=fread(fid,1,'float32');
    info.s1.ps_scaleq=fread(fid,1,'float32');
    info.s1.ps_snr_warning=fread(fid,1,'int32');
    info.s1.ps_aps_or_mps=fread(fid,1,'int32');
    info.s1.ps_mps_bitmap=fread(fid,1,'int32');
    info.s1.ps_powerspec=fread(fid,256,'uint8=>char')';
    info.s1.ps_filler1=fread(fid,1,'int32');
    info.s1.ps_filler2=fread(fid,1,'int32');
    info.s1.rec_noise_mean=fread(fid,16,'float32');
    info.s1.rec_noise_std=fread(fid,16,'float32');

    info.s1.halfecho=fread(fid,1,'int16');
else
    fseek(fid,440,'cof');
end;

% new field 02-19-92
if var_group(1)>2
    info.s1.im_size_y=fread(fid,1,'int16');
    info.s1.data_collect_type1=fread(fid,1,'int32');
    info.s1.freq_scale=fread(fid,1,'float32');
    info.s1.phase_scale=fread(fid,1,'float32');

    info.s1.ovl=fread(fid,1,'int16');

    info.s1.pclin=fread(fid,1,'int16');
    info.s1.pclinnpts=fread(fid,1,'int16');
    info.s1.pclinorder=fread(fid,1,'int16');
    info.s1.pclinavg=fread(fid,1,'int16');
    info.s1.pccon=fread(fid,1,'int16');
    info.s1.pcconnpts=fread(fid,1,'int16');
    info.s1.pcconorder=fread(fid,1,'int16');
    info.s1.pcextcorr=fread(fid,1,'int16');
    info.s1.pcgraph=fread(fid,1,'int16');
    info.s1.pcileave=fread(fid,1,'int16');
    info.s1.hdbestky=fread(fid,1,'int16');
    info.s1.pcctrl=fread(fid,1,'int16');
    info.s1.pcthrespts=fread(fid,1,'int16');
    info.s1.pcdiscbeg=fread(fid,1,'int16');
    info.s1.pcdiscmid=fread(fid,1,'int16');
    info.s1.pcdiscend=fread(fid,1,'int16');
    info.s1.pcthrespct=fread(fid,1,'int16');
    info.s1.pcspacial=fread(fid,1,'int16');
    info.s1.pctempporal=fread(fid,1,'int16');
    info.s1.pcspare=fread(fid,1,'int16');
    info.s1.ileaves=fread(fid,1,'int16');
    info.s1.kydir=fread(fid,1,'int16');
    info.s1.alt=fread(fid,1,'int16');
    info.s1.reps=fread(fid,1,'int16');
    info.s1.ref=fread(fid,1,'int16');

    info.s1.pcconnorm=fread(fid,1,'float32');
    info.s1.pcconfitwt=fread(fid,1,'float32');
    info.s1.pclinnorm=fread(fid,1,'float32');
    info.s1.pclinfitwt=fread(fid,1,'float32');
    info.s1.pcbestky=fread(fid,1,'float32');

    info.s1.vrgf=fread(fid,1,'int32');
    info.s1.vrgfxres=fread(fid,1,'int32');

    info.s1.bp_corr=fread(fid,1,'int32');
    info.s1.recv_freq_s=fread(fid,1,'float32');
    info.s1.recv_freq_e=fread(fid,1,'float32');

    info.s1.hniter=fread(fid,1,'int32');

    info.s1.fast_rec=fread(fid,1,'int32');

    info.s1.refframes=fread(fid,1,'int32');
    info.s1.refframep=fread(fid,1,'int32');
    info.s1.scnframe=fread(fid,1,'int32');
    info.s1.pasframe=fread(fid,1,'int32');

    info.s1.user_usage_tag=fread(fid,1,'uint32');
    info.s1.user_fill_mapMSW=fread(fid,1,'uint32');
    info.s1.user_fill_mapLSW=fread(fid,1,'uint32');

    info.s1.user20=fread(fid,1,'float32');
    info.s1.user21=fread(fid,1,'float32');
    info.s1.user22=fread(fid,1,'float32');
    info.s1.user23=fread(fid,1,'float32');
    info.s1.user24=fread(fid,1,'float32');
    info.s1.user25=fread(fid,1,'float32');
    info.s1.user26=fread(fid,1,'float32');
    info.s1.user27=fread(fid,1,'float32');
    info.s1.user28=fread(fid,1,'float32');
    info.s1.user29=fread(fid,1,'float32');
    info.s1.user30=fread(fid,1,'float32');
    info.s1.user31=fread(fid,1,'float32');
    info.s1.user32=fread(fid,1,'float32');
    info.s1.user33=fread(fid,1,'float32');
    info.s1.user34=fread(fid,1,'float32');
    info.s1.user35=fread(fid,1,'float32');
    info.s1.user36=fread(fid,1,'float32');
    info.s1.user37=fread(fid,1,'float32');
    info.s1.user38=fread(fid,1,'float32');
    info.s1.user39=fread(fid,1,'float32');
    info.s1.user40=fread(fid,1,'float32');
    info.s1.user41=fread(fid,1,'float32');
    info.s1.user42=fread(fid,1,'float32');
    info.s1.user43=fread(fid,1,'float32');
    info.s1.user44=fread(fid,1,'float32');
    info.s1.user45=fread(fid,1,'float32');
    info.s1.user46=fread(fid,1,'float32');
    info.s1.user47=fread(fid,1,'float32');
    info.s1.user48=fread(fid,1,'float32');

    info.s1.pcfitorig=fread(fid,1,'int16');
    info.s1.pcshotfirst=fread(fid,1,'int16');
    info.s1.pcshotlast=fread(fid,1,'int16');
    info.s1.pcmultegrp=fread(fid,1,'int16');
    info.s1.pclinfix=fread(fid,1,'int16');

    info.s1.pcconfix=fread(fid,1,'int16');

    info.s1.pclinslope=fread(fid,1,'float32');
    info.s1.pcconslope=fread(fid,1,'float32');
    info.s1.pccoil=fread(fid,1,'int16');
    info.s1.excess=fread(fid,1,'int16');
end;

if var_group(2)~=0
    disp('s2:sorry not implemented yet!!');
end;
if var_group(3)~=0
    disp('s3:sorry not implemented yet!!');
end;
if var_group(4)~=0
    fseek(fid,10240,'bof');
    fseek(fid,4,'cof');
    info.s4.p1=fread(fid,3,'float32'); % corners of first image
    info.s4.p2=fread(fid,3,'float32'); % corners of first image
    info.s4.p3=fread(fid,3,'float32'); % corners of first image
    info.s4.p4=info.s4.p3+info.s4.p2-info.s4.p1; % missing corner
end;
if var_group(5)~=0
    disp('s5:sorry not implemented yet!!');
end;
if var_group(6)~=0
    disp('s6:sorry not implemented yet!!');
end;
if var_group(7)~=0
    disp('s7:sorry not implemented yet!!');
end;
if var_group(8)==1
    fseek(fid,36872+20480,'bof');
    fseek(fid,7,'cof');
    info.s8.ex_no=fread(fid,1,'int16');
    info.s8.hospname=fread(fid,33,'uint8=>char')';
    fseek(fid,36,'cof');
    info.s8.magstrength=fread(fid,1,'int32');
    info.s8.patid=fread(fid,13,'uint8=>char')';
    info.s8.patname=fread(fid,25,'uint8=>char')';
    fseek(fid,86,'cof');
    info.s8.ex_datetime=fread(fid,1,'int32');
end;
if var_group(9)~=0
    fseek(fid,36872+20480+1040,'bof');
    fseek(fid,7,'cof');
    info.s9.se_exno=fread(fid,1,'uint16');
    info.s9.se_no=fread(fid,1,'int16');
    fseek(fid,8,'cof');
    info.s9.se_desc=fread(fid,30,'uint8=>char')';
    info.s9.pr_sysid=fread(fid,9,'uint8=>char')';
    info.s9.pansysid=fread(fid,9,'uint8=>char')';    
    fseek(fid,16,'cof');
    info.s9.anref=fread(fid,3,'uint8=>char')';
    info.s9.imhor=fread(fid,1,'float32');
    info.s9.prtcl=fread(fid,25,'uint8=>char')';
end;
if var_group(10)~=0
    ptrloc1 = HEADERSIZE-1536;
    fseek(fid,ptrloc1+8,'bof');
    info.s10.im_exno=fread(fid,1,'uint16');
    info.s10.im_seno=fread(fid,1,'int16');
    info.s10.im_no=fread(fid,1,'int16');
    fseek(fid,ptrloc1+24,'bof');
    info.s10.sctime=fread(fid,1,'float32');
    info.s10.slthick=fread(fid,1,'float32');
%    info.s10.plane=fread(fid,1,'int16');
%    info.s10.scanspacing=fread(fid,1,'float32');
    fseek(fid,ptrloc1+168,'bof');
    info.s10.s_i_offset=fread(fid,1,'float32');
    fseek(fid,ptrloc1+200,'bof');
    info.s10.tr=fread(fid,1,'int32')/1000;
    fseek(fid,ptrloc1+208,'bof');
    info.s10.te=fread(fid,1,'int32')/1000;
    fseek(fid,ptrloc1+260,'bof');
    info.s10.fa=fread(fid,1,'int16');
    fseek(fid,ptrloc1+320,'bof');
    info.s10.psdname=fread(fid,33,'uint8=>char')';
    
end;

    
if isstr(pfilename),
  fclose(fid);
end;


