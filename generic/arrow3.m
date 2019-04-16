function H=arrow3(p1,p2,s,w,h,ip)
% ARROW3
%   ARROW3(P1,P2) will draw vector lines (2D/3D) from P1 to P2 with
%   arrowheads, where P1 and P2 can be either nx2 matrices (for 2D),
%   or nx3 matrices (for 3D).
%
%   ARROW3(P1,P2,S,W,H,IP) can be used to specify properties of the
%   line and arrowhead; W=width of arrowhead, H=height of arrowhead.
%   If a value is provided for IP, an initial point marker will be
%   plotted with width IP; use IP = 0 for default width.  S is a
%   character string made from one each of the following 3 columns.
%   Invalid character will be ignored and replaced by default setting.
%
%       Color Switches:         Line Type:              Line Weight:
%       ------------------------------------------------------------
%       k   black (default)     -   solid (default)     0.5 (default)
%       y   yellow              :   dotted
%       m   magenta             -.  dashdot
%       c   cyan                --  dashed
%       r   red                 
%       g   green
%       b   blue
%       w   white
%       x   random color!
%
%   If a particular aspect ratio is required, use DASPECT or PBASPECT
%   before calling ARROW3.  Changing DASPECT or PBASPECT after calling
%   ARROW3 may change the appearance of arrowheads and initial point
%   markers.
%
%   Usage Examples:
%
%       % 2D vectors
%       Arrow3([0 0],[1 3])
%       Arrow3([0 0],[1 2],'-.b')
%       Arrow3([0 0],[10 10],'--x2',1)
%       Arrow3(zeros(10,2),50*rand(10,2),'x',1,3)
%       Arrow3(zeros(10,2),[10*rand(10,1),500*rand(10,1)],'r')
%       Arrow3(10*rand(10,2),50*rand(10,2),'x',1,[],1)
%
%       % 3D vectors
%       Arrow3([0 0 0],[1 1 1])
%       Arrow3(zeros(20,3),50*rand(20,3),'--x1.5',2)
%       Arrow3(zeros(100,3),50*rand(100,3),'x',1,3)
%       Arrow3(zeros(10,3),[10*rand(10,1),500*rand(10,1),50*rand(10,1)],'b')
%       Arrow3(10*rand(10,3),50*rand(10,3),'x',[],[],0)
%
%       % Just for fun
%       Arrow3(zeros(100,3),50*rand(100,3),'x',10,3);
%       light('Position',[-10 -10 -10],'Style','local');
%       light('Position',[60,60,60]), lighting gouraud; alpha(.95)
%
%   Copyright(c)2002, Version 3.00
%       Jeff Chang <pchang@mtu.edu>
%       Tom Davis  <tdavis@eng.usf.edu>

%   Revision History:
%
%       04/27/02   - Minor log plot revisions (TD)
%       03/26/02   - Added log plot support (TD)
%       03/24/02   - Adaptive grid spacing control to trade-off appearance
%                    Vs speed based on size of matrix (JC)
%       03/16/02   - Added "axis tight" for improved appearance (JC)
%       03/12/02   - Added initial point marker (TD)
%       03/03/02   - Added aspect ratio support (TD)
%       03/02/02   - Enchance program's user friendliness (JC)
%                    (Lump Color, LineType & LineWeight together)
%       03/01/02   - Replaced call to ROTATE (TD)
%       02/28/02   - Modified "Plot line",
%                    added lineweight and linetype (TD)
%       02/27/02   - Minor enhancements on 3D appearance (JC)
%       02/26/02   - Minor enhancements for speed (TD&JC)
%       02/26/02   - Optimise PLOT3 and SURF for speed (TD)
%       02/25/02   - Return handler, error handling, color effect,
%                    generalize for 2D/3D vectors (JC)
%       02/24/02   - Optimise PLOT3 and SURF for speed (TD)
%       02/23/02   - First release (JC&TD)
%

%===============================================================
% Error Checking
if ishold, restore=1; else restore=0; end
if nargin<2
    error([upper(mfilename),' requires at least two input arguments'])
end
[r1,c1]=size(p1); [r2,c2]=size(p2);
if r1~=r2, error('P1 and P2 must have same number of rows'), end
if c1~=c2, error('P1 and P2 must have same number of columns'), end
if c1==1 | (nargin>5 & length(ip)>1)
    error(['Invalid input, type HELP ',upper(mfilename),' for usage examples'])
end
if c1==2, p1=[p1,zeros(r1,1)]; p2=[p2,zeros(r1,1)]; end
if ~restore, clf, hold on, xys=0; end, view(c1), F=gca;
if restore
    xs=strcmp(get(F,'xscale'),'log');
    ys=strcmp(get(F,'yscale'),'log');
    zs=strcmp(get(F,'zscale'),'log');
    if zs, error('Z log scale not supported'), end
    xys=xs+ys;
    if xys & c1==3, error('3D log plot not supported'), end
end

%===============================================================
% Style Control
vc=['ymcrgbkwx'];                           % valid color code
n=r1;
if nargin<3, [c,lt,lw]=LocalValidateCLTW;   % default Color, LineType/Weight
else, 
    [c,lt,lw]=LocalValidateCLTW(s);
    if c=='x', c=vc(mod(randperm(n),7)+1);  % random color (less white)
    elseif ~sum(vc==c),
        warning('Invalid color switch, default color (black) will be used');
        c='k';
    end
end

%===============================================================
% Log Plot
if xys
    axis auto
    set(F,'units','points')
    pos=get(F,'position');
    set(F,'units','normalized')
    xr=get(F,'xlim'); yr=get(F,'ylim');
    if strcmp(get(F,'PlotBoxAspectRatioMode'),'auto')
        set(F,'PlotBoxAspectRatio',[pos(3),pos(4),1])
    end
    par=get(F,'PlotBoxAspectRatio');
    set(F,'DataAspectRatio',[par(2),par(1),par(3)])
    % map coordinates onto unit square
    q=[p1;p2];
    if xs, xr=log10(xr); q(:,1)=log10(q(:,1)); end
    if ys, yr=log10(yr); q(:,2)=log10(q(:,2)); end
    q=q-repmat([xr(1),yr(1),0],2*n,1);
    dx=xr(2)-xr(1); dy=yr(2)-yr(1);
    q=q*diag([1/dx,1/dy,1]);
    q1=q(1:n,:); q2=q(n+1:end,:);
end

%===============================================================
% Line
if lw>0
    if length(c)==1
        P=zeros(3*n,3); i=1:n;
        P(3*i-2,:)=p1(i,:); P(3*i-1,:)=p2(i,:); P(3*i,1)=NaN;
        H1=plot3(P(:,1),P(:,2),P(:,3),[lt,c],'LineWidth',lw);
    else
        cn=[1,1,0;1,0,1;0,1,1;1,0,0;0,1,0;0,0,1;0,0,0;1,1,1];
        for i=1:n, C(i,:)=cn(find(vc==c(i)),:); end  % color map
        set(F,'ColorOrder',C)
        H1=plot3([p1(:,1),p2(:,1)]',[p1(:,2),p2(:,2)]',[p1(:,3),p2(:,3)]',...
            lt,'LineWidth',lw);
    end
end

%===============================================================
% Scale
ar=get(F,'DataAspectRatio'); ar=sqrt(3)*ar/norm(ar);
set(F,'DataAspectRatioMode','manual')
if nargin<4 | isempty(w)              % width
    if xys, w=1;
    else
        xr=get(F,'xlim'); yr=get(F,'ylim'); zr=get(F,'zlim');
        w=norm([xr(2)-xr(1),yr(2)-yr(1),zr(2)-zr(1)])/70;
    end
end
if xys, w=w/70; end
if nargin<5 | isempty(h), h=3*w; end  % height

%===============================================================
% Arrowhead
if xys, p1=q1; p2=q2; end
W=(p1-p2)./repmat(ar,n,1);            % new z direction
W=W./repmat(sqrt(sum(W.*W,2)),1,3);   % unit vector
U=[-W(:,2),W(:,1),zeros(n,1)];        % new x direction
N=sqrt(sum(U.*U,2));                  % norm(U)
i=find(N<eps); j=length(i);
U(i,:)=repmat([1,0,0],j,1); N(i)=ones(j,1);
U=U./repmat(N,1,3);                   % unit vector
V=cross(W,U,2);                       % new y direction

m1=30; m2=10; num=200;                % max, min grid spacing, and threshold limits
if n<num, m=round((m2-m1)*n/num+m1);  % adjust grid spacing automatically
else m=m2; end                        % to speed up when matrix size>num

[x,y,z]=cylinder([0,w/2],m);
G=surf(x,y,h*z);
X=get(G,'XData'); Y=get(G,'YData'); Z=get(G,'ZData');
[j,k]=size(X);
if length(c)==1, c=repmat(c,n,1); end
H2=zeros(n,1);
for i=1:n                             % translate, rotate, and scale
    H2(i)=copyobj(G,F);
    newxyz=[X(:),Y(:),Z(:)]*[U(i,:);V(i,:);W(i,:)]*diag(ar)+...
        repmat(p2(i,:),j*k,1);
    newx=reshape(newxyz(:,1),j,k);
    newy=reshape(newxyz(:,2),j,k);
    newz=reshape(newxyz(:,3),j,k);
    if xys
        newx=newx*dx+xr(1); newy=newy*dy+yr(1);
        if xs, newx=10.^newx; end
        if ys, newy=10.^newy; end
    end
    set(H2(i),'XData',newx,'YData',newy,'ZData',newz,...
        'FaceColor',c(i),'EdgeColor','None')
end
delete(G)

%===============================================================
% Initial Point Marker
if nargin>5 & ~isempty(ip)
    if ip<=0, ip=w; elseif xys, ip=ip/70; end
    [x,y,z]=sphere(m);
    G=surf(x*ip/2*ar(1),y*ip/2*ar(2),z*ip/2*ar(3));
    X=get(G,'XData'); Y=get(G,'YData'); Z=get(G,'ZData');
    H3=zeros(n,1);
    for i=1:n                         % translate
        H3(i)=copyobj(G,F);
        newx=p1(i,1)+X; newy=p1(i,2)+Y; newz=p1(i,3)+Z;
        if xys
            newx=newx*dx+xr(1); newy=newy*dy+yr(1);
            if xs, newx=10.^newx; end
            if ys, newy=10.^newy; end
        end
        set(H3(i),'XData',newx,'YData',newy,'ZData',newz,...
            'FaceColor',c(i),'EdgeColor','None')
    end
    delete(G)
end

%===============================================================
% Finish
if ~restore, hold off, end
if c1==3                              % good for 3D view
    axis vis3d, set(gcf,'Renderer','OpenGL')
end
if xys, set(F,'DataAspectRatioMode','auto')
else, axis tight, end
if nargout, H=[H1(:);H2(:);H3(:)]; end

%===============================================================
% Generate valid value for color, linetype and lineweight
function [c,lt,lw]=LocalValidateCLTW(s)
if nargin<1, c='k'; lt='-'; lw=0.5;
else,
    % identify linetype
    if findstr(s,'--'), lt='--'; s=strrep(s,'--','');
    elseif findstr(s,'-.'), lt='-.'; s=strrep(s,'-.','');
    elseif findstr(s,'-'), lt='-'; s=strrep(s,'-','');
    elseif findstr(s,':'), lt=':'; s=strrep(s,':','');
    else, lt='-';
    end
    
    % identify lineweight
    tmp=double(s);
    tmp=find(tmp>45 & tmp<57);
    if length(tmp), lw=str2num(s(tmp)); s(tmp)='';
    else, lw=0.5; end
    
    % identify color
    c=s(1);
end