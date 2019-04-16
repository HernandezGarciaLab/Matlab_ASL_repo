function [kdata, uu,vv,images, scaninfo, A, W]=readin_recon_rex2(filename,dorecon,slice,timepts)
%[kdata, uu,vv,images, scaninfo, A, W]=readin_recon_rex2(filename,dorecon,slice,timepts)
% readin and recon program for two interleaved rosette
%  filename : any valid P-file name with correct path. If this is only
%             input, will return scaninfo only.
%  dorecon 0 : skip recon
%          1 : do recon    
%          2 : do fast recon (no field map correction possible)
%          3 : do iterative recon
%  slice : an 1d array that specifies which slice. a vector specifies slices to be
%          acquired.(e.g. [1, 3:5, 500]). Default is [1:nslice], if not specified. 
%  timepts : same as slice. Default is [1:maxtimepts]. Slice must be
%            specified for this to be specified.
% 
%  kdata : kspace data. (nslice by ntimepts by nl*framesize)
%  images : recon image. (xres by xres by nslice by ntimepts)
%  scaninfo : structure of [opte, opxres, rosgrad, zgradon, fov, maxnslice, doconcat, tsp, nl, maxntimepts,slice,timepts];
%             opte (us), fov (cm), tsp (us)
%  A : MRIP object
%  W : Weight for gridding recon
%%  Usage %%
%  [kdata, images, scaninfo, A, W]=readin_recon(filename)  -- returns scaninfo
%  [kdata, images, scaninfo, A, W]=readin_recon(filename,dorecon) --
%                        returns kdata and images for all slices and timepoints
%  [kdata, images, scaninfo, A, W]=readin_recon(filename,dorecon,[1:3],[3:40])
%                      -- returns kdata and images of the specifed slices and timepoints


%  jun 19, 2001 made npt 5800 to 5830 to maximally utilize data points
%               and dorecon is added to choose recon or not.
%  jul 11, 2001 changed to rere_int for two interleaved rosette
%               and retrieves frsize from P header
%  jul 26, 2001 rere_int_single  reads in three single slice data
%  feb 7, 2002  rere_int_singletwo : accept 180+alpha rotation for interleaves
%                      so uses ktraj5_int2W instead ktraj5_int
%               uses voronoi weight and k2image77 for gridding recon
%  jul 3, 2002 readin_recon : gets the number of slices from input argument
%                             kdata is now (nslice x npoints)
%  aug 26, 2002 readin_recon : got rid of nslice input argument. Instead, reads in from 
%                              the header of the file
%                              added scaninfo
%  sep 24, 2002 readin_recon : reads in bunch from header, recons multi slice, multi framed data. 
%  nov 8, 02     readin_recon : now take care of multiple timepoints and
%                               selective data acquisition
%  Jun 30,03     readin_recon_rslx : takes different header information for
%                                    rslx.e
%  mar 09, 04    readin_recon_rslx2 : new header size 60464
%                readin_recon_rslx3 : old header size 39984
%  jan 18, 05    readin_recon_rex2  : header size now 61464 and conversion to little
%                                     endian 
W=[];
% get header info
[info]=headread_rex2(filename,[2 0 0 0 0 0 0 1 1 1]);
fov=info.s1.user0;         % field of view in cm 
maxnslice=info.s1.nslices;      % number of slice
opxres=info.s1.user3;      % reconstruction resolution 
doconcat=info.s1.user11;   % if data exceeds 8192, do concatenated data acquisition up to 2
centf=info.s1.user12;      % receiver center frequency in kHz
tsp=info.s1.user13;        % sampling time in us
zgradon=mod(info.s1.user17,100);    % if SMART zgrad is on
opte=info.s1.user15;       % TE in us: beginning of acquisition from RF excitation
nl=info.s1.user4;          % number of interleaves
maxntimepts=info.s1.user1;
rosrf=info.s1.user18;      % rosrf
slthick=info.s1.user7;     % slice thickness in mm
 % trajectory parameters
n2=info.s1.user5;
ncyc=info.s1.user2;
krad=info.s1.user8;
nper=info.s1.user9;
nextra=info.s1.user16;
turn=info.s1.user19;

domap=info.s1.user14;
mapdel=info.s1.user15;
% construct scaninfo structure
scaninfo.opte = opte;
scaninfo.opxres = opxres;
scaninfo.zgradon = mod(zgradon,100);
scaninfo.selslnum = round(zgradon/100);
scaninfo.fov = fov;
scaninfo.maxnslice = maxnslice;
scaninfo.doconcat = doconcat;
scaninfo.tsp=tsp;
scaninfo.nl=nl;
scaninfo.maxntimepts=maxntimepts;
scaninfo.slthick=slthick;
scaninfo.rosrf=rosrf;
scaninfo.n2=n2;
scaninfo.ncyc=ncyc;
scaninfo.krad=krad;
scaninfo.nper=nper;
scaninfo.turn=turn;
scaninfo.domap=domap;
scaninfo.mapdel=mapdel;
switch nargin
    case 1
        kdata=[];images=[];slice=[];timepts=[];A=[];
        return;
    case 2, % select all slice and timepts
        slice=1:maxnslice;
        timepts=1:maxntimepts;
    case 4, % select slices and time points
        if max(timepts)>maxntimepts,error('exceed max time pts'),end;
        if max(slice)>maxnslice,error('exceed max slice num'),end;
    otherwise,
        error('invalid num of inputs')
end;
if scaninfo.domap==1 & timepts ==1 
    scaninfo.opte=scaninfo.opte+scaninfo.mapdel;
end;
scaninfo.slice=slice;
scaninfo.timepts=timepts;
frsize=info.s1.frame_size;                % get frame size
% generate kspace trajectory

uu=[];vv=[];
for ii=0:nl-1
    [k,k2,gg,param]=genrosett_rslx2(n2,ncyc/nl,krad,nper*4/tsp,0.44,180/ncyc*ii,turn,tsp/1e3);
    uu=[uu,real(k(1:frsize*(doconcat+1)))];
    vv=[vv,imag(k(1:frsize*(doconcat+1)))];
end;
if doconcat == 1
    uu=[];vv=[];
    delay=0; % delay in samples
%    disp(sprintf('delay= %d samples',delay));
    for ii=0:nl-1
        uu=[uu,real(k2(1:frsize)),real(k2(frsize+1+delay:2*frsize+delay))];
        vv=[vv,imag(k2(1:frsize)),imag(k2(frsize+1+delay:2*frsize+delay))]; 
    end;
end;
header=61464;                   % header size in bytes
npt=length(uu)/nl;              % number of data points per interleave
N=opxres;                       % recon resolution
dt=tsp/1000;                    % sampling rate in ms
ttemp=dt/1000*[0:npt-1];
tt=[];                          % generate time index for data demodulation at 50kHz
for ii=1:nl
    tt=[tt,ttemp];
end;

kdata=zeros(length(slice),length(timepts),nl*npt);


%disp('read in - readin_recon_rslx2');
fid=fopen(filename,'r','l');%k=fread(fid,[2,inf],'int16');kk=k(1,:)+i*k(2,:);
    for iii=1:length(slice)
        for iiii=1:length(timepts)
            for ii=1:nl
                tp=timepts(iiii);
                sl=slice(iii);
%                loc=header+4*frsize+4*frsize*(nl*maxntimepts+1+mod(nl,2))*(sl-1)+4*frsize*(tp-1)*nl+4*frsize*(ii-1);
                loc=header+4*frsize+4*frsize*(nl*maxntimepts+1+mod(nl+maxntimepts+1,2))*(sl-1)+4*frsize*(tp-1)*nl+4*frsize*(ii-1);
                fseek(fid,loc,'bof');
                ktemp1a=fread(fid,[2,frsize],'int16');
                s1a=ktemp1a(1,:)+i*ktemp1a(2,:);
%                if tsp == 5
%                    kdata(iii,iiii,1+(ii-1)*npt:ii*npt)=s1a(1:npt).*exp(-i*2*pi*centf*1000*ttemp).*exp(i*2*pi*info.s1.xoff/info.s1.user3*uu(1+(ii-1)*npt:ii*npt)).*exp(i*2*pi*info.s1.yoff/info.s1.user3*vv(1+(ii-1)*npt:ii*npt));

%                elseif tsp == 4
                    kdata(iii,iiii,1+(ii-1)*npt:ii*npt)=s1a(1:npt).*exp(i*2*pi*info.s1.xoff/info.s1.user3*uu(1+(ii-1)*npt:ii*npt)).*exp(i*2*pi*info.s1.yoff/info.s1.user3*vv(1+(ii-1)*npt:ii*npt));

%                end;
            end;
        end;
    end;
   
fclose(fid);
X=[];
Y=[];
for ii=1:N
   Y=[Y,N/2-1:-1:-N/2];
   X=[X,ones(1,N)*ii-N/2-1];
end;


A=mrip(uu.'/N,vv.'/N,tt.',zeros(N,N),X.',Y.',ones(N^2,1),fov,N,opte/1000000,nl);
%disp(sprintf('recon mode %d',dorecon));
% recon section
N=64;   % image size is 64x64
if dorecon == 2
    W=weight_vor(uu,vv);
end;
images=zeros(N,N,length(slice),length(timepts));
for iii=1:length(slice)
    for iiii=1:length(timepts)
        if dorecon == 1
            W=get_weight(uu,vv,4.5,4.5,0.5,0.5,'plain');
            W1=1./W;
            W1=W1/sum(W1)*pi*400;
            W=1./W1;
            mask=get_cir_mask(N,20);
            images(:,:,iii,iiii)=get_field_correction(kdata(iii,iiii,:),uu,vv,zeros(N,N),tt2,W);
        elseif dorecon == 2
            kapod=apod(A,sqz(kdata(iii,iiii,:)));
            images(:,:,iii,iiii)=k2image77(uu,vv,kapod,W,N);
        elseif dorecon == 3
            X=[];
            Y=[];
            for ii=1:N
                Y=[Y,N/2-1:-1:-N/2];
                X=[X,ones(1,N)*ii-N/2-1];
            end;
            As=mri(uu.'/64,vv.'/64,tt2.',zeros(N,N),X.',Y.',ones(N^2,1),20,N,0.0060);
            numit=10;m=2*npt;
            W=spdiag(ones(1,m));
            [sl,infos]=qpwls_pcg(As,W,kdata(iii,iiii,:).',0,zeros(4096,1),0,1,numit);
            images(:,:,iii,iiii)=reshape(sl(:,end),N,N);
        end;
    end;
end;
kdata=squeeze(kdata);
images=squeeze(images);













