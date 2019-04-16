function f=byteswap(filename,type,info,rewrite)
% Usage ... f=byteswap(filename,type,info,rewrite)
%
% Writes a new file of filename with reversed bytes.
% This is useful in unix to pc conversions.
% type = either ( 'short', 'long', 'float', 'double' )
% info=[# elements to read; offset in bytes; write offset (0 or 1)]
% rewrite = 0 or 1 for no or yes.
 
if nargin<4,
  rewrite=0;
end;

fid=fopen(filename,'r');
if fid<3,
  error('Could not open file!');
end;

if length(info)<2,
  % assume no offset
  info(2)=0;
  info(3)=0;
end;
if length(info)<3,
  info(3)=0;
end;

if strcmp(type,'long'),
  size=4;
elseif strcmp(type,'float'),
  size=4;
elseif strcmp(type,'double'),
  size=8;
else,
  % assume short in any case
  size=2;
end;

if info(3),
  [header,cnt]=fread(fid,info(2),'uint8');
  if cnt~=info(2),
    fclose(fid);
    error('Could not read offset!');
  end;
  status=fseek(fid,info(2),'bof');
  if status~=0,
    fclose(fid);
    error('Could not seek to location!');
  end;
else,
  status=fseek(fid,info(2),'bof');
  if status~=0,
    fclose(fid);
    error('Could not seek to location!');
  end;
end;
if info(1)==0,
  [data,cnt]=fread(fid,inf,'uint8');
else,
  [data,cnt]=fread(fid,info(1)*size,'uint8');
  if cnt~=info(1)*size,
    fclose(fid);
    error('Could not read that number of elements from file!');
  end;
end;
fclose(fid);

%newdata=zeros(size(data));
if size==2,
  for m=1:info(1),
    newdata(2*m-1)=data(2*m);
    newdata(2*m)=data(2*m-1);
  end;
elseif size==4,
  for m=1:info(1),
    newdata(4*m-3)=data(4*m);
    newdata(4*m-2)=data(4*m-1);
    newdata(4*m-1)=data(4*m-2);
    newdata(4*m)=data(4*m-3);
  end;
elseif size==8,
  for m=1:info(1),
    newdata(8*m)=data(8*m-7);
    newdata(8*m-1)=data(8*m-6);
    newdata(8*m-2)=data(8*m-5);
    newdata(8*m-3)=data(8*m-4);
    newdata(8*m-4)=data(8*m-3);
    newdata(8*m-5)=data(8*m-2);
    newdata(8*m-6)=data(8*m-1);
    newdata(8*m-7)=data(8*m);
  end;
end;

if rewrite,
  newfile=filename;
  tmpcmd=['! del ',filename];
  eval(tmpcmd);
else,
  %newfile=[filename,'.rev'];
  newfile=['tmp.rev'];
end;

fidn=fopen(newfile,'w');
if fidn<3,
  error('Could not open new file to write!');
end;
if info(3),
  cnt=fwrite(fidn,header,'uint8');
  if cnt~=info(2),
    fclose(fidn);
    error('Could not write offset to new file!');
  end;
  status=fseek(fidn,info(2),'bof');
  if status~=0,
    fclose(fid);
    error('Could not seek to new file location!');
  end;
end;
cnt=fwrite(fidn,newdata,'uint8');
if cnt~=info(1)*size,
  fclose(fidn);
  error('Could not write all bytes to new file!');
end;
fclose(fidn);
